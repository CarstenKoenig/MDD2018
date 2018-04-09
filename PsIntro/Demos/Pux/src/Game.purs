module Game where

import Prelude hiding (div)

import Data.Foldable (sum)

type Score = Int

type State r =
  { scores :: Array Score
  | r }


totalScore :: forall r . State r -> Score
totalScore = sum <<< _.scores


addDie :: forall r . Score -> State r -> State r
addDie n state =
  if isGameOver state then
    state
  else
    state { scores = state.scores <> [n] }


isGameOver :: forall r . State r -> Boolean
isGameOver state =
  totalScore state >= 21


isGameLost :: forall r . State r -> Boolean
isGameLost state =
  totalScore state > 21


is21 :: forall r . State r -> Boolean
is21 state =
  totalScore state == 21