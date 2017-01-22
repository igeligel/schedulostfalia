{-# LANGUAGE OverloadedStrings #-}
import Network.Wreq
import Control.Lens
import Data.List.Split
import TextUtility
import HttpUtility

{- public methods -}
getSchedule course week = do
    r <- schedulePost course week
    let responseBodyContent = r ^? responseBody
    let responseBodyString = fromLazyByteStringToString responseBodyContent
    let realBody = getBody responseBodyString
    let table = getScheduleTable realBody
    let tableRows = splitByTableRow table
    let result = convertToAllTds [] tableRows
    let readableResult = map toReadableFormat result
    return readableResult

{-|
  This function converts the given tuple of a course into a readable format by
  converting the beginning and ending time to a tuple and the day of the week to a String.
-}
toReadableFormat :: (String,Integer,Integer,String,String,String) -> ((Integer,Integer),(Integer,Integer),String,String,String,String)
toReadableFormat (a,b,c,d,e,f) = 
    do
        let beginningTime = convertToTime a
        let endingTime = addMinutes beginningTime b
        let weekday = convertDayNumberToReadableDate c
        (beginningTime, endingTime, weekday, d, e, f)

{-|
  This is the highest level function for the parser. It takes an empty array as first argument
  to enable recursion and the second argument as input to iterate through.
-}
convertToAllTds result inputRows = 
    if null inputRows
        then result 
        else do
            let bestResult = convertAllRows [] inputRows
            bestResult

{-|
  This is a function which will also take an empty array because of recursion and will take a single
  row as argument to split it up into different table datas (courses).
-}
convertAllRows result input
    | null input = result
    | otherwise = convertAllRows (result ++ innerResult) (drop 1 input)
    where tablespan = splitTableData (head input)
          time = getTime (head tablespan)
          innerResult = convertAllSpans [] tablespan time 0

{-|
  This is the function which will take an empty array as first argument (because of recursion), the
  table data entries, the current time because this will be parsed once per row and a number how many
  got deleted already. This is important because of the offset and the weekday which can be constructed
  by this number.
-}
convertAllSpans :: Num a => [(t, Integer, a, String, String, String)] -> [String] -> t -> a -> [(t, Integer, a, String, String, String)]
convertAllSpans result timedatas time deleted
    | not (null timedatas) && (substring "object-cell-border" toCheck)     = convertAllSpans (result ++ [insertTuple]) (drop 1 timedatas) time (deleted+1)
    | not (null timedatas) && not (substring "object-cell-border" toCheck) = convertAllSpans result (drop 1 timedatas) time (deleted+1)
    | otherwise                                                            = result
    where
        toCheck     = head timedatas
        courseName  = getCourseName toCheck
        courseRoom  = getCourseRoom toCheck
        lecturer    = getCourseLecturer toCheck
        getDuration = (read (getCourseDuration toCheck) :: Integer) * 15
        insertTuple = (time,getDuration,deleted,courseName,courseRoom,lecturer)

{- Helper Functions -}

{- Split functions -}
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

{- Tuple -}
firstSextuple :: (a,b,c,d,e,f) -> a
firstSextuple (x,_,_,_,_,_) = x

secondSextuple :: (a,b,c,d,e,f) -> b
secondSextuple (_,x,_,_,_,_) = x

thirdSextuple :: (a,b,c,d,e,f) -> c
thirdSextuple (_,_,z,_,_,_) = z

firstTuple :: (a,b) -> a
firstTuple (x,_) = x

incrementFirstTuple :: (Integer,Integer) -> (Integer,Integer)
incrementFirstTuple (x,y) = (x+1, y)

secondTuple :: (a,b) -> b
secondTuple (_,x) = x

incrementSecondTuple :: (Integer,Integer) -> (Integer,Integer)
incrementSecondTuple (x,y) = (x, succ y)

resetSecondTuple :: (Integer,Integer) -> (Integer,Integer)
resetSecondTuple (x,y) = (x,0)

{- Time utility -}
convertToTime :: String -> (Integer, Integer)
convertToTime input = 
    do
        let hours = getHour input
        let minutes = getMinutes input
        (hours,minutes)

addMinutes :: (Integer, Integer) -> Integer -> (Integer, Integer)
addMinutes time minutes
  | minutes == 0 = time
  | secondTuple time >= 59 =
    addMinutes (resetSecondTuple (incrementFirstTuple time))
      (minutes - 1)
  | otherwise = addMinutes (incrementSecondTuple time) (minutes - 1)

getHour :: String -> Integer
getHour input = read(head(splitOn ":" input)) :: Integer

getMinutes :: String -> Integer
getMinutes input = read(splitOn ":" input !! 1) :: Integer

days = ["Monday", "Tuesday", "Wednesday", "Thursday", "Friday", "Saturday", "Sunday"]

convertDayNumberToReadableDate :: Integer -> String
convertDayNumberToReadableDate input = days !! fromIntegral (input - 1)


{- In Work -}
getOffset input startTime endTime =
    0

fixOffset result input = 
    do
        let stringTime = firstSextuple (head input)
        let time = convertToTime stringTime
        let duration = secondSextuple (head input)
        let timeEnded = addMinutes time duration
        timeEnded
        