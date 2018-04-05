---
author: Carsten König
title: Einführung in PureScript
date: 10. April 2018
---

# Einleitung

##
![[www.purescript.org](http://www.purescript.org/)](../images/logo.svg)

- funktionale Programmiersprache
- kompiliert in recht leserliches Javascript
- einfaches JavaScript FFI
- ausdruckstarkes Typensystem

::: notes
- von Haskell inspiriert (aber nicht lazy)
- nach Elm / Fable / Typescript
- oder um reines FP zu lernen
:::


# Syntax und Features

## Ausdrücke/Werte
- (fast) alles ist ein **Ausdruck**
- ein *Ausdruck* hat einen **Wert** und einen **Typen** 
- Daten/Werte sind *nicht-veränderbar*

---

### Beispiele

```haskell
str :: String
str = "Hallo Magdeburg"

zahl :: Number
zahl = 0.99

ganzZahlen :: Array Int
ganzZahlen = [ 1, 2, 3, 4, 5 ]
```

::: notes
- Typ und Wertwelt sind getrennt
- nach dem Kompilieren gibt es keine Typen mehr
- Signaturen eigentlich nicht benötigt
- Funktionen sind auch nur Werte mit Typ
:::

## Funktionen

Funktionen in **PureScript** sind *rein* und *total*

$$f : Domain \rightarrow \text{Co-Domain}$$

::: notes
- für jede Eingabe liefert die Funktion genau eine Ausgabe
- keine Seiteneffekte
- reine Funktionen kann man "memoizen"
- total heißt: PureScript zwingt dazu alle Fälle zu Bedenken - soll Laufzeitfehler vermeiden
- für partielle Funktionen siehe [hier](https://github.com/purescript/documentation/blob/master/guides/The-Partial-type-class.md)
:::

---

### Beispiel

```haskell
fizzBuzzNumber :: Int -> String
fizzBuzzNumber = \ n ->
  case Tuple (n `mod` 3 == 0) (n `mod` 5 == 0) of
    Tuple true true  -> "FizzBuzz"
    Tuple true false -> "Fizz"
    Tuple false true -> "Buzz"
    _                -> show n

-- oder
fizzBuzzNumber n =
  case Tuple ...
```

::: notes
- Funktion ist auch nur ein Wert
- annonyme Funktionen mit `\ x -> ...`
- Pattern matching mit `case`
- Kein eingebauter Tupel-Typ!
- wollen FizzBuzz für ein Array in Range
:::

---

```haskell
fizzBuzzNumbers :: Int -> Int -> Array String
fizzBuzzNumbers from to =
  map fizzBuzzNumber (range from to)

-- oder
fizzBuzzNumbers from to =
  fizzBuzzNumber <$> range from to
```

::: notes
fehlt noch die String zusammenzuhängen und auszugeben
:::

---

```haskell
fizzBuzzNumbers :: Int -> Int -> Array String
fizzBuzzNumbers from to =
  map fizzBuzzNumber (range from to)

...

  log (joinWith "\n" (fizzBuzzNumbers 1 30))
```

::: notes
- suche nach [joinWith](https://pursuit.purescript.org/packages/purescript-strings/3.5.0/docs/Data.String#v:joinWith)
- über Pursuit vorführen
:::


## Algebraische Datentypen

**Produkt-** / **Summen**-Datentypen

::: notes
- neben Records der Weg um eigene Datentypen zu definieren
:::

---

### Produkt

```haskell
data Tupel a b
  = Tupel a b

tupel = Tupel 42 "Handtuch"

first :: ∀ a b . Tupel a b -> a
first (Tupel a _) = a
```

---

### Warum *Produkt*?

Wieviele mögliche Werte hat der Typ

```haskell
data Kombination = MkKomb Bool Char
```

::: incremental
- `MkKomb false 'a'`
- `MkKomb false 'b'`
- ...
- `MkKomb true 'a'`
- ...
:::

---

### Summen

```haskell
data Result err res
  = Err err
  | Ok res

okRes :: Result String Int
okRes = Ok 42

withDefault :: ∀ err res . res -> Result err res -> res
withDefault def (Err _) = def
withDefault _   (Ok  v) = v
```

---

### Warum *Summe*?

Wieviele mögliche Werte hat der Typ

```haskell
data Alternative = Entweder Bool | Oder Char
```

::: incremental
- `Entweder false`
- `Entweder true`
- `Oder 'a'`
- `Oder 'b'`
- ...
:::

## *Algebraisch*?
*Produkt*/*Summen* kann man mischen

```haskell
data Algebraisch a = Entweder a Bool | Oder String
```

## Records
*Produkt-Typen* mit *Labels*

```haskell
type Person =
    { name    :: String 
    , caAlter :: Int
    }


carsten :: Person
carsten = { name: "Carsten", caAlter: 30 }


sagHallo :: Person -> String
sagHallo { name: n, caAlter: a } =
    if a <= 30 then "Hallo " <> n else "Guten Tag " <> n
```

---

gewohnter Syntax geht auch

```haskell
sagHallo :: Person -> String
sagHallo p =
    if p.caAlter <= 30 then 
      "Hallo " <> p.name 
    else 
      "Guten Tag " <> p.name
```

## Row-Polymorphism
Records sind eigentlich

```haskell
data Record :: # Type -> Type
```

([siehe Prim](https://pursuit.purescript.org/builtins/docs/Prim))

---

Funktioniert mit jedem Record, der mindestens ein Feld `name` vom Typ `String` hat

```haskell
hallo :: forall r . { name :: String | r } -> String
hallo rec = "Hallo " <> rec.name
```

## (native) Effekte
Seiteneffekte sind in *PureScript* explizit über das Typsystem (Monaden)

```haskell
main :: forall e. Eff (console :: CONSOLE | e) Unit
main = log "Hallo Welt"
```

```haskell
data Eff :: # Control.Monad.Eff.Effect -> Type -> Type
```

::: notes
- gleiches Prinzip wie bei Records
- nur in `main` werden Effekte "ausgelöst"
- `Eff` ist eine Monade
:::

---

Effekte können "verzahnt" werden

```haskell
ausgeben :: forall e . Int -> Eff (console :: CONSOLE | e) Unit
ausgeben n = log ("-> " <> show n)

wuerfel :: forall e . Eff (random :: RANDOM | e) Int
wuerfel = randomInt 1 6

wuerfeln :: forall e . Eff ( random :: RANDOM
                           , console :: CONSOLE | e) Unit
wuerfeln = do
  n <- wuerfel
  ausgeben n
```

::: notes
`Eff` wird in PS0.12 wohl ähnlich wie Haskell `IO` werden (ohne row-Polymorphismus)
:::

## Typklassen

```haskell
app :: forall a b . (a -> b) -> a -> b
app f a = f a

plusS :: Int -> Int -> String
plusS a b = show (a + b)
```

::: notes
- bisher nur entweder alle möglichen Typen
- oder sehr konrete Typen
- `show` und `(+)` kann doch aber eine Teilmenge aller Typen definiert werden
:::

---

**Typklassen** *schränken* Datentypen ein um in der Klasse
definierte Funktionen/Operatoren verfügbar zu machen.

```haskell
plusS :: forall a. Show a => Semiring a => a -> a -> String
plusS a b = show (a + b)
```

---

### Typklassen mit mehreren Parametern

```haskell
class (Monad m) <= MonadState s m | m -> s where
```

::: notes
- Monad ist eine Superklasse von MonadState (jeder MS muss M sein)
- | m -> s ist eine funktionale Abhängigkeit - der Typ der Monade muss den Zustand S eindeutig bestimmen
:::


## Kinds

```haskell
-- value
a = 5

-- type
a :: Int

-- "type" of type?
Int :: Type
```

---

## Higher-Kinded-Types

> "Funktion" zwischen Typen

```haskell
Int                          :: Type

Maybe Int                    :: Type

Maybe                        :: Type -> Type

List                         :: Type -> Type

data Fix f = Fix (f (Fix f)) :: (* -> *) -> *
```

---

können Muster wie *Funktoren*, *Monaden*, ... in der Sprache ausdrücken!

```haskell
class Functor f where
  map :: forall a b. (a -> b) -> f a -> f b

-- kind:
f :: Type -> Type

```

---

[**free monads**](https://pursuit.purescript.org/packages/purescript-free/4.2.0/docs/Control.Monad.Free)
oder [**rekursion schemes**](https://pursuit.purescript.org/packages/purescript-matryoshka/0.3.0/docs/Matryoshka.Fold#v:cata)

```haskell
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
```


## Higher-Ranked-Types
hier gibt es ein `toStr` für ein festes `s`

```haskell
notWorking :: forall s . Show s => (s -> String) -> String
notWorking toStr = toStr 42 <> " and " <> toStr true
                         ^^^ could not match type
```

---
hier gibt es für jedes `s` ein eigenes `toStr` 

```haskell
useIt :: (forall s . Show s => s -> String) -> String
useIt toStr = toStr 42 <> " and " <> toStr true
```

## Interop
zu Javascript und zurück recht einfach

# UI-Frameworks

## 
![source [Twitter](https://twitter.com/paf31/status/981203006979846145)](../images/UiAuswahl.png){height=550px}


## Pux

## Halogen
Komponenten mit _interessanten_ Typen

# Resourcen

## 
- [Homepage - www.purescript.org](http://www.purescript.org/)
- [Dokumentation - github.com/purescript/documentation](https://github.com/purescript/documentation)
- [PureScript by Example (Buch) - leanpub.com/purescript/read](https://leanpub.com/purescript/read)
- [Pursuit - pursuit.purescript.org](https://pursuit.purescript.org/)

# Fragen?

# Foo

## Code
```haskell
class Functor f where
    fmap :: (a -> b) -> f a -> f b
```

::: notes

This is my note.

- It can contain Markdown
- like this list

:::

# Bar

## 
* test
* test

***

##

:::::::::::::: {.columns}
::: {.column width="40%"}
contents... col 1
:::
::: {.column width="60%"}
contents...column 2
:::
::::::::::::::
