module Main where

import Prelude hiding (div)

import Control.Monad.Eff (Eff)
import Control.Monad.Eff.Class (liftEff)
import Control.Monad.Eff.Random (RANDOM, randomInt)
import Data.Array (null)
import Data.Maybe (Maybe(..))
import Data.String (joinWith)
import Game as Game
import Notify (NOTIFY)
import Notify as Notify
import Pux (CoreEffects, EffModel, start)
import Pux.DOM.Events (onClick)
import Pux.DOM.HTML (HTML)
import Pux.Renderer.React (renderToDOM)
import Text.Smolder.HTML (button, div, p, span, h1)
import Text.Smolder.Markup (text, (#!))


data Event
  = Reset
  | ThrowDice
  | AddDie Game.Score


type State = { scores :: Array Game.Score }

type AppEffects = ( random :: RANDOM, notify :: NOTIFY )

initialState :: State
initialState = { scores: [] }

-- | Start and render the app
main :: Eff (CoreEffects AppEffects) Unit
main = do
  app <- start
    { initialState: initialState
    , view
    , foldp: update
    , inputs: []
    }

  renderToDOM "#app" app.markup app.input


-- | Return a new state (and effects) from each event
update :: Event -> State -> EffModel State Event AppEffects
update ThrowDice curState
  | not (Game.isGameOver curState) =
    { state: curState
    , effects:
      [ do
        score <- liftEff (randomInt 1 6)
        pure $ Just $ AddDie score
      ]
    }
  | otherwise = 
    { state: curState, effects: [] }
update (AddDie score) curState 
  | not (Game.isGameOver curState) =
    let state' = Game.addDie score curState 
    in
      { state: state'
      , effects: 
        [ do
          when (Game.isGameOver state') $
            liftEff $ Notify.show "game ended"
          pure Nothing
        ]
      }
  | otherwise = 
    { state: curState, effects: [] }
update Reset _ =
  { state: initialState, effects: [] }


-- | Return markup from the state
view :: State -> HTML Event
view state = do
  h1 $ text "Black-Dice"
  div $ do
    viewScores
    viewTotal
    span $ do
      button #! onClick (const ThrowDice) $ text "throw"
      button #! onClick (const Reset) $ text "reset"
  where
    viewScores =
      if null state.scores then
        p $ text "---"
      else
        p $ text (joinWith ", " $ show <$> state.scores)
    viewTotal =
      if Game.isGameLost state then
        p $ text ("GAME OVER - " <> show (Game.totalScore state))
      else if Game.isBlackDice state then
        p $ text "BLACK DICE!!!"
      else
        p $ text ("Score: " <> show (Game.totalScore state))

