module RecSchemes where
  
import Prelude
  
data Fix f = Fix (f (Fix f))

cata :: forall f a . Functor f => (f a -> a) -> Fix f -> a
cata alg (Fix ff) = alg (map (cata alg) ff)

data ListF el a = Nil | Cons el a
derive instance listFunctor :: Functor (ListF el)

type List el = Fix (ListF el)

mySum :: List Int -> Int
mySum = cata $ case _ of
    Nil          -> 0
    (Cons n acc) -> n + acc


nil = Fix Nil
cons h tl = Fix $ Cons h tl