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

data Projektion ev res = MkProj (forall a . (forall s . Proj ev s res -> a) -> a)

type Proj ev s res =
  { s0 :: s
  , fold :: s -> ev -> s
  , proj :: s -> res
  }

makeProjektion :: forall s ev res . s -> (s -> ev -> s) -> (s -> res) -> Projektion ev res
makeProjektion st0 fld pr = MkProj \apply -> apply { s0: st0, fold: fld, proj: pr }

runProj :: forall f ev res . Foldable f => Projektion ev res -> f ev -> res
runProj (MkProj proj) = proj (\p -> p.proj <<< foldl p.fold p.s0)


instance projektionFunctor :: Functor (Projektion ev) where
  map f (MkProj proj) = MkProj \run -> proj (\pr -> run $ mapP f pr)


mapP :: forall ev s a b . (a -> b) -> Proj ev s a -> Proj ev s b
mapP f pr =
  { s0: pr.s0
  , fold: pr.fold
  , proj: f <<< pr.proj
  }


instance projektionApply :: Apply (Projektion ev) where
  apply prf prx = (\ (Tuple f x) -> f x) <$> both prf prx


instance projektionApplicative :: Applicative (Projektion ev) where
  pure a = makeProjektion unit (\ _ _ -> unit) (const a)


both :: forall ev a b. Projektion ev a -> Projektion ev b -> Projektion ev (Tuple a b)           
both (MkProj pa) (MkProj pb) = MkProj \run -> pa (\prA -> pb (\prB -> run $ comp prA prB))

comp :: forall ev sA sB resA resB . Proj ev sA resA -> Proj ev sB resB -> Proj ev (Tuple sA sB) (Tuple resA resB)
comp prA prB =
  { s0: Tuple prA.s0 prB.s0
  , fold: \ (Tuple sa sb) ev -> Tuple (prA.fold sa ev) (prB.fold sb ev) 
  , proj: \ (Tuple sa sb) -> Tuple (prA.proj sa) (prB.proj sb)
  }


summe :: Projektion Int Int
summe = makeProjektion 0 (+) id

maxP :: forall a . Ord a => Projektion a (Maybe a)
maxP = makeProjektion Nothing (\m a -> max (Just a) m) id

auswertung :: Projektion Int String
auswertung = (\ s m -> "Summe " <> show s <> " mit max. " <> show m) <$> summe <*> maxP