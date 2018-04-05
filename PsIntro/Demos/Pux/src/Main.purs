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

data Event 
  = Reset 
  | Mehr
  | Wurf Int

type State = 
  { gameOver :: Boolean
  , wuerfe   :: Array Int
  }


initial :: State
initial = { gameOver: false
          , wuerfe: []
          }

punkte :: State -> Int
punkte = sum <<< _.wuerfe          


addWurf :: Int -> State -> State
addWurf n state =
  if state.gameOver then
    state
  else
    checkGameOver $ state { wuerfe = state.wuerfe <> [n] }

checkGameOver :: State -> State
checkGameOver state =
  if punkte state >= 21 then
    state { gameOver = true }
  else
    state

type AppEffects = ( random :: RANDOM )

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
update Reset curState = 
  { state: initial
  , effects: [] 
  }
update (Wurf n) curState = 
  { state: addWurf n curState
  , effects: [] 
  }
update Mehr curState = 
  { state: curState
  , effects: 
    [ do
      w <- Wurf <$> liftEff (randomInt 1 6)
      pure $ Just w
    ] 
  }


-- | Return markup from the state
view :: State -> HTML Event
view state = do
  h1 $ text "Black-Dice"
  div do
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
      if state.gameOver then
        p $ text ("GAME OVER - " <> show (punkte state))
      else
        p $ text ("Punkte: " <> show (punkte state))
        
