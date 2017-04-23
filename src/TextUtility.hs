module TextUtility where
import Data.List.Split
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

basicSplit :: String -> String -> String -> String
basicSplit begin end input = head (splitOn end (splitOn begin input !! 1))

getCourseName :: String -> String
getCourseName = basicSplit "<td align='center'>" "</td>"

getCourseRoom :: String -> String
getCourseRoom = basicSplit "<td align='left'>" "</td>"

getCourseLecturer :: String -> String
getCourseLecturer = basicSplit "<td align='right'>" "</td>"

getCourseDuration :: String -> String
getCourseDuration = basicSplit "rowspan='" "'"

getTime :: String -> String
getTime = basicSplit "row-label-one'>" "<"

getScheduleTable :: String -> String
getScheduleTable input = splitOn "class='grid-border-args' cellspacing='0'" input !! 1

splitByTableRow :: String -> [String]
splitByTableRow = splitOn "<tr >\r\n    <td  rowsp"

splitTableData :: String -> [String]
splitTableData = splitOn "<td   class='"

getBody :: String -> String
getBody input = splitOn "<body>" input !! 2
