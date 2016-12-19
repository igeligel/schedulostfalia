{-# LANGUAGE OverloadedStrings #-}
module Schedulostfalia.Request where
import Network.Wreq
-- Operators such as (&) and (.~).
import Control.Lens
import qualified Data.ByteString as ByteStringOperation
import Text.HTML.TagSoup
import Data.List.Split
import qualified Data.ByteString.Char8 as ByteStringCharacterOperation
import qualified Data.ByteString.Lazy as ByteStringLazyOperation

import Language.Haskell.TH.Ppr

import Data.Maybe

standardHeader::ByteStringOperation.ByteString
standardHeader = "identifier%5B%5D"

standardValue::ByteStringOperation.ByteString
standardValue = "%23SPLUSB3BC2B"

getBodyForOstfalia course = do
    r <- post ("http://splus.ostfalia.de/semesterplan123.php?identifier=%23" ++ course) [standardHeader := standardValue]
    let z = r^? responseBody
    return (fromJust z)

exampleTableRow = "<tr><td rowspan='1' class='row-label-one'>7:00</td><td class='cell-border'>&nbsp;</td><td class='cell-border'>&nbsp;</td><td class='cell-border'>&nbsp;</td><td class='cell-border'>&nbsp;</td><td class='cell-border'>&nbsp;</td><td class='cell-border'>&nbsp;</td></tr>"
exampleWithCourse = "<tr> <td rowspan='1' class='row-label-one'>12:00</td> <td class='cell-border'>&nbsp;</td> <td class='cell-border'>&nbsp;</td> <td class='cell-border'>&nbsp;</td> <td class='object-cell-border' colspan='1' rowspan='6'> <!-- START OBJECT-CELL --> <table class='object-cell-args' cellspacing='0' border='0' width='100%'> <col class='object-cell-0-1' /> <tr> <td align='center'>MA-SoftwareEngineeringProjekt</td> </tr> </table> <table class='object-cell-args' cellspacing='0' border='0' width='100%'> <col class='object-cell-1-1' /> <tr> <td align='center'></td> </tr> </table> <table class='object-cell-args' cellspacing='0' border='0' width='100%'> <col class='object-cell-2-0' /> <col class='object-cell-2-2' /> <tr> <td align='left'>H&ouml;rsaal 127</td> <td align='right'>Prof. Dr. B. M&uuml;ller</td> </tr> </table> <!-- END OBJECT-CELL --> </td> <td class='cell-border'>&nbsp;</td> <td class='cell-border'>&nbsp;</td> </tr>"
exampleMultipleRows = "<tr> <td rowspan='1' class='row-label-one'>11:45</td><td class='cell-border'>&nbsp;</td><td class='cell-border'>&nbsp;</td><td class='cell-border'>&nbsp;</td><td class='cell-border'>&nbsp;</td><td class='cell-border'>&nbsp;</td><td class='cell-border'>&nbsp;</td></tr><tr> <td rowspan='1' class='row-label-one'>12:00</td><td class='cell-border'>&nbsp;</td><td class='cell-border'>&nbsp;</td><td class='cell-border'>&nbsp;</td><td class='object-cell-border' colspan='1' rowspan='6'> <table class='object-cell-args' cellspacing='0' border='0' width='100%'> <col class='object-cell-0-1'/> <tr> <td align='center'>MA-SoftwareEngineeringProjekt</td></tr></table> <table class='object-cell-args' cellspacing='0' border='0' width='100%'> <col class='object-cell-1-1'/> <tr> <td align='center'></td></tr></table> <table class='object-cell-args' cellspacing='0' border='0' width='100%'> <col class='object-cell-2-0'/> <col class='object-cell-2-2'/> <tr> <td align='left'>H&ouml;rsaal 127</td><td align='right'>Prof. Dr. B. M&uuml;ller</td></tr></table> </td><td class='cell-border'>&nbsp;</td><td class='cell-border'>&nbsp;</td></tr>"

splitByTableRow:: String -> [String]
splitByTableRow input = splitOn "<tr>" input

parseBlock input = do
    let time = getTime input
    let name = getCourseName input
    let room = getCourseRoom input
    let lecturer = getCourseLecturer input
    putStrLn time
    putStrLn name
    putStrLn room
    putStrLn lecturer

getTime element = Prelude.head (splitOn "<" (splitOn "one'>" (splitOn "<td" element !! 1) !! 1))

isThereaCourse input = "object-cell-border" `ByteStringCharacterOperation.isInfixOf` ByteStringCharacterOperation.pack input

getSemesterFive = getBodyForOstfalia "SPLUS63AE5D"

getCourseName input = 
    if isThereaCourse input
        then head (splitOn "</td>" (splitOn "<td align='center'>" input !! 1))
        else ""

getCourseRoom input = 
    if isThereaCourse input
        then head (splitOn "</td>" (splitOn "<td align='left'>" input !! 1))
        else ""

getCourseLecturer input = 
    if isThereaCourse input
        then head (splitOn "</td>" (splitOn "<td align='right'>" input !! 1))
        else ""

charToString :: Char -> String
charToString = (:[])
