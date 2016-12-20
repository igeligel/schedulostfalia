import qualified Data.ByteString.Lazy as B
import qualified Data.ByteString.Char8 as C

exampleString :: String
exampleString = "identifier%5B%5D"

exampleByteString = C.pack exampleString

{- To String -}
toString input = C.unpack (B.toStrict (input))