module Records where

import Prelude


type Person =
    { name    :: String 
    , caAlter :: Int
    }


carsten :: Person
carsten = { name: "Carsten", caAlter: 30 }


sagHallo :: Person -> String
sagHallo { name: n, caAlter: a } =
    if a <= 30 then
        "Hallo " <> n
    else
        "Guten Tag " <> n


hallo :: forall r . { name :: String | r } -> String
hallo rec = "Hallo " <> rec.name