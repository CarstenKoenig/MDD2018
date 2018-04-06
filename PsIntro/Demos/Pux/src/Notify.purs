module Notify where

import Prelude
import Control.Monad.Eff (Eff, kind Effect)


foreign import data NOTIFY :: Effect

foreign import show :: forall eff . String -> Eff ( notify :: NOTIFY | eff ) Unit