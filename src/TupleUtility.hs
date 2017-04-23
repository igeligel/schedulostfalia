module TupleUtility where

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
