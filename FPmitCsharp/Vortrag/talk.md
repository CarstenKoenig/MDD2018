---
author: Carsten König
title: Funktionale Programmierung in C#
date: 10. April 2018
---

# Was ist FP?

::: notes
- in der FP dreht sich alles um Funktionen
- Arbeiten damit (Verknüpfen, zurückgeben, ...)
- dafür müssen Funktionen *first class* sein
:::

## Lambda Kalkül

![Alonzo Church](../images/Alonzo_Church.jpg)

::: notes
- ca. 1930
- ging um Berechenbarkeit und die fundamente der Mathematik
- wurde später ausgebaut (Logiklücke)
:::

---

### Boolsche Werte

```csharp
true  = (t, f) => t
false = (t, f) => f

lcIf (b, t, e) = b (t, f)

and (a, b)     = a (b, false)
```

---

### natürliche Zahlen

```csharp
zero     = (s, z) => z
succ (n) = (s, z) => s (n (s,z))

for (n,i0,next) = n (next, i0)

plus (a, b)     = a (succ, b)
```

## Demo

---

## *reine* Funktionen

eine Funktion sollte zu jeder möglichen Eingabe **genau eine** Ausgabe liefern

```csharp
f(x) == f(x);
```

## keine *Seiteneffekte*

Funktionen sollen keine (*beobachtbaren*) Seiteneffekte bewirken

## Funktionen

> **Intuition** sollten *memoizable* sein

```csharp
static Dictionary<int, int> _cache = new Dictionary<int, int>();
static int f_memo(int x, Func<int, int> f)
{
    if (_cache.TryGetValue(x, out var y))
        return y;

    y = f(x);
    _cache[x] = y;
    return y;
}
```

---

### Beispiele

```csharp
int f (int x)
{
    return 2*x;
}
```

**ok**

---

```csharp
int f (int x)
{
    Console.WriteLine("Hallo");
    return 2*x;
}
```

**Seiteneffekt**

---

```csharp
int f (int x)
{
    return DateTime.Now.Second + x;
}
```

**keine Funktion**

---

```csharp
int f (int x)
{
    while (true) ;
    return 0;
}
```

**keine Funktion**

---

```csharp
int f (int x)
{
    throw new Exception(":(");
}
```

**keine Funktion(?)**

---

```csharp
int f (int x)
{
    var acc = 0;
    for (var i = 0; i < x; i++)
        acc += i;
    return acc;
}
```

**ok**

---

## gute Idee?

*Seiteneffekte* vermeiden / an den Rand des Systems

## currying / partial application

TODO: Erklären!

# unveränderliche Daten

::: notes
- verändern von Daten sind Seiteneffekte
- reine Funktionen und unveränderliche Daten 
:::

## wie?

- `readonly`, nur *getter*
- veränderte Kopie liefern
- `void` und `()` hinterfragen
- optional: unveränderliche Datenstrukturen falls möglich

::: notes
- Tools wie ReSharper helfen
- `System.Collections.Immutable`
:::

## gute Idee?

ja - so weit wie möglich / sinnvoll

::: notes
- irgendwann wird ein sinnvolles Programm Zustand verwalten müssen
- Beispiel am .net Framework nehmen (String, DateTime, ...)
:::


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

# Fragen ?

# Quellen

- Bild von Church: [Wikipedia](https://en.wikipedia.org/wiki/File:Alonzo_Church.jpg)

# Vielen Dank

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