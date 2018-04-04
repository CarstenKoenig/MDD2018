module Main where

import Prelude

import Control.Monad.Eff (Eff)
import Control.Monad.Eff.Console (CONSOLE, log)
import Data.Tuple (Tuple(..))


fizzBuzzNumber :: Int -> String
fizzBuzzNumber n =
  case Tuple (n `mod` 3 == 0) (n `mod` 5 == 0) of
    Tuple true true  -> "FizzBuzz"
    Tuple true false -> "Fizz"
    Tuple false true -> "Buzz"
    _                -> show n


main :: forall e. Eff (console :: CONSOLE | e) Unit
main = do
  log "Hello sailor!"
