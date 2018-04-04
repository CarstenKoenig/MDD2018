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
Was sind ADTs - Sum- und Product-Types erklären

## Typklassen
unbedingt JS zeigen

## Higher-Kinded-Types
nicht unbedingt "freundlich" ;)

## Row-Polymorphism
richtig flexible Records

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
