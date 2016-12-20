{-# LANGUAGE OverloadedStrings #-}
import Network.Wreq
import Control.Lens
import Data.List.Split
import Data.Maybe
import qualified Data.ByteString.Lazy as B
import qualified Data.ByteString.Char8 as C

standardHeader :: String
standardHeader = "identifier%5B%5D"

standardValue :: String
standardValue = "%23SPLUS659BF0"

{- number: 1 7:00
           2 7:15
        -}

{- day: 1 Monday
        2 Tuesday
        ...-}
getBodyForOstfalia course = do
    r <- post ("http://splus.ostfalia.de/semesterplan123.php?identifier=%23" ++ course) [(C.pack standardHeader) := (C.pack standardValue)]
    let z = r ^? responseBody
    let responseString = toFuckingString z
    let body = getBody responseString
    let table = getScheduleTable body
    let tableRows = splitByTableRow table
    let newResult = convertToAllTds [] tableRows "wadwa"
    return newResult {-
    let tableRows = splitByTableRow table
    let splittedTableData = splitTableData (tableRows !! number)
    let tableDataEntry = splittedTableData !! day
    let course = getCourseName tableDataEntry
    let room = getCourseRoom tableDataEntry
    let lecturer = getCourseLecturer tableDataEntry
    let time = getTime (tableRows !! number)
    return ((convertDayNumberToReadableDate day) ++ " | " ++ time ++ " | " ++ course ++ " | " ++ room ++ " | " ++ lecturer)-}


convertToAllTds result inputRows currentTime = 
    if (null inputRows) 
        then do
            result 
        else do
            let bestResult = convertAllRows [] inputRows
            bestResult

convertAllRows result input = 
    if (null input)
        then do
            result
        else do 
            let tablespan = splitTableData (head input)
            let time = getTime (head tablespan)
            let innerResult = convertAllSpans [] tablespan time 0
            convertAllRows (result ++ innerResult) (drop 1 input)
    
convertAllSpans result timedatas time deleted = 
    if (null timedatas)
        then do
            result
        else do
            let toCheck = head timedatas
            if (substring "object-cell-border" toCheck)
                then do
                    {-Parse here-}
                    let courseName = getCourseName toCheck
                    let courseRoom = getCourseRoom toCheck
                    let lecturer = getCourseLecturer toCheck
                    let getDuration = (read (getCourseDuration toCheck) :: Integer) * 15
                    let insertTuple = (time,getDuration,deleted,courseName,courseRoom,lecturer)
                    convertAllSpans (result ++ [insertTuple]) (drop 1 timedatas) time (deleted+1)
                else do
                    convertAllSpans (result) (drop 1 timedatas) time (deleted+1)


{-rowspan auslesen-}

{-if (substring "object-cell-border" (tablespan !! 4))
                then do
                    convertToAllTds (result ++ tablespan) (drop 1 inputRows) time
                else do
                    convertToAllTds (result) (drop 1 inputRows) time-}


{-((convertDayNumberToReadableDate day) ++ " | " ++ time ++ " | " ++ course ++ " | " ++ room ++ " | " ++ lecturer)-}
getCourseName input = head (splitOn "</td>" (splitOn "<td align='center'>" input !! 1))
getCourseRoom input = head (splitOn "</td>" (splitOn "<td align='left'>" input !! 1))
getCourseLecturer input = head (splitOn "</td>" (splitOn "<td align='right'>" input !! 1))
getCourseDuration input = head (splitOn "'" (splitOn "rowspan='" input !! 1))


getTime input = head (splitOn "<" (splitOn "row-label-one'>" input !! 1))

convertDayNumberToReadableDate 1 = "Monday"
convertDayNumberToReadableDate 2 = "Tuesday"
convertDayNumberToReadableDate 3 = "Wednesday"
convertDayNumberToReadableDate 4 = "Thursday"
convertDayNumberToReadableDate 5 = "Friday"
convertDayNumberToReadableDate 6 = "Saturday"

convertRowNumberToReadableTime 1 = "7:00"

getScheduleTable :: String -> String
getScheduleTable input = splitOn "class='grid-border-args' cellspacing='0'" input !! 1

filterForCourses input = filter (substring "object-cell-border") input

toFuckingString input = C.unpack (B.toStrict (fromJust input))

splitByTableRow :: String -> [String]
splitByTableRow input = splitOn "<tr >\r\n    <td  rowsp" input

splitTableData :: String -> [String]
splitTableData input = splitOn "<td   class='" input

getCourses :: [String] -> String
getCourses input = "wdawda"

hasCourse input = substring  "object-cell-border" input

getBody :: String -> String
getBody input = splitOn "<body>" input !! 2

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

exampleList = ["  >\r\n\r\n<!-- START COLUMN LABELS ONE -->\r\n<tr>\r\n    <td></td>\r\n    \r\n    <td    class='col-label-one' colspan='1'>Mo</td>\r\n    <td    class='col-label-one' colspan='1'>Di</td>\r\n    <td    class='col-label-one' colspan='1'>Mi</td>\r\n    <td    class='col-label-one' colspan='1'>Do</td>\r\n    <td    class='col-label-one' colspan='1'>Fr</td>\r\n    <td   class='col-label-one' colspan='1'>Sa</td>\r\n</tr>\r\n\r\n<!-- END COLUMN LABELS ONE -->\r\n\r\n<!-- START ROW OUTPUT -->\r\n","an='1' class='row-label-one'>7:00</td>\r\n    <td   class='cell-border'>&nbsp;</td>\r\n    <td   class='cell-border'>&nbsp;</td>\r\n    <td   class='cell-border'>&nbsp;</td>\r\n    <td   class='cell-border'>&nbsp;</td>\r\n    <td   class='cell-border'>&nbsp;</td>\r\n    <td  class='cell-border'>&nbsp;</td>\r\n</tr>\r\n","an='1' class='row-label-one'>7:15</td>\r\n    <td   class='cell-border'>&nbsp;</td>\r\n    <td   class='cell-border'>&nbsp;</td>\r\n    <td   class='cell-border'>&nbsp;</td>\r\n    <td   class='cell-border'>&nbsp;</td>\r\n    <td   class='cell-border'>&nbsp;</td>\r\n    <td  class='cell-border'>&nbsp;</td>\r\n</tr>\r\n","an='1' class='row-label-one'>7:30</td>\r\n<td   class='cell-border'>&nbsp;</td>\r\n    <td   class='cell-border'>&nbsp;</td>\r\n    <td   class='cell-border'>&nbsp;</td>\r\n    <td   class='cell-border'>&nbsp;</td>\r\n    <td   class='cell-border'>&nbsp;</td>\r\n    <td  class='cell-border'>&nbsp;</td>\r\n</tr>\r\n","an='1' class='row-label-one'>7:45</td>\r\n    <td   class='cell-border'>&nbsp;</td>\r\n    <td   class='cell-border'>&nbsp;</td>\r\n    <td   class='cell-border'>&nbsp;</td>\r\n    <td   class='cell-border'>&nbsp;</td>\r\n    <td   class='cell-border'>&nbsp;</td>\r\n    <td  class='cell-border'>&nbsp;</td>\r\n</tr>\r\n","an='1' class='row-label-one'>8:00</td>\r\n    <td   class='cell-border'>&nbsp;</td>\r\n    <td   class='cell-border'>&nbsp;</td>\r\n    <td   class='cell-border'>&nbsp;</td>\r\n    <td   class='cell-border'>&nbsp;</td>\r\n    <td   class='cell-border'>&nbsp;</td>\r\n    <td  class='cell-border'>&nbsp;</td>\r\n</tr>\r\n","an='1' class='row-label-one'>8:15</td>\r\n    <td   class='cell-border'>&nbsp;</td>\r\n    <td   class='cell-border'>&nbsp;</td>\r\n    <td   class='cell-border'>&nbsp;</td>\r\n    <td   class='object-cell-border' colspan='1' rowspan='6' >\r\n<!-- START OBJECT-CELL -->\r\n<table class='object-cell-args' cellspacing='0' border='0' width='100%'>\r\n  <col class='object-cell-0-1' />\r\n<tr>\r\n  <td align='center'>IESE-IT-Sicherheit</td>\r\n</tr>\r\n</table>\r\n<table class='object-cell-args' cellspacing='0' border='0' width='100%'>\r\n  <col class='object-cell-1-1' />\r\n<tr>\r\n  <td align='center'></td>\r\n</tr>\r\n</table>\r\n<table class='object-cell-args' cellspacing='0' border='0' width='100%'>\r\n  <col class='object-cell-2-0' />\r\n  <col class='object-cell-2-2' />\r\n<tr>\r\n  <td align='left'>H&ouml;rsaal 223</td>\r\n  <td align='right'>Prof. Dr. S. Gharaei</td>\r\n</tr>\r\n</table>\r\n<!-- END OBJECT-CELL -->\r\n    </td>\r\n    <td   class='cell-border'>&nbsp;</td>\r\n    <td  class='cell-border'>&nbsp;</td>\r\n</tr>\r\n","an='1' class='row-label-one'>8:30</td>\r\n    <td   class='cell-border'>&nbsp;</td>\r\n    <td   class='cell-border'>&nbsp;</td>\r\n    <td   class='cell-border'>&nbsp;</td>\r\n    <td   class='cell-border'>&nbsp;</td>\r\n    <td  class='cell-border'>&nbsp;</td>\r\n</tr>\r\n","an='1' class='row-label-one'>8:45</td>\r\n    <td   class='cell-border'>&nbsp;</td>\r\n    <td   class='cell-border'>&nbsp;</td>\r\n    <td   class='cell-border'>&nbsp;</td>\r\n    <td   class='cell-border'>&nbsp;</td>\r\n    <td  class='cell-border'>&nbsp;</td>\r\n</tr>\r\n","an='1' class='row-label-one'>9:00</td>\r\n    <td   class='cell-border'>&nbsp;</td>\r\n<td   class='cell-border'>&nbsp;</td>\r\n    <td   class='object-cell-border' colspan='1' rowspan='12' >\r\n<!-- START OBJECT-CELL -->\r\n<table class='object-cell-args' cellspacing='0' border='0' width='100%'>\r\n  <col class='object-cell-0-1' />\r\n<tr>\r\n  <td align='center'>SOE-Weitere Programmiersprache - Projektvortr&auml;ge</td>\r\n</tr>\r\n</table>\r\n<table class='object-cell-args' cellspacing='0' border='0' width='100%'>\r\n  <col class='object-cell-1-1' />\r\n<tr>\r\n  <td align='center'>Weitere Veransta&ouml;ltung am Do 26.01.17</td>\r\n</tr>\r\n</table>\r\n<table class='object-cell-args' cellspacing='0' border='0' width='100%'>\r\n  <col class='object-cell-2-0' />\r\n  <col class='object-cell-2-2' />\r\n<tr>\r\n  <td align='left'>H&ouml;rsaal 223</td>\r\n  <td align='right'>Prof. Dr. M. Huhn</td>\r\n</tr>\r\n</table>\r\n<!-- END OBJECT-CELL -->\r\n    </td>\r\n    <td   class='cell-border'>&nbsp;</td>\r\n    <td  class='cell-border'>&nbsp;</td>\r\n</tr>\r\n","an='1' class='row-label-one'>9:15</td>\r\n    <td   class='cell-border'>&nbsp;</td>\r\n    <td   class='cell-border'>&nbsp;</td>\r\n    <td   class='cell-border'>&nbsp;</td>\r\n    <td  class='cell-border'>&nbsp;</td>\r\n</tr>\r\n","an='1' class='row-label-one'>9:30</td>\r\n    <td   class='cell-border'>&nbsp;</td>\r\n    <td   class='cell-border'>&nbsp;</td>\r\n    <td   class='cell-border'>&nbsp;</td>\r\n    <td  class='cell-border'>&nbsp;</td>\r\n</tr>\r\n","an='1' class='row-label-one'>9:45</td>\r\n    <td   class='cell-border'>&nbsp;</td>\r\n    <td   class='cell-border'>&nbsp;</td>\r\n    <td   class='cell-border'>&nbsp;</td>\r\n    <td   class='cell-border'>&nbsp;</td>\r\n    <td  class='cell-border'>&nbsp;</td>\r\n</tr>\r\n","an='1' class='row-label-one'>10:00</td>\r\n    <td   class='cell-border'>&nbsp;</td>\r\n    <td   class='cell-border'>&nbsp;</td>\r\n    <td   class='object-cell-border' colspan='1' rowspan='6' >\r\n<!-- START OBJECT-CELL -->\r\n<table class='object-cell-args' cellspacing='0' border='0' width='100%'>\r\n  <col class='object-cell-0-1' />\r\n<tr>\r\n  <td align='center'>IESE-IT-Sicherheit</td>\r\n</tr>\r\n</table>\r\n<table class='object-cell-args' cellspacing='0' border='0' width='100%'>\r\n  <col class='object-cell-1-1' />\r\n<tr>\r\n  <td align='center'></td>\r\n</tr>\r\n</table>\r\n<table class='object-cell-args' cellspacing='0' border='0' width='100%'>\r\n  <col class='object-cell-2-0' />\r\n  <col class='object-cell-2-2' />\r\n<tr>\r\n  <td align='left'>H&ouml;rsaal 223</td>\r\n  <td align='right'>Prof. Dr. S. Gharaei</td>\r\n</tr>\r\n</table>\r\n<!-- END OBJECT-CELL -->\r\n    </td>\r\n    <td   class='cell-border'>&nbsp;</td>\r\n    <td  class='cell-border'>&nbsp;</td>\r\n</tr>\r\n","an='1' class='row-label-one'>10:15</td>\r\n    <td   class='cell-border'>&nbsp;</td>\r\n    <td   class='cell-border'>&nbsp;</td>\r\n    <td   class='cell-border'>&nbsp;</td>\r\n    <td  class='cell-border'>&nbsp;</td>\r\n</tr>\r\n","an='1' class='row-label-one'>10:30</td>\r\n    <td   class='cell-border'>&nbsp;</td>\r\n    <td   class='cell-border'>&nbsp;</td>\r\n    <td   class='cell-border'>&nbsp;</td>\r\n    <td  class='cell-border'>&nbsp;</td>\r\n</tr>\r\n","an='1' class='row-label-one'>10:45</td>\r\n    <td   class='cell-border'>&nbsp;</td>\r\n    <td   class='cell-border'>&nbsp;</td>\r\n    <td   class='cell-border'>&nbsp;</td>\r\n    <td  class='cell-border'>&nbsp;</td>\r\n</tr>\r\n","an='1' class='row-label-one'>11:00</td>\r\n    <td   class='cell-border'>&nbsp;</td>\r\n    <td   class='cell-border'>&nbsp;</td>\r\n    <td   class='cell-border'>&nbsp;</td>\r\n    <td  class='cell-border'>&nbsp;</td>\r\n</tr>\r\n","an='1' class='row-label-one'>11:15</td>\r\n    <td   class='cell-border'>&nbsp;</td>\r\n    <td   class='cell-border'>&nbsp;</td>\r\n    <td   class='cell-border'>&nbsp;</td>\r\n    <td  class='cell-border'>&nbsp;</td>\r\n</tr>\r\n","an='1' class='row-label-one'>11:30</td>\r\n    <td   class='cell-border'>&nbsp;</td>\r\n    <td   class='cell-border'>&nbsp;</td>\r\n<td   class='cell-border'>&nbsp;</td>\r\n    <td   class='cell-border'>&nbsp;</td>\r\n    <td  class='cell-border'>&nbsp;</td>\r\n</tr>\r\n","an='1' class='row-label-one'>11:45</td>\r\n    <td   class='cell-border'>&nbsp;</td>\r\n    <tdclass='cell-border'>&nbsp;</td>\r\n    <td   class='cell-border'>&nbsp;</td>\r\n    <td   class='cell-border'>&nbsp;</td>\r\n    <td  class='cell-border'>&nbsp;</td>\r\n</tr>\r\n","an='1' class='row-label-one'>12:00</td>\r\n    <td   class='cell-border'>&nbsp;</td>\r\n    <td   class='cell-border'>&nbsp;</td>\r\n    <td   class='cell-border'>&nbsp;</td>\r\n    <td   class='object-cell-border' colspan='1' rowspan='6' >\r\n<!-- START OBJECT-CELL -->\r\n<table class='object-cell-args' cellspacing='0' border='0' width='100%'>\r\n  <col class='object-cell-0-1' />\r\n<tr>\r\n  <td align='center'>SOE-Weitere Programmiersprache</td>\r\n</tr>\r\n</table>\r\n<table class='object-cell-args' cellspacing='0' border='0' width='100%'>\r\n  <col class='object-cell-1-1' />\r\n<tr>\r\n  <td align='center'>Termin&auml;nderung in KW39!</td>\r\n</tr>\r\n</table>\r\n<table class='object-cell-args' cellspacing='0' border='0' width='100%'>\r\n  <col class='object-cell-2-0' />\r\n  <col class='object-cell-2-2' />\r\n<tr>\r\n  <td align='left'>H&ouml;rsaal 026</td>\r\n  <td align='right'>Prof. Dr. M. Huhn</td>\r\n</tr>\r\n</table>\r\n<!-- END OBJECT-CELL -->\r\n    </td>\r\n    <td   class='object-cell-border' colspan='1' rowspan='6' >\r\n<!-- START OBJECT-CELL -->\r\n<table class='object-cell-args' cellspacing='0' border='0' width='100%'>\r\n  <col class='object-cell-0-1' />\r\n<tr>\r\n  <td align='center'>SOE-SeProjekt</td>\r\n</tr>\r\n</table>\r\n<table class='object-cell-args' cellspacing='0' border='0' width='100%'>\r\n  <col class='object-cell-1-1' />\r\n<tr>\r\n  <td align='center'>5cr</td>\r\n</tr>\r\n</table>\r\n<table class='object-cell-args' cellspacing='0' border='0' width='100%'>\r\n  <col class='object-cell-2-0' />\r\n  <col class='object-cell-2-2' />\r\n<tr>\r\n  <td align='left'>Seminarraum 152</td>\r\n  <td align='right'>Prof. Dr. W. Pekrun</td>\r\n</tr>\r\n</table>\r\n<!-- END OBJECT-CELL -->\r\n    </td>\r\n    <td  class='cell-border'>&nbsp;</td>\r\n</tr>\r\n","an='1' class='row-label-one'>12:15</td>\r\n    <td   class='cell-border'>&nbsp;</td>\r\n    <td   class='cell-border'>&nbsp;</td>\r\n    <td   class='cell-border'>&nbsp;</td>\r\n    <td  class='cell-border'>&nbsp;</td>\r\n</tr>\r\n","an='1' class='row-label-one'>12:30</td>\r\n    <td   class='cell-border'>&nbsp;</td>\r\n    <td   class='cell-border'>&nbsp;</td>\r\n    <td   class='cell-border'>&nbsp;</td>\r\n    <td  class='cell-border'>&nbsp;</td>\r\n</tr>\r\n","an='1' class='row-label-one'>12:45</td>\r\n    <td   class='cell-border'>&nbsp;</td>\r\n    <td   class='cell-border'>&nbsp;</td>\r\n    <td   class='cell-border'>&nbsp;</td>\r\n    <td  class='cell-border'>&nbsp;</td>\r\n</tr>\r\n","an='1' class='row-label-one'>13:00</td>\r\n    <td   class='cell-border'>&nbsp;</td>\r\n    <td   class='cell-border'>&nbsp;</td>\r\n    <td   class='cell-border'>&nbsp;</td>\r\n    <td  class='cell-border'>&nbsp;</td>\r\n</tr>\r\n","an='1' class='row-label-one'>13:15</td>\r\n    <td   class='cell-border'>&nbsp;</td>\r\n    <td   class='cell-border'>&nbsp;</td>\r\n    <td   class='cell-border'>&nbsp;</td>\r\n    <td  class='cell-border'>&nbsp;</td>\r\n</tr>\r\n","an='1' class='row-label-one'>13:30</td>\r\n    <td   class='cell-border'>&nbsp;</td>\r\n    <td   class='cell-border'>&nbsp;</td>\r\n    <td   class='cell-border'>&nbsp;</td>\r\n    <td   class='cell-border'>&nbsp;</td>\r\n    <td   class='cell-border'>&nbsp;</td>\r\n    <td  class='cell-border'>&nbsp;</td>\r\n</tr>\r\n","an='1' class='row-label-one'>13:45</td>\r\n    <td   class='cell-border'>&nbsp;</td>\r\n    <td   class='cell-border'>&nbsp;</td>\r\n    <td   class='cell-border'>&nbsp;</td>\r\n    <td   class='cell-border'>&nbsp;</td>\r\n    <td   class='cell-border'>&nbsp;</td>\r\n    <td  class='cell-border'>&nbsp;</td>\r\n</tr>\r\n","an='1' class='row-label-one'>14:00</td>\r\n    <td   class='cell-border'>&nbsp;</td>\r\n    <td   class='cell-border'>&nbsp;</td>\r\n    <td   class='cell-border'>&nbsp;</td>\r\n    <td   class='cell-border'>&nbsp;</td>\r\n    <td   class='cell-border'>&nbsp;</td>\r\n    <td  class='cell-border'>&nbsp;</td>\r\n</tr>\r\n","an='1' class='row-label-one'>14:15</td>\r\n    <td   class='cell-border'>&nbsp;</td>\r\n    <td   class='cell-border'>&nbsp;</td>\r\n    <td   class='cell-border'>&nbsp;</td>\r\n    <td   class='object-cell-border' colspan='1' rowspan='6' >\r\n<!-- START OBJECT-CELL -->\r\n<table class='object-cell-args' cellspacing='0' border='0' width='100%'>\r\n  <col class='object-cell-0-1' />\r\n<tr>\r\n  <td align='center'>SOE-Weitere Programmiersprache</td>\r\n</tr>\r\n</table>\r\n<table class='object-cell-args' cellspacing='0' border='0' width='100%'>\r\n  <col class='object-cell-1-1' />\r\n<tr>\r\n  <td align='center'>Termin&auml;nderung in KW39!</td>\r\n</tr>\r\n</table>\r\n<table class='object-cell-args' cellspacing='0' border='0' width='100%'>\r\n  <col class='object-cell-2-0' />\r\n  <col class='object-cell-2-2' />\r\n<tr>\r\n  <td align='left'>H&ouml;rsaal 026</td>\r\n  <td align='right'>Prof. Dr. M. Huhn</td>\r\n</tr>\r\n</table>\r\n<!-- END OBJECT-CELL -->\r\n    </td>\r\n    <td   class='object-cell-border' colspan='1' rowspan='6' >\r\n<!-- START OBJECT-CELL -->\r\n<table class='object-cell-args' cellspacing='0' border='0' width='100%'>\r\n  <col class='object-cell-0-1' />\r\n<tr>\r\n  <td align='center'>SOE-SeProjekt</td>\r\n</tr>\r\n</table>\r\n<table class='object-cell-args' cellspacing='0' border='0' width='100%'>\r\n  <col class='object-cell-1-1' />\r\n<tr>\r\n  <td align='center'>5cr</td>\r\n</tr>\r\n</table>\r\n<table class='object-cell-args' cellspacing='0' border='0' width='100%'>\r\n  <col class='object-cell-2-0' />\r\n  <col class='object-cell-2-2' />\r\n<tr>\r\n  <td align='left'>Seminarraum 152</td>\r\n  <td align='right'>Prof. Dr. W. Pekrun</td>\r\n</tr>\r\n</table>\r\n<!-- END OBJECT-CELL -->\r\n    </td>\r\n    <td  class='cell-border'>&nbsp;</td>\r\n</tr>\r\n","an='1' class='row-label-one'>14:30</td>\r\n    <td   class='cell-border'>&nbsp;</td>\r\n    <td   class='cell-border'>&nbsp;</td>\r\n    <td   class='cell-border'>&nbsp;</td>\r\n    <td  class='cell-border'>&nbsp;</td>\r\n</tr>\r\n","an='1' class='row-label-one'>14:45</td>\r\n    <td   class='cell-border'>&nbsp;</td>\r\n    <td   class='cell-border'>&nbsp;</td>\r\n    <td   class='cell-border'>&nbsp;</td>\r\n    <td  class='cell-border'>&nbsp;</td>\r\n</tr>\r\n","an='1' class='row-label-one'>15:00</td>\r\n    <td   class='cell-border'>&nbsp;</td>\r\n    <td   class='cell-border'>&nbsp;</td>\r\n    <td   class='cell-border'>&nbsp;</td>\r\n    <td  class='cell-border'>&nbsp;</td>\r\n</tr>\r\n","an='1' class='row-label-one'>15:15</td>\r\n    <td   class='cell-border'>&nbsp;</td>\r\n    <td   class='cell-border'>&nbsp;</td>\r\n    <td   class='cell-border'>&nbsp;</td>\r\n    <td  class='cell-border'>&nbsp;</td>\r\n</tr>\r\n","an='1' class='row-label-one'>15:30</td>\r\n    <td   class='cell-border'>&nbsp;</td>\r\n    <td   class='cell-border'>&nbsp;</td>\r\n    <td   class='cell-border'>&nbsp;</td>\r\n    <td  class='cell-border'>&nbsp;</td>\r\n</tr>\r\n","an='1' class='row-label-one'>15:45</td>\r\n    <td   class='cell-border'>&nbsp;</td>\r\n    <td   class='cell-border'>&nbsp;</td>\r\n    <td   class='cell-border'>&nbsp;</td>\r\n    <td   class='cell-border'>&nbsp;</td>\r\n    <td   class='cell-border'>&nbsp;</td>\r\n    <td  class='cell-border'>&nbsp;</td>\r\n</tr>\r\n","an='1' class='row-label-one'>16:00</td>\r\n    <td   class='cell-border'>&nbsp;</td>\r\n    <td   class='cell-border'>&nbsp;</td>\r\n    <td   class='object-cell-border' colspan='1' rowspan='6' >\r\n<!-- START OBJECT-CELL -->\r\n<table class='object-cell-args' cellspacing='0' border='0' width='100%'>\r\n  <col class='object-cell-0-1' />\r\n<tr>\r\n  <td align='center'>SOE-Fortgeschr. Themen Softwaretechnik</td>\r\n</tr>\r\n</table>\r\n<table class='object-cell-args' cellspacing='0' border='0' width='100%'>\r\n  <col class='object-cell-1-1' />\r\n<tr>\r\n  <td align='center'></td>\r\n</tr>\r\n</table>\r\n<table class='object-cell-args' cellspacing='0' border='0' width='100%'>\r\n  <col class='object-cell-2-0' />\r\n  <col class='object-cell-2-2' />\r\n<tr>\r\n  <td align='left'>H&ouml;rsaal 026</td>\r\n  <td align='right'>Prof. Dr. B. M&uuml;ller</td>\r\n</tr>\r\n</table>\r\n<!-- END OBJECT-CELL -->\r\n    </td>\r\n    <td   class='object-cell-border' colspan='1' rowspan='6' >\r\n<!-- START OBJECT-CELL -->\r\n<table class='object-cell-args' cellspacing='0' border='0' width='100%'>\r\n  <col class='object-cell-0-1' />\r\n<tr>\r\n  <td align='center'>SOE-Fortgeschr. Themen Softwaretechnik</td>\r\n</tr>\r\n</table>\r\n<table class='object-cell-args' cellspacing='0' border='0' width='100%'>\r\n  <col class='object-cell-1-1' />\r\n<tr>\r\n  <td align='center'></td>\r\n</tr>\r\n</table>\r\n<table class='object-cell-args' cellspacing='0' border='0' width='100%'>\r\n  <col class='object-cell-2-0' />\r\n  <col class='object-cell-2-2' />\r\n<tr>\r\n  <td align='left'>H&ouml;rsaal 026</td>\r\n  <td align='right'>Prof. Dr. B. M&uuml;ller</td>\r\n</tr>\r\n</table>\r\n<!-- END OBJECT-CELL -->\r\n    </td>\r\n    <td   class='cell-border'>&nbsp;</td>\r\n    <td  class='cell-border'>&nbsp;</td>\r\n</tr>\r\n","an='1' class='row-label-one'>16:15</td>\r\n    <td   class='cell-border'>&nbsp;</td>\r\n    <td   class='cell-border'>&nbsp;</td>\r\n    <td   class='cell-border'>&nbsp;</td>\r\n    <td  class='cell-border'>&nbsp;</td>\r\n</tr>\r\n","an='1' class='row-label-one'>16:30</td>\r\n    <td   class='cell-border'>&nbsp;</td>\r\n    <td   class='cell-border'>&nbsp;</td>\r\n    <td   class='cell-border'>&nbsp;</td>\r\n    <td  class='cell-border'>&nbsp;</td>\r\n</tr>\r\n","an='1' class='row-label-one'>16:45</td>\r\n    <td   class='cell-border'>&nbsp;</td>\r\n    <td   class='cell-border'>&nbsp;</td>\r\n    <td   class='cell-border'>&nbsp;</td>\r\n    <td  class='cell-border'>&nbsp;</td>\r\n</tr>\r\n","an='1' class='row-label-one'>17:00</td>\r\n    <td   class='cell-border'>&nbsp;</td>\r\n    <td   class='cell-border'>&nbsp;</td>\r\n    <td   class='cell-border'>&nbsp;</td>\r\n    <td  class='cell-border'>&nbsp;</td>\r\n</tr>\r\n","an='1' class='row-label-one'>17:15</td>\r\n    <td   class='cell-border'>&nbsp;</td>\r\n    <td   class='cell-border'>&nbsp;</td>\r\n    <td   class='cell-border'>&nbsp;</td>\r\n    <td  class='cell-border'>&nbsp;</td>\r\n</tr>\r\n","an='1' class='row-label-one'>17:30</td>\r\n    <td   class='cell-border'>&nbsp;</td>\r\n    <td   class='cell-border'>&nbsp;</td>\r\n    <td   class='cell-border'>&nbsp;</td>\r\n    <td   class='cell-border'>&nbsp;</td>\r\n    <td   class='cell-border'>&nbsp;</td>\r\n    <td  class='cell-border'>&nbsp;</td>\r\n</tr>\r\n","an='1' class='row-label-one'>17:45</td>\r\n    <td   class='cell-border'>&nbsp;</td>\r\n    <td   class='cell-border'>&nbsp;</td>\r\n    <td   class='cell-border'>&nbsp;</td>\r\n    <td   class='cell-border'>&nbsp;</td>\r\n    <td   class='cell-border'>&nbsp;</td>\r\n    <td  class='cell-border'>&nbsp;</td>\r\n</tr>\r\n","an='1' class='row-label-one'>18:00</td>\r\n    <td   class='cell-border'>&nbsp;</td>\r\n    <td   class='cell-border'>&nbsp;</td>\r\n    <td   class='cell-border'>&nbsp;</td>\r\n    <td   class='cell-border'>&nbsp;</td>\r\n    <td   class='cell-border'>&nbsp;</td>\r\n    <td  class='cell-border'>&nbsp;</td>\r\n</tr>\r\n","an='1' class='row-label-one'>18:15</td>\r\n    <td   class='cell-border'>&nbsp;</td>\r\n    <td   class='cell-border'>&nbsp;</td>\r\n    <td   class='cell-border'>&nbsp;</td>\r\n    <td   class='cell-border'>&nbsp;</td>\r\n    <td   class='cell-border'>&nbsp;</td>\r\n    <td  class='cell-border'>&nbsp;</td>\r\n</tr>\r\n","an='1' class='row-label-one'>18:30</td>\r\n    <td   class='cell-border'>&nbsp;</td>\r\n    <td   class='cell-border'>&nbsp;</td>\r\n    <td   class='cell-border'>&nbsp;</td>\r\n    <td   class='cell-border'>&nbsp;</td>\r\n    <td   class='cell-border'>&nbsp;</td>\r\n    <td  class='cell-border'>&nbsp;</td>\r\n</tr>\r\n","an='1' class='row-label-one'>18:45</td>\r\n    <td   class='cell-border'>&nbsp;</td>\r\n    <td   class='cell-border'>&nbsp;</td>\r\n    <td   class='cell-border'>&nbsp;</td>\r\n    <td   class='cell-border'>&nbsp;</td>\r\n    <td   class='cell-border'>&nbsp;</td>\r\n    <td  class='cell-border'>&nbsp;</td>\r\n</tr>\r\n","an='1' class='row-label-one'>19:00</td>\r\n    <td   class='cell-border'>&nbsp;</td>\r\n    <td   class='cell-border'>&nbsp;</td>\r\n    <td   class='cell-border'>&nbsp;</td>\r\n    <td   class='cell-border'>&nbsp;</td>\r\n    <td   class='cell-border'>&nbsp;</td>\r\n    <td  class='cell-border'>&nbsp;</td>\r\n</tr>\r\n","an='1' class='row-label-one'>19:15</td>\r\n    <td   class='cell-border'>&nbsp;</td>\r\n    <td   class='cell-border'>&nbsp;</td>\r\n    <td   class='cell-border'>&nbsp;</td>\r\n    <td   class='cell-border'>&nbsp;</td>\r\n    <td   class='cell-border'>&nbsp;</td>\r\n    <td  class='cell-border'>&nbsp;</td>\r\n</tr>\r\n","an='1' class='row-label-one'>19:30</td>\r\n    <td   class='cell-border'>&nbsp;</td>\r\n    <td   class='cell-border'>&nbsp;</td>\r\n    <td   class='cell-border'>&nbsp;</td>\r\n    <td   class='cell-border'>&nbsp;</td>\r\n    <td   class='cell-border'>&nbsp;</td>\r\n    <td  class='cell-border'>&nbsp;</td>\r\n</tr>\r\n","an='1' class='row-label-one'>19:45</td>\r\n    <td   class='cell-border'>&nbsp;</td>\r\n    <td   class='cell-border'>&nbsp;</td>\r\n    <td   class='cell-border'>&nbsp;</td>\r\n    <td   class='cell-border'>&nbsp;</td>\r\n    <td   class='cell-border'>&nbsp;</td>\r\n    <td  class='cell-border'>&nbsp;</td>\r\n</tr>\r\n","an='1' class='row-label-one'>20:00</td>\r\n    <td   class='cell-border'>&nbsp;</td>\r\n    <td   class='cell-border'>&nbsp;</td>\r\n    <td   class='cell-border'>&nbsp;</td>\r\n    <td   class='cell-border'>&nbsp;</td>\r\n    <td   class='cell-border'>&nbsp;</td>\r\n    <td  class='cell-border'>&nbsp;</td>\r\n</tr>\r\n\r\n<!-- END ROW OUTPUT -->\r\n</table>\r\n\r\n<!-- START REPORT FOOTER -->\r\n<table class='footer-border-args'  border='0' cellspacing='0' width='100%'><tr>\r\n<td>\r\n<table cellspacing='0' border='0' width='100%' class='footer-0-args'>\r\n<col align='left' /><col align='center' /><col align='right' />\r\n  <tr>\r\n    <td class='left'><span class='footer-0-0-0'>Stand vom </span><span class='footer-0-0-1'>19</span><span class='footer-0-0-2'>.</span><span class='footer-0-0-3'>12</span><span class='footer-0-0-4'>.</span><span class='footer-0-0-5'>2016</span><span class='footer-0-0-6'>, </span><span class='footer-0-0-7'>23:58</span></td><td></td><td></td>\r\n  </tr>\r\n</table>\r\n</td>\r\n</tr>\r\n</table>\r\n<!-- END REPORT FOOTER -->\r\n<hr />\r\n</body>\r\n</html></div>\r\n\r\n</body>\r\n</html>"]