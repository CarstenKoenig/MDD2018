module Projektion 
  ( Projektion
  , makeProjektion
  , runProj
  , auswertung
  ) where

import Prelude

import Data.Array (foldl)
import Data.Foldable (class Foldable)
import Data.Maybe (Maybe(..))
import Data.Tuple (Tuple(..))

data Projektion ev res =
  -- Existential-Trick - der s-Typ soll versteckt werden
  -- a wird benutzt, damit die Rückgabe nicht fest von der
  -- versteckten `Proj` festgelegt wird 
  -- wird benötigt um z.B. um eine Funktor-Instanz
  -- über die versteckte `Proj` zu erstellen
  MkProj (forall a . (forall s . Proj ev s res -> a) -> a)


-- damit wollen wir eigentlich arbeiten,
-- aber weil `s` von der Projektion abhängt, könnte man
-- hierrauf direkt keine Apply/Applicative Instanz
-- definieren - deswegen der Existential-Trick über `Projektion`
type Proj ev s res =
  { s0 :: s
  , fold :: s -> ev -> s
  , proj :: s -> res
  }

-- | Projektion über die Komponenten eines left-Folds erstellen
makeProjektion :: forall s ev res . s -> (s -> ev -> s) -> (s -> res) -> Projektion ev res
makeProjektion st0 fld pr = MkProj \apply -> apply { s0: st0, fold: fld, proj: pr }


-- | eine Projektion auf eine "foldable" Event-Quelle anwenden
runProj :: forall f ev res . Foldable f => Projektion ev res -> f ev -> res
runProj (MkProj apply) = 
  -- die Funktion "wünscht" sich a ~ res und setzt in apply
  -- eine Funktion ein, um die Einzelteile von `Proj` über einen links-fold
  -- zu verarbeiten
  apply (\p -> p.proj <<< foldl p.fold p.s0)


instance projektionFunctor :: Functor (Projektion ev) where
  map f (MkProj proj) = MkProj \run -> proj (run <<< mapP f)
    where
      mapP :: forall s a b . (a -> b) -> Proj ev s a -> Proj ev s b
      mapP f pr =
        { s0: pr.s0
        , fold: pr.fold
        , proj: f <<< pr.proj
        }


instance projektionApply :: Apply (Projektion ev) where
  apply prf prx = (\ (Tuple f x) -> f x) <$> both prf prx


instance projektionApplicative :: Applicative (Projektion ev) where
  pure a = makeProjektion unit (\ _ _ -> unit) (const a)


-- | verknüpfts zwei Projektionen zu einer Projektion, die das Tupel der beiden
-- | Ergebnise liefert - über `runProj` wird die Event-Foldable nur einmal durchlaufen!
both :: forall ev a b. Projektion ev a -> Projektion ev b -> Projektion ev (Tuple a b)           
both (MkProj pa) (MkProj pb) = MkProj \run -> pa (\prA -> pb (\prB -> run $ comp prA prB))
  where
    comp :: forall sA sB resA resB . Proj ev sA resA -> Proj ev sB resB -> Proj ev (Tuple sA sB) (Tuple resA resB)
    comp prA prB =
      { s0: Tuple prA.s0 prB.s0
      , fold: \ (Tuple sa sb) ev -> Tuple (prA.fold sa ev) (prB.fold sb ev) 
      , proj: \ (Tuple sa sb) -> Tuple (prA.proj sa) (prB.proj sb)
      }


---------------------------------------------------------------------------------
-- Beispiele

auswertung :: Projektion Int String
auswertung = (\ s m -> "Summe " <> show s <> " mit max. " <> show m) <$> summe <*> maxP

summe :: Projektion Int Int
summe = makeProjektion 0 (+) id

maxP :: forall a . Ord a => Projektion a (Maybe a)
maxP = makeProjektion Nothing (\m a -> max (Just a) m) id
