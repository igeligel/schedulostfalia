import Control.Lens
import Network.Wreq

standardHeader :: String
standardHeader = "identifier%5B%5D"

standardValue :: String
standardValue = "%23SPLUS659BF0"

postRequest id = do
    response <- post ("http://splus.ostfalia.de/semesterplan123.php?identifier=%23" ++ id) [(standardHeader) := (standardValue)]
    putStrLn "Done"