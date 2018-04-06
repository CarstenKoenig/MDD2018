module Main where

import Prelude hiding (div)

import Control.Monad.Eff (Eff)
import Control.Monad.Eff.Class (liftEff)
import Control.Monad.Eff.Random (RANDOM, randomInt)
import Data.Array (null)
import Data.Foldable (sum)
import Data.Maybe (Maybe(..))
import Data.String (joinWith)
import Pux (CoreEffects, EffModel, start)
import Pux.DOM.Events (onClick)
import Pux.DOM.HTML (HTML)
import Pux.Renderer.React (renderToDOM)
import Text.Smolder.HTML (button, div, p, span, h1)
import Text.Smolder.Markup (text, (#!))
import Notify (NOTIFY)
import Notify as Notify


data Event
  = Reset
  | Mehr
  | Wurf Int


type State =
  { wuerfe   :: Array Int
  }


initial :: State
initial = { wuerfe: [] }


punkte :: State -> Int
punkte = sum <<< _.wuerfe


addWurf :: Int -> State -> State
addWurf n state =
  if isGameOver state then
    state
  else
    state { wuerfe = state.wuerfe <> [n] }


isGameOver :: State -> Boolean
isGameOver state =
  punkte state >= 21


isGameLost :: State -> Boolean
isGameLost state =
  punkte state > 21


isBlackDice :: State -> Boolean
isBlackDice state =
  punkte state == 21