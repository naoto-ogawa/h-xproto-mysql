{-# LANGUAGE OverloadedStrings #-}
{-# LANGUAGE FlexibleContexts  #-}
{-# LANGUAGE TypeOperators     #-}
{-# LANGUAGE DataKinds         #-}
{-# LANGUAGE OverloadedLabels  #-}
{-# LANGUAGE RecordWildCards   #-}

module DataBase.MySQLX.ExprParser where

-- general, standard library
import Prelude   as P 
import           Control.Applicative
import           Control.Monad.Trans
import           Control.Monad.Trans.State         as SM
import           Data.Attoparsec.Combinator
import           Data.Attoparsec.ByteString.Char8  as APBC
import qualified Data.ByteString.Char8             as BC
import           Data.Scientific

-- protocol buffer library
import qualified Com.Mysql.Cj.Mysqlx.Protobuf.DocumentPathItem                   as PDPI
import qualified Com.Mysql.Cj.Mysqlx.Protobuf.Expr                               as PEx
import qualified Com.Mysql.Cj.Mysqlx.Protobuf.Object.ObjectField                 as POF
import qualified Com.Mysql.Cj.Mysqlx.Protobuf.Object                             as PO
import qualified Com.Mysql.Cj.Mysqlx.Protobuf.Order.Direction                    as POD
import qualified Com.Mysql.Cj.Mysqlx.Protobuf.Order                              as PO
import qualified Com.Mysql.Cj.Mysqlx.Protobuf.Projection                         as PP

-- my library
import DataBase.MySQLX.Functions
import DataBase.MySQLX.Model          as XM
import DataBase.MySQLX.Util           (uppercase, bs2s)

-- ------------------------------------------------------------------------------------------ 
-- State and its functions of the Parser
-- ------------------------------------------------------------------------------------------ 
data ParserState = ParserState {
    markerIdx   :: Int
  , bindList    :: [String]
} deriving (Show)

newParserState :: ParserState
newParserState =  ParserState {markerIdx = 0, bindList = []}

incParserState :: ParserState -> ParserState
incParserState s@ParserState{..} = s {markerIdx = markerIdx + 1}  

addBindParserState :: String -> ParserState -> ParserState
addBindParserState bind s@ParserState{..} = s {bindList = bind: bindList }  

incAndaddBindParserState :: String -> ParserState -> ParserState
incAndaddBindParserState bind ParserState{..} = ParserState (markerIdx + 1) (bind:bindList) 

-- ------------------------------------------------------------------------------------------ 
-- entry points
-- ------------------------------------------------------------------------------------------ 
parseCriteria :: BC.ByteString -> Either String (PEx.Expr,        ParserState)
parseCriteria = parseOnly (runStateT xParse     newParserState <* endOfInput)

parseCriteria'  :: BC.ByteString -> PEx.Expr
parseCriteria' x = either (_leftFunc x) _rightFunc $ parseCriteria x

parseProjection :: BC.ByteString -> Either String ([PP.Projection], ParserState) 
parseProjection = parseOnly (runStateT projections newParserState <* endOfInput)

parseProjection' :: BC.ByteString -> [PP.Projection]
parseProjection' x = either (_leftFunc x) _rightFunc $ parseProjection x

parseOrderBy  :: BC.ByteString -> Either String ([PO.Order],      ParserState)
parseOrderBy  = parseOnly (runStateT orderBy     newParserState <* endOfInput)

parseOrderBy' :: BC.ByteString -> [PO.Order]
parseOrderBy'  x = either (_leftFunc x) _rightFunc $ parseOrderBy x

_leftFunc x l = error $ "parse error : " ++ l ++ ", original string : \"" ++ bs2s x ++ "\""
_rightFunc (e, s) = e
-- ------------------------------------------------------------------------------------------ 
-- root parser (esp. criteria)  
-- ------------------------------------------------------------------------------------------ 
xParse :: StateT ParserState Parser PEx.Expr
xParse = orExpr

-- ------------------------------------------------------------------------------------------ 
-- grammer structure 
-- ------------------------------------------------------------------------------------------ 
orExpr :: StateT ParserState Parser PEx.Expr
orExpr = leftAsso ["||", "or"] andExpr

andExpr :: StateT ParserState Parser PEx.Expr
andExpr = leftAsso ["&&", "and"] ilriExpr 

-- ilriExpr IS, IN, LIKE, BETWEEN, REGEXP, NOT
ilriExpr :: StateT ParserState Parser PEx.Expr
ilriExpr = do
  x <- compExpr 
  b <- atomNot
  lift (string "is")        *> (do
             b2 <- atomNot  
             x2 <- compExpr
             return $ (if b2 then xIsNot else xIs) x x2
     ) <|>
    lift (string "in")      *> (lSkip >> parenExprList >>= \xs -> return $ (if b then xNotIn     else xIn   ) x xs) <|>
    lift (string "like")    *> (lSkip >> compExpr      >>= \x2 -> return $ (if b then not_like   else like  ) x x2) <|>
    lift (string "between") *> (do 
      lSkip 
      l <- compExpr
      lString "and"
      r <- compExpr
      return $ (if b then xNotBetween else xBetween) x l r
    ) <|>
    lift (string "regexp") *> (lSkip >> compExpr      >>= \x2 -> return $ (if b then not_regexp else regexp) x x2) <|> 
    return x 

-- TokenType.GE, TokenType.GT, TokenType.LE, TokenType.LT, TokenType.EQ, TokenType.NE 
compExpr :: StateT ParserState Parser PEx.Expr
compExpr = leftAsso [">=", ">", "<=", "<", "==", "!=", "="] bitExpr

-- TokenType.BITAND, TokenType.BITOR, TokenType.BITXOR 
bitExpr :: StateT ParserState Parser PEx.Expr
bitExpr = leftAsso ["&","|","^"] shiftExpr 

-- TokenType.LSHIFT, TokenType.RSHIFT
shiftExpr :: StateT ParserState Parser PEx.Expr
shiftExpr = leftAsso ["<<", ">>"] addSubExpr

addSubExpr :: StateT ParserState Parser PEx.Expr
addSubExpr = leftAsso ["+", "-"] mulDivExpr 

mulDivExpr :: StateT ParserState Parser PEx.Expr
mulDivExpr = leftAsso ["*", "/", "%"] addSubIntervalExpr 

-- *Parser> Main.pPrint_ $ Data.Attoparsec.ByteString.Char8.parseOnly addSubIntervalExpr_N  "'2011-10-11'"
-- *Parser> Main.pPrint_ $ Data.Attoparsec.ByteString.Char8.parseOnly addSubIntervalExpr_N  "'2011-10-11' + interval 31 day"
-- *Parser> Main.pPrint_ $ Data.Attoparsec.ByteString.Char8.parseOnly addSubIntervalExpr_N  "'2011-10-11' + interval 31 day - interval 1 week"
addSubIntervalExpr :: StateT ParserState Parser PEx.Expr
addSubIntervalExpr = do
  lhs <- atomicExpr 
  xs  <- many' addSubInterval_
  return $ if P.null xs 
             then lhs 
             else P.foldr (\(sign, rhs) lhs' -> ope lhs' sign rhs) 
                          (uncurry (ope lhs) (P.head xs))
                          (P.tail xs)
  where 
    ope :: PEx.Expr -> String -> [PEx.Expr] -> PEx.Expr
    ope lhs sign rhs = multiaryOperator (mkOperator sign) (lhs : rhs)

addSubInterval_ :: StateT ParserState Parser (String, [PEx.Expr])
addSubInterval_ = do
  sign <- addSubInterval
  amt  <- bitExpr  
  unit <- intervalUnit
  return (sign, [amt, unit])

addSubInterval :: StateT ParserState Parser String
addSubInterval = do
  c <- addSub 
  trimLR (lString "interval")
  return $ if c == '+' then "date_add" else "date_sub" 

addSub :: StateT ParserState Parser Char
addSub = trimLR $ lift (char '+' <|> char '-') 

intervalUnit :: StateT ParserState Parser PEx.Expr
intervalUnit = do 
  x <- trimLR $ lift (
    foldr1 (<|>) $ map stringCI
    [
      "microsecond"         
    , "second"             
    , "minute"             
    , "hour"               
    , "day"                
    , "week"               
    , "month"              
    , "quarter"            
    , "year"               
    , "second_microsecond"  
    , "minute_microsecond" 
    , "minute_second"      
    , "hour_microsecond"   
    , "hour_second"        
    , "hour_minute"        
    , "day_microsecond"    
    , "day_second"         
    , "day_minute"         
    , "day_hour"           
    , "year_month"
    ]
    )
  return $ expr x 

-- *Parser> Main.pPrint_ $ Data.Attoparsec.ByteString.Char8.parseOnly functionalCall " sum ( price1, price2  ) "
-- functionalCall :: Either String String -> StateT ParserState (Parser BC.ByteString) PEx.Expr
functionalCall :: Either String String -> StateT ParserState Parser PEx.Expr
functionalCall val = 
  case val of 
    Left  sch  -> do
       lChar '.' 
       x <- identifier  
       params <- parenExprList 
       return $ expr $ mkFunctionCall' x   sch params
    Right idn  -> do
       params <- parenExprList 
       return $ expr $ mkFunctionCall' idn "" params

leftAsso :: [String] -> StateT ParserState Parser PEx.Expr -> StateT ParserState Parser PEx.Expr
leftAsso opes inner = do
  x <- inner 
  leftAsso_ (innerLeftAsso opes) inner x
  where
    innerLeftAsso :: [String] -> StateT ParserState Parser BC.ByteString
    innerLeftAsso opes_ = lift $ P.foldr1 (<|>) (P.map (string . BC.pack) opes_)

leftAsso_ :: StateT ParserState Parser BC.ByteString -> StateT ParserState Parser PEx.Expr -> PEx.Expr -> StateT ParserState Parser PEx.Expr
leftAsso_ parser inner x = (do 
   ope <- parser
   y   <- inner
   leftAsso_ parser inner (mkBin ope x y)) <|> 
     return x
  where 
    mkBin ope = mkBinaryOperator (BC.unpack $ checkEquality ope)
    checkEquality :: BC.ByteString -> BC.ByteString
    checkEquality x = 
      case uppercase x of 
        "="       -> "==" -- Should we put this code here or in the Model.hs?
        "AND"     -> "&&"
        "OR"      -> "||"
        otherwise -> x
-- ------------------------------------------------------------------------------------------ 
-- atomic 
-- ------------------------------------------------------------------------------------------ 
{-
, EROTEME                      --> atomEroteme
, COLON                        --> atomColon
, LPAREN , RPAREN              --> atomParen
, LCURLY                       --> atomCurly           ==> JSON Object
, LSQBRACKET                   --> atomSqbracket       ==> JSON Array
, CAST                         --> atomCast 
, PLUS , MINUS                 --> atomPlusMinus
, NOTi(not) , NEG(~) , BANG(!) --> atomNagete 
, LSTRING                      --> atomString 
, NULL                         --> atomNull 
, LNUM_INT , LNUM_DOUBLE       --> atomNumeric
, TRUE , FALSE                 --> atomBool 
, DOLLAR                       --> atomDocPath 
, STAR                         
, IDENT                        --> atomIdent
-}

atomicExpr :: StateT ParserState Parser PEx.Expr
atomicExpr = trimLR $ 
  atomEroteme    <|>
  atomColon      <|>
  atomParen      <|>
  atomCurlyExpr  <|>
  atomSqbracket  <|>
  atomCast       <|>
  atomPlusMinus  <|>
  atomNegate     <|>
  atomString     <|>
  atomNull       <|>
  atomNumeric    <|>
  atomBool       <|>
  atomDocPath    <|>
  atomIdent      <|> 
  identOrFunc   

atomCurlyExpr :: StateT ParserState Parser PEx.Expr
atomCurlyExpr = do
  json <- atomCurly
  return $ expr json

atomCurly :: StateT ParserState Parser PO.Object 
atomCurly = do
  lChar '{'
  x <- sepBy atomKeyVal $ lChar ','
  lChar '}'
  return $ setObject x 

atomKeyVal :: StateT ParserState Parser POF.ObjectField 
atomKeyVal = do
  k <- trimLR atomQuotedString
  lChar ':'
  v <- atomicExpr
  return $ mkObjectField k v

atomSqbracket :: StateT ParserState Parser PEx.Expr
atomSqbracket = openCloseExprList '[' ']' ',' >>= \x -> return $ expr $ mkArray x

atomNegate :: StateT ParserState Parser PEx.Expr
atomNegate = do 
  x <- lift (string "not" <|> string "!" <|> string "~")
  y <- atomicExpr 
  return $ mkSingleOperator (BC.unpack x) y 

atomPlusMinus :: StateT ParserState Parser PEx.Expr
atomPlusMinus = do
  x <- lift (char '+' <|> char '-') 
  let b = x == '+'
  lSkip
  c <- lPeek
  case c of
    Nothing -> error "parser error"
    Just y -> if '0' <= y && y <= '9' 
                then numeric  >>= \n -> case n of
                  Left  z -> return $ expr $ (if b then id else negate) z
                  Right z -> return $ expr $ (if b then id else negate) z
                else atomicExpr >>= \z -> return $ (if b then (@+) else (@-)) z

-- cast ( expr as xxx )
atomCast :: StateT ParserState Parser PEx.Expr 
atomCast  = do
  lString "cast" 
  lSkip 
  lChar '('
  z <- xParse 
  lChar 'a' 
  lChar 's' 
  lSkip
  y <- atomCast1 <|> atomCast2 <|> atomCast3 <|> atomCast4
  lSkip 
  lChar ')'
  return $ XM.xCast [z, expr y] 

atomDecimalLetter :: StateT ParserState Parser String
atomDecimalLetter = trimLR $ lift $ many1 digit 

atomDecimalScale :: StateT ParserState Parser String 
atomDecimalScale = do 
  x <- atomDecimalLetter 
  y <- lPeek
  case y of 
    Just ',' -> lift (char ',') >> atomDecimalLetter >>= \z -> return $ x ++ "," ++ z 
    Just ')' -> return x
    Just z   -> error $ "xParenDecimalScal parse error, peekedChar " ++ [z]
    Nothing  -> error "xParenDecimalScal parse error"

-- cast (x as decimal(10,0))"
atomCast1 :: StateT ParserState Parser BC.ByteString
atomCast1 = do
  x <- lString "decimal"
  lSkip 
  lChar '('
  y <- atomDecimalScale
  lChar ')'
  return $ ('(' `BC.cons` x) `BC.append` BC.pack (" " ++ y) `BC.snoc` ')'

atomCast2 :: StateT ParserState Parser BC.ByteString
atomCast2 = lift (string "char" <|> string "binary") >>= \x -> do
  lSkip 
  lChar '(' 
  lSkip 
  num <- lift $ many1 digit
  lSkip 
  lChar ')'
  return $ x `BC.append` BC.pack ("(" ++ num ++ ")")

atomCast3 :: StateT ParserState Parser BC.ByteString
atomCast3 = (lift (string "unsigned") <|> lift (string "signed")) >>= \x -> lSkip >> lift (string "integer") >> return (x `BC.append` BC.pack " integer")

atomCast4 :: StateT ParserState Parser BC.ByteString
atomCast4 = lift (string "json") <|> lift (string "datetime" <|> "date" <|> "time") >>= \x -> return x

-- no trim
atomBool :: StateT a Parser PEx.Expr                                    -- [test]
atomBool = atomTrue <|> atomFalse 

-- no trim
atomTrue :: StateT a Parser PEx.Expr                                    -- [test]
atomTrue = lString "true" >> return (expr True)

-- no trim
atomFalse :: StateT a Parser PEx.Expr                                   -- [test]
atomFalse = lString "false" >> return (expr False)

atomNumeric :: StateT ParserState Parser PEx.Expr
atomNumeric = trimLR $ do
  x <- numeric
  return $ case x of
    Left  y -> expr (y :: Double)
    Right y -> expr (y :: Int)

numeric :: StateT ParserState Parser (Either Double Int)
numeric = lift $ floatingOrInteger <$> APBC.scientific

atomNot :: StateT ParserState Parser Bool
atomNot = do
  lSkip
  x <- lPeek
  case x of
    Just 'n' -> do 
      lString "not"
      lSkip 
      return True
    Just _   -> return False
    Nothing  -> return False

atomString :: StateT ParserState Parser PEx.Expr
atomString = do 
  x <- atomQuotedString
  return $ expr x

-- > Data.Attoparsec.ByteString.Char8.parseOnly (runStateT atomString_ []) "aaa"
-- Left "Failed reading: satisfyWith"
-- > Data.Attoparsec.ByteString.Char8.parseOnly (runStateT atomString_ []) "'aaa'"
-- Right ("aaa",[])
-- > Data.Attoparsec.ByteString.Char8.parseOnly (runStateT atomString_ []) "\"aaa\""
-- Right ("aaa",[])
-- > Data.Attoparsec.ByteString.Char8.parseOnly (runStateT atomString_ []) "`aaa`"
-- Right ("aaa",[])
atomQuotedString :: StateT ParserState Parser String 
atomQuotedString = lift parseQuatedString

atomIdent :: StateT ParserState Parser PEx.Expr
atomIdent = do
  lChar '`'
  x <- lift $ many $ notChar '`' 
  lChar '`'
  return $ exprIdentifierName x

atomNull :: StateT ParserState Parser PEx.Expr                                    -- [test]
atomNull = do
  lString "null"
  return mkNullExpr 

identOrFunc :: StateT ParserState Parser PEx.Expr
identOrFunc = do
  str <- identifier 
  c <- lPeek
  case c of
    Just '.' -> functionalCall $ Left  str 
    Just '(' -> functionalCall $ Right str 
    Just '-' -> do 
      arw <- docPathArrowLAH 
      if arw then do 
        docPathArrow
        docPath <- lift (char '$') >> lift (char '.') >> atomDocumentPath    -- TODO lift (string "$.") ?
        return $ exprColumnIdentifier $ columnIdentifierNameDocumentPahtItem str docPath
      else return $ exprIdentifierName str 
    Just  _  -> return $ exprIdentifierName str 
    Nothing  -> return $ exprIdentifierName str 

docPathArrow :: StateT ParserState Parser Bool 
docPathArrow = do 
  lChar '-' 
  x <- lift anyChar 
  return $ x == '>'

docPathArrowLAH :: StateT ParserState Parser Bool 
docPathArrowLAH = StateT $ \s -> lookAhead $ runStateT docPathArrow s

-- pPrint_ $ Data.Attoparsec.ByteString.Char8.parseOnly (runStateT xParse (ParserState 1)) "a = ? and b = ? and (c = 'x' or d = ?)"
atomEroteme :: StateT ParserState Parser PEx.Expr
atomEroteme = do
  lSkip 
  lChar '?' 
  lSkip
  s <- get
  let idx = markerIdx s
  put $ incParserState s 
  -- modify (\ParserState{..} -> ParserState (markerIdx + 1))
  return $ exprPlaceholder idx

atomColon :: StateT ParserState Parser PEx.Expr
atomColon = do
  lSkip 
  lChar ':'
  bind <- identifier
  s <- get
  let idx = markerIdx s
  put $ incAndaddBindParserState bind s
  return $ exprPlaceholder idx

atomParen :: StateT ParserState Parser PEx.Expr
atomParen = do 
  lChar '(' 
  x <- orExpr 
  lChar ')'
  return x

atomDocPath :: StateT ParserState Parser PEx.Expr 
atomDocPath = do
  lChar '$'
  docPath <- atomDocumentPath
  return $ (exprColumnIdentifier . columnIdentifierDocumentPahtItem) docPath

atomDocumentPath :: StateT ParserState Parser [PDPI.DocumentPathItem]
atomDocumentPath = many1 atomPathItem

atomPathItem :: StateT ParserState Parser PDPI.DocumentPathItem 
atomPathItem = atomMember <|> atomArrayIdx <|> atomDoubleAsterisk 

atomDoubleAsterisk_ :: StateT ParserState Parser String
atomDoubleAsterisk_ = do
  lString "**" 
  return "**" 

atomDoubleAsterisk :: StateT ParserState Parser PDPI.DocumentPathItem 
atomDoubleAsterisk = atomDoubleAsterisk_ >> return mkDoubleAsterisk

atomMember :: StateT ParserState Parser PDPI.DocumentPathItem
atomMember = atomMemberStr <|> atomMemberAst

atomMemberStr_ :: StateT ParserState Parser String 
atomMemberStr_ = do
  lChar '.' 
  identifier

atomMemberStr :: StateT ParserState Parser PDPI.DocumentPathItem 
atomMemberStr = mkMember <$> atomMemberStr_

atomMemberAst_ :: StateT ParserState Parser Char 
atomMemberAst_ = do
  lChar '.'
  lChar '*' 

atomMemberAst :: StateT ParserState Parser PDPI.DocumentPathItem 
atomMemberAst = atomMemberAst_ >> return mkMemberAsterisk

atomArrayIdx :: StateT ParserState Parser PDPI.DocumentPathItem
atomArrayIdx = atomArrayIdxNum <|> atomArrayIdxAst 

atomArrayIdxNum_ :: StateT ParserState Parser Int
atomArrayIdxNum_ = do
  lChar '['
  x <- lift APBC.decimal 
  lChar ']'
  return x 

atomArrayIdxAst_ :: StateT ParserState Parser Char 
atomArrayIdxAst_ = lift (string "[*]") >> return '*'

atomArrayIdxNum :: StateT ParserState Parser PDPI.DocumentPathItem 
atomArrayIdxNum = (mkArrayIndex . fromIntegral) <$> atomArrayIdxNum_ 

atomArrayIdxAst :: StateT ParserState Parser PDPI.DocumentPathItem 
atomArrayIdxAst = atomArrayIdxAst_ >> return mkArrayIndexAsterisk

-- ------------------------------------------------------------------------------------------ 
-- order by
-- ------------------------------------------------------------------------------------------ 
atomAsc :: Parser POD.Direction
atomAsc = trimLR' (stringCI "asc") >> return POD.ASC

atomDesc :: Parser POD.Direction
atomDesc = trimLR' (stringCI "desc") >> return POD.DESC

atomOrderdirection :: StateT ParserState Parser POD.Direction 
atomOrderdirection = lift (atomAsc <|> atomDesc)

atomOrder :: StateT ParserState Parser PO.Order 
atomOrder = do
  ex   <- orExpr
  mdir <- maybeOption atomOrderdirection
  case mdir of
    Just dir -> return PO.Order {PO.expr = ex, PO.direction = Just dir}
    Nothing  -> return PO.Order {PO.expr = ex, PO.direction = Nothing }

orderBy :: StateT ParserState Parser [PO.Order]
orderBy = sepBy atomOrder $ lChar ','

-- ------------------------------------------------------------------------------------------ 
-- projection 
-- ------------------------------------------------------------------------------------------ 
-- pPrint_ $  parseOnly (runStateT projections newParserState) "a as a__a , b as b__b " -- "a , b as b__b"
projections :: StateT ParserState Parser [PP.Projection]
projections = sepBy projection $ lChar ',' 

--
-- pPrint_ $  parseOnly (runStateT projection newParserState) "b As xx"
-- pPrint_ $  parseOnly (runStateT projection newParserState) "'a is \\'a\\'' as 'xxxx'"
projection :: StateT ParserState Parser PP.Projection
projection =  do
   x <- orExpr
   a <- as_ 
   case a of
     Just _  -> do
       lift as
       str <- trimLR (atomQuotedString <|> identifier) -- atomString_
       return $ mkProjection x str
     Nothing -> return $ mkProjection' x
  where 
    as_ :: StateT ParserState Parser (Maybe BC.ByteString)
    as_ = optional $ lift $ lookAhead as
    as :: Parser BC.ByteString 
    as = stringCI "as" 

-- ------------------------------------------------------------------------------------------ 
-- Utility for Parser
-- ------------------------------------------------------------------------------------------ 
firstChar :: Parser Char
firstChar = satisfy (\a -> isAlpha_ascii a || a == '_')

nonFirstChar :: Parser Char
nonFirstChar = satisfy (\a -> isDigit a || isAlpha_ascii a || a == '_')

identifier :: StateT ParserState Parser String 
identifier = trimLR $ lift firstChar >>= \x -> lift (many nonFirstChar) >>= \xs -> return (x:xs)

-- no trim
parenExprList :: StateT ParserState Parser [PEx.Expr]                             -- [test]
parenExprList = openCloseExprList '(' ')' ',' 

openCloseExprList :: Char -> Char -> Char -> StateT ParserState Parser [PEx.Expr]
openCloseExprList l r sep = do  
  lChar l 
  x <- sepBy xParse $ lChar sep
  lChar r 
  return x

-- | add maybe functionality to a parser.
maybeOption :: StateT ParserState Parser a -> StateT ParserState Parser (Maybe a)
maybeOption p = option Nothing (Just <$> p)

-- | trimSpace for a state parser.
trimLR :: StateT ParserState Parser a -> StateT ParserState Parser a
trimLR parser = do 
  lSkip 
  x <- parser 
  lSkip
  return x

-- | trimSpace for a pure parser.
trimLR' :: Parser a -> Parser a
trimLR' parser = skipSpace >> parser >>= \x -> skipSpace >> return x

-- | oneOf (the same as oneOf in Parsec)
oneOf :: String -> Parser Char
oneOf xs = satisfy (`elem` xs)

-- | noneOf (the same as noneOf in Parsec)
noneOf :: String -> Parser Char
noneOf xs = satisfy (`notElem` xs)

-- from https://stackoverflow.com/a/24106749
escape :: Char -> Parser String
escape l = do
    d <- char '\\'
    c <- oneOf $ l : "\\\"0nrvtbf" -- all the characters which can be escaped
    return [d, c]

nonEscape :: Parser Char
nonEscape = noneOf "\\\"\0\n\r\v\t\b\f"

character :: Char -> Parser String
character l = fmap return nonEscape <|> escape l

-- 
--  >> pPrint_ $  parseOnly parseQuatedString "'a is \\'a'"
-- Right "a is \'a"
--  >> pPrint_ $  parseOnly parseQuatedString "'aaa'"
-- Right "aaa"
--  >> pPrint_ $  parseOnly parseQuatedString "`aaa`"
-- Right "aaa"
--  >> pPrint_ $  parseOnly parseQuatedString "`a\'aa`"
-- Right "a'aa"
--  >> pPrint_ $  parseOnly parseQuatedString "'a\\'aa'"
-- Right "a\'aa"
--  >>
--
parseQuatedString :: Parser String
parseQuatedString = do
  l <- satisfy isQuoteChar 
  strings <- many $ do 
    y <- lookAhead (character l)
    if y /= [l]
      then character l >>= \z -> return z 
      else fail "satisfy" 
  satisfy (== l) 
  return $ P.concat strings

-- pure functions
isQuoteChar :: Char -> Bool
isQuoteChar = (`elem` ("'\"`" :: String))

-- lifting 
lChar :: Char -> StateT ParserState Parser Char
lChar = lift . char

lString :: BC.ByteString -> StateT a Parser BC.ByteString
lString = lift . stringCI

lSkip:: StateT a Parser () 
lSkip = lift skipSpace 

lPeek :: StateT a Parser (Maybe Char) 
lPeek  = lift peekChar 

