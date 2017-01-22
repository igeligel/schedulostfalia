{-# LANGUAGE OverloadedStrings #-}
import Network.Wreq
import Control.Lens
import TextUtility
import HttpUtility
import TupleUtility
import TimeUtility

{-|
    This is the main function used in the program to get schedules of the Ostfalia.
-}
getSchedule course week = do
    r <- schedulePost course week
    let responseBodyContent = r ^? responseBody
    let responseBodyString  = fromLazyByteStringToString responseBodyContent
    let realBody            = getBody responseBodyString
    let table               = getScheduleTable realBody
    let tableRows           = splitByTableRow table
    let result              = convertToAllTds [] tableRows
    let readableResult      = map toReadableFormat result
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
convertToAllTds result inputRows
    | null inputRows = result
    | otherwise      = convertAllRows [] inputRows

{-|
  This is a function which will also take an empty array because of recursion and will take a single
  row as argument to split it up into different table datas (courses).
-}
convertAllRows result input
    | null input = result
    | otherwise  = convertAllRows (result ++ innerResult) (drop 1 input)
    where tablespan   = splitTableData (head input)
          time        = getTime (head tablespan)
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
