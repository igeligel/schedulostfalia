module TextUtility where 

import qualified Data.ByteString.Lazy as B
import qualified Data.ByteString.Char8 as C
import Data.Maybe

fromLazyByteStringToString :: Maybe B.ByteString -> String
fromLazyByteStringToString input = C.unpack (B.toStrict (fromJust input))

substring :: String -> String -> Bool
substring (x:xs) [] = False
substring xs ys
    | prefix xs ys = True
    | substring xs (tail ys) = True
    | otherwise = False

prefix :: String -> String -> Bool
prefix [] ys = True
prefix (x:xs) [] = False
prefix (x:xs) (y:ys) = (x == y) && prefix xs ys