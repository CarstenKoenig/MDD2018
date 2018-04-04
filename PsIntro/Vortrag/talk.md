---
author: Carsten König
title: Einführung in PureScript
date: 10. April 2018
---

# Features

## Funktionen

Funktionen in **PureScript** sind *rein* und *total*

$$f : Domain \rightarrow \text{Co-Domain}$$

::: notes
für partielle Funktionen siehe [hier](https://github.com/purescript/documentation/blob/master/guides/The-Partial-type-class.md)
:::

---

### Beispiel
```haskell
fizzBuzzNumber :: Int -> String
fizzBuzzNumber n =
  case Tuple (n `mod` 3 == 0) (n `mod` 5 == 0) of
    Tuple true true  -> "FizzBuzz"
    Tuple true false -> "Fizz"
    Tuple false true -> "Buzz"
    _                -> show n
```

::: notes
- wollen FizzBuzz für ein Array in Range
:::

---

```haskell
fizzBuzzNumbers :: Int -> Int -> Array String
fizzBuzzNumbers from to =
  map fizzBuzzNumber (range from to)
```

::: notes
suche nach [intercalate](https://pursuit.purescript.org/packages/purescript-foldable-traversable/3.4.0/docs/Data.Foldable#v:intercalate)
über Pursuit vorführen
:::

---

```haskell
log (intercalate "\n" (fizzBuzzNumbers 1 30))
```

## Algebraische Datentypen

**Produkt-** / **Summen**-Datentypen

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

#### Warum *Produkt*?

Wieviele mögliche Werte hat der Typ

```haskell
data Kombination = MkKomb Bool Char
```

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

#### Warum *Summe*?

Wieviele mögliche Werte hat der Typ

```haskell
data Alternative = Entweder Bool | Oder Char
```


## Records
Product-Types mit Labels

## Row-Polymorphism
richtig flexible Records

## Typklassen
unbedingt JS zeigen

## Higher-Kinded-Types
nicht unbedingt "freundlich" ;)

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

## Effects
Seiteneffekte sind wirklich explizit

## Interop
zu Javascript und zurück recht einfach

# UI-Frameworks

## 
![source [Twitter](https://twitter.com/paf31/status/981203006979846145)](../images/UiAuswahl.png){height=550px}


## Pux

## Halogen
Komponenten mit _interessanten_ Typen

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
