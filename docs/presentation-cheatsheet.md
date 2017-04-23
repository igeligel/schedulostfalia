# Presentation Cheatsheet

## Simple HTTP Request

```haskell
import Control.Lens
import Network.Wreq

standardHeader :: String
standardHeader = "identifier%5B%5D"

standardValue :: String
standardValue = "%23SPLUS659BF0"

postRequest id = do
    response <- post ("http://splus.ostfalia.de/semesterplan123.php?identifier=%23" ++ id) [(standardHeader) := (standardValue)]
    putStrLn "Done"
```

## HTTP Request 2

```haskell
{-# LANGUAGE OverloadedStrings #-}
import Control.Lens
import Network.Wreq
import Data.Maybe
import qualified Data.ByteString.Lazy as B
import qualified Data.ByteString.Char8 as C

standardHeader :: String
standardHeader = "identifier%5B%5D"

standardValue :: String
standardValue = "%23SPLUS659BF0"

postRequest id = do
    response <- post ("http://splus.ostfalia.de/semesterplan123.php?identifier=%23" ++ id) [(C.pack standardHeader) := (C.pack standardValue)]
    let postResponseBody = response ^? responseBody
    let responseString = toString postResponseBody
    putStrLn responseString

toString input = C.unpack (B.toStrict (fromJust input))
```

## Parsing Example

```haskell
getCourseName :: String -> String
getCourseName input = head (splitOn "</td>" (splitOn "<td align='center'>" input !! 1))
```

## String to ByteString

```haskell
import qualified Data.ByteString.Lazy as B
import qualified Data.ByteString.Char8 as C

exampleString :: String
exampleString = "identifier%5B%5D"

exampleByteString = C.pack exampleString

{- To String -}
toString input = C.unpack (B.toStrict (input))
```

## Table Data Course

```html
<tr>
  <td rowspan='1' class='row-label-one'>11:45</td>
  <td class='cell-border'>&nbsp;</td>
  <td class='cell-border'>&nbsp;</td>
  <td class='cell-border'>&nbsp;</td>
  <td class='cell-border'>&nbsp;</td>
  <td class='cell-border'>&nbsp;</td>
  <td class='cell-border'>&nbsp;</td>
</tr>
<tr>
  <td rowspan='1' class='row-label-one'>12:00</td>
  <td class='cell-border'>&nbsp;</td>
  <td class='cell-border'>&nbsp;</td>
  <td class='cell-border'>&nbsp;</td>
  <td class='object-cell-border' colspan='1' rowspan='6'>
    <!-- START OBJECT-CELL -->
    <table class='object-cell-args' cellspacing='0' border='0' width='100%'>
      <col class='object-cell-0-1' />
      <tr>
        <td align='center'>MA-SoftwareEngineeringProjekt</td>
      </tr>
    </table>
    <table class='object-cell-args' cellspacing='0' border='0' width='100%'>
      <col class='object-cell-1-1' />
      <tr>
        <td align='center'></td>
      </tr>
    </table>
    <table class='object-cell-args' cellspacing='0' border='0' width='100%'>
      <col class='object-cell-2-0' />
      <col class='object-cell-2-2' />
      <tr>
        <td align='left'>H&ouml;rsaal 127</td>
        <td align='right'>Prof. Dr. B. M&uuml;ller</td>
      </tr>
    </table>
    <!-- END OBJECT-CELL -->
  </td>
  <td class='cell-border'>&nbsp;</td>
  <td class='cell-border'>&nbsp;</td>
</tr>
```

## Table Data No Course

```html
<tr>
  <td rowspan='1' class='row-label-one'>12:15</td>
  <td class='cell-border'>&nbsp;</td>
  <td class='cell-border'>&nbsp;</td>
  <td class='cell-border'>&nbsp;</td>
  <td class='cell-border'>&nbsp;</td>
  <td class='cell-border'>&nbsp;</td>
</tr>
<tr>
  <td rowspan='1' class='row-label-one'>12:30</td>
  <td class='cell-border'>&nbsp;</td>
  <td class='cell-border'>&nbsp;</td>
  <td class='cell-border'>&nbsp;</td>
  <td class='cell-border'>&nbsp;</td>
  <td class='cell-border'>&nbsp;</td>
</tr>
```

## Dependencies

```bash
cabal update
cabal install -j --disable-tests wreq
```
