getCourseName :: String -> String
getCourseName input = head (splitOn "</td>" (splitOn "<td align='center'>" input !! 1))