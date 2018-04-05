module Main where

import Prelude hiding (div)
import Control.Monad.Eff (Eff)
import Pux (CoreEffects, EffModel, start)
import Pux.DOM.Events (onClick)
import Pux.DOM.HTML (HTML)
import Pux.Renderer.React (renderToDOM)
import Text.Smolder.HTML (button, div, span)
import Text.Smolder.Markup (text, (#!))

data Event = Increment | Decrement

type State = Int

-- | Start and render the app
main :: ∀ fx. Eff (CoreEffects fx) Unit
main = do
  app <- start
    { initialState: 0
    , view
    , foldp: update
    , inputs: []
    }

  renderToDOM "#app" app.markup app.input


-- | Return a new state (and effects) from each event
update :: ∀ fx. Event -> State -> EffModel State Event fx
update Increment n = { state: n + 1, effects: [] }
update Decrement n = { state: n - 1, effects: [] }


-- | Return markup from the state
view :: State -> HTML Event
view count =
  div do
    button #! onClick (const Increment) $ text "++"
    span $ text ("  " <> show count <> "  ")
    button #! onClick (const Decrement) $ text "--"