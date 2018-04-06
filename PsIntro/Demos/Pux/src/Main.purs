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


type AppEffects = ( random :: RANDOM, notify :: NOTIFY )


-- | Start and render the app
main :: Eff (CoreEffects AppEffects) Unit
main = do
  app <- start
    { initialState: initial
    , view
    , foldp: update
    , inputs: []
    }

  renderToDOM "#app" app.markup app.input


-- | Return a new state (and effects) from each event
update :: Event -> State -> EffModel State Event AppEffects
update Mehr curState
  | not (isGameOver curState) =
    { state: curState
    , effects:
      [ do
        w <- Wurf <$> liftEff (randomInt 1 6)
        pure $ Just w
      ]
    }
  | otherwise = 
    { state: curState, effects: [] }
update (Wurf n) curState 
  | not (isGameOver curState) =
    let state' = addWurf n curState 
    in
      { state: state'
      , effects: 
        [
          if isGameOver state' then 
            liftEff $ do
              Notify.show "GAME OVER"
              pure Nothing
          else
            pure Nothing
        ]
      }
  | otherwise = 
    { state: curState, effects: [] }
update Reset _ =
  { state: initial, effects: [] }


-- | Return markup from the state
view :: State -> HTML Event
view state = do
  h1 $ text "Black-Dice"
  div $ do
    viewWuerfe
    viewPunkte
    span $ do
      button #! onClick (const Mehr) $ text "mehr"
      button #! onClick (const Reset) $ text "Reset"
  where
    viewWuerfe =
      if null state.wuerfe then
        p $ text "keien Würfe"
      else
        p $ text (joinWith ", " $ show <$> state.wuerfe)
    viewPunkte =
      if isGameLost state then
        p $ text ("GAME OVER - " <> show (punkte state))
      else if isBlackDice state then
        p $ text "BLACK DICE!!!"
      else
        p $ text ("Punkte: " <> show (punkte state))

