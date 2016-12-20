{-# LANGUAGE OverloadedStrings #-}
import Control.Lens
import Network.Wreq
import Data.Maybe
import qualified Data.ByteString.Lazy as B
import qualified Data.ByteString.Char8 as C

standardHeader :: String
standardHeader = "identifier%5B%5D"

standardValue :: String
standardValue = "%23SPLUS659BF0"

postRequest id = do
    response <- post ("http://splus.ostfalia.de/semesterplan123.php?identifier=%23" ++ id) [(C.pack standardHeader) := (C.pack standardValue)]
    let postResponseBody = response ^? responseBody
    let responseString = toString postResponseBody
    putStrLn responseString

toString input = C.unpack (B.toStrict (fromJust input))
