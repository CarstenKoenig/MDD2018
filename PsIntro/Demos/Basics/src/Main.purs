module Main where

import Prelude

import Control.Monad.Eff (Eff)
import Control.Monad.Eff.Console (CONSOLE, log)
import Data.Array (intercalate, range)
import Data.Tuple (Tuple(..))


fizzBuzzNumber :: Int -> String
fizzBuzzNumber n =
  case Tuple (n `mod` 3 == 0) (n `mod` 5 == 0) of
    Tuple true true  -> "FizzBuzz"
    Tuple true false -> "Fizz"
    Tuple false true -> "Buzz"
    _                -> show n


fizzBuzzNumbers :: Int -> Int -> Array String
fizzBuzzNumbers from to =
  map fizzBuzzNumber (range from to)
  

main :: forall e. Eff (console :: CONSOLE | e) Unit
main = do
  log $ intercalate "\n" $ fizzBuzzNumbers 1 30


data Result err res
  = Err err
  | Ok res


withDefault :: ∀ err res . res -> Result err res -> res
withDefault def (Err _) = def
withDefault _   (Ok  v) = v


-- notWorking :: forall s . Show s => (s -> String) -> String
-- notWorking toStr = toStr 42 <> " and " <> toStr true

useIt :: (forall s . Show s => s -> String) -> String
useIt toStr = toStr 42 <> " and " <> toStr true