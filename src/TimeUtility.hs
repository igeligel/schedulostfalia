module TimeUtility where

import TupleUtility
import TextUtility
import Data.List.Split

convertToTime :: String -> (Integer, Integer)
convertToTime input = 
    do
        let hours = getHour input
        let minutes = getMinutes input
        (hours,minutes)

addMinutes :: (Integer, Integer) -> Integer -> (Integer, Integer)
addMinutes time minutes
  | minutes == 0           = time
  | secondTuple time >= 59 = addMinutes (resetSecondTuple (incrementFirstTuple time)) (minutes - 1)
  | otherwise              = addMinutes (incrementSecondTuple time) (minutes - 1)

getHour :: String -> Integer
getHour input = read(head(splitOn ":" input)) :: Integer

getMinutes :: String -> Integer
getMinutes input = read(splitOn ":" input !! 1) :: Integer

days :: [String]
days = ["Monday", "Tuesday", "Wednesday", "Thursday", "Friday", "Saturday", "Sunday"]

convertDayNumberToReadableDate :: Integer -> String
convertDayNumberToReadableDate input = days !! fromIntegral (input - 1)
