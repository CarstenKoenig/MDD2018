---
author: Carsten König
title: Funktionale Programmierung in C#
date: 10. April 2018
---

# Was ist FP?

## Funktionen
- reine/totale Funktionen erklären
- was sind Seiteneffekte
- `void` ist *verdächtig*
- Seiteneffekte an den Rand der Applikation drängen
- Currying (macht keinen Sinn in C#)

## unveränderliche Daten
- `readonly`, nur *getter*
- *setter* liefern eine neue Kopie, nicht `void`

# Result Datentyp

## Vorstellung
- Idee **Product** mit Tupeln erklären
- Wir wollen *Oder*-Typen
- `Result` ist Fehler *oder* Erfolg
- von Pattern-Matching zur `Match`-Funktion (*Catamorphismus*)
- Einfaches Beispiel: `WithDefault`
- kurzer Rückschritt zum *Tupel*

## Alternative Darstellungen
- Vererbung
- C# 7.1 Pattern-Matching

## Higher-Order Funktionen
- `Try` um Exceptions zu wrappen
- `delegate` für `TryParse` Muster
- `TryParseWith` vorstellen

## Funktor
- `BiMap` und `Map`
- andere Beispiele - Nullable, Task

## als Effekt
- `Apply`, `liftA2`
- `Traversable` über `IEnumerable`

## Monade und LINQ
- `Bind` und die *Selects*
- Beispiel vorstellen

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