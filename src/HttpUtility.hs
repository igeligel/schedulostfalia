module HttpUtility where
import Network.Wreq
import Control.Lens
import qualified Data.ByteString.Char8 as CharOperations

{-|
  The 'packWheeks' function will take an output string and will pack it as Form Parameter which is used for the HTTP POST Request parameter.
-}
packWeeks :: Show a => a -> [FormParam]
packWeeks week = [CharOperations.pack "weeks" := CharOperations.pack (show week)]

{-|
  The 'schedulePost' function will create the IO response of the POST HTTP Request.
-}
schedulePost course week = post ("http://splus.ostfalia.de/semesterplan123.php?identifier=%23" ++ course) (packWeeks week)
