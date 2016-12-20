{-# LANGUAGE OverloadedStrings #-}
import Network.Wreq
import Control.Lens
import Data.List.Split
import Data.Maybe
import Data.Time
import qualified Data.ByteString.Lazy as B
import qualified Data.ByteString.Char8 as C

getBodyForOstfalia course week = do
    r <- post ("http://splus.ostfalia.de/semesterplan123.php?identifier=%23" ++ course) [(C.pack "weeks") := (C.pack (show week) )]
    let z = r ^? responseBody
    let responseString = fromLazyByteStringToString z
    let body = getBody responseString
    let table = getScheduleTable body
    let tableRows = splitByTableRow table
    let newResult = convertToAllTds [] tableRows "wadwa"
    let notOffsetInput = newResult
    let readableResult = map toReadableFormat notOffsetInput
    return readableResult

toReadableFormat :: (String,Integer,Integer,String,String,String) -> ((Integer,Integer),(Integer,Integer),String,String,String,String)
toReadableFormat (a,b,c,d,e,f) = 
    do
        let beginningTime = convertToTime a
        let endingTime = addMinutes beginningTime b
        let weekday = convertDayNumberToReadableDate c
        (beginningTime, endingTime, weekday, d, e, f)
 

first :: (a,b,c,d,e,f) -> a
first (x,_,_,_,_,_) = x

second :: (a,b,c,d,e,f) -> b
second (_,x,_,_,_,_) = x

third :: (a,b,c,d,e,f) -> c
third (_,_,z,_,_,_) = z

test = ("8:15",90,4,"IESE-IT-Sicherheit","H&ouml;rsaal 223","Prof. Dr. S. Gharaei")

fixOffset result input = 
    do
        let stringTime = first (head input)
        let time = convertToTime stringTime
        let duration = second (head input)
        let timeEnded = addMinutes time duration
        timeEnded

getOffset input startTime endTime =
    0


getTestTime input = 
    do
        let result = convertToTime input
        result

convertToTime input = 
    do
        let hours = getHour input
        let minutes = getMinutes input
        (hours,minutes)

firstTuple :: (a,b) -> a
firstTuple (x,_) = x

incrementFirstTuple :: (Integer,Integer) -> (Integer,Integer)
incrementFirstTuple (x,y) = (x+1, y)

secondTuple :: (a,b) -> b
secondTuple (_,x) = x

incrementSecondTuple :: (Integer,Integer) -> (Integer,Integer)
incrementSecondTuple (x,y) = (x, y+1)

resetSecondTuple :: (Integer,Integer) -> (Integer,Integer)
resetSecondTuple (x,y) = (x,0)

addMinutes time minutes = 
    if (minutes == 0)
        then do
            time
        else do
            if (secondTuple time >= 59) 
                then do
                    addMinutes (resetSecondTuple(incrementFirstTuple time)) (minutes - 1)
                else do
                    addMinutes (incrementSecondTuple time) (minutes - 1)


getHour input = read(head(splitOn ":" input)) :: Integer
getMinutes input = read((splitOn ":" input) !! 1) :: Integer

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

fromLazyByteStringToString input = C.unpack (B.toStrict (fromJust input))

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

exampleTupleResult = [("8:15",90,4,"IESE-IT-Sicherheit","H&ouml;rsaal 223","Prof. Dr. S. Gharaei"),("9:00",180,3,"SOE-Weitere Programmiersprache - Projektvortr&auml;ge","H&ouml;rsaal 223","Prof. Dr. M. Huhn"),("10:00",90,3,"IESE-IT-Sicherheit","H&ouml;rsaal 223","Prof. Dr. S. Gharaei"),("12:00",90,4,"SOE-Weitere Programmiersprache","H&ouml;rsaal 026","Prof. Dr. M. Huhn"),("12:00",90,5,"SOE-SeProjekt","Seminarraum 152","Prof. Dr. W. Pekrun"),("14:15",90,4,"SOE-Weitere Programmiersprache","H&ouml;rsaal 026","Prof. Dr. M. Huhn"),("14:15",90,5,"SOE-SeProjekt","Seminarraum 152","Prof. Dr. W. Pekrun"),("16:00",90,3,"SOE-Fortgeschr. Themen Softwaretechnik","H&ouml;rsaal 026","Prof. Dr. B. M&uuml;ller"),("16:00",90,4,"SOE-Fortgeschr. Themen Softwaretechnik","H&ouml;rsaal 026","Prof. Dr. B. M&uuml;ller")]
