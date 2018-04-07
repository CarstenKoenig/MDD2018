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

# Funktionen

## reine Funktionen

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

---

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

### gute Idee?

*Seiteneffekte* vermeiden / an den Rand des Systems

## currying / partial application

```csharp
int Add (int a , int b) { return a + b; }

Func<int, int> AddCurry (int a) { return b => a + b; }

var add10 = AddCurry(10);

add10(5); // == 15
```

::: notes
- in vielen FP first Sprachen werden Funktionen in "*curry* Form" gegeben
- *partial application* bedeutet: wir geben einer Funktion nur einen Parameter und erhalten eine Funktion, die den Rest erwartet
- ge*curry*te Funktionen machen *partial application* trivial
:::

---

```csharp
public static Func<tIn2, tOut> 
    PartialApply<tIn1, tIn2, tOut>( 
        this Func<tIn1, tIn2, tOut> f,
        tIn1 x1) {

  return x2 => f(x1, x2); 
  // == return Curry(f)(x1);
}

public static Func<tIn1, Func<tIn2, tOut>> 
    Curry<tIn1, tIn2, tOut>( this Func<tIn1, tIn2, tOut> f ) {

  return x1 => x2 => f(x1, x2);
}
```

---

### gute Idee?

Arbeit mit `Func<...>` in C# sehr lästig - auch weil Typinferenz nur sehr eingeschränkt ist

## Funktionen höherer Ordnung

Funktionen, die andere Funktionen als *Argumente* nutzen, oder Funktionen *zurückgeben*

---

### Beispiele

- `Curry` von gerade
- `Enumerable.Filter`

---

### Resourcenmanagment

```csharp
public T UseConnection<T>(Func<Connection, T> useCon) {
    try {
        using (var con = CreateConnection())
            return useCon(con);
    }
    catch (System.Exception error) {
        logError(error);
        throw;
    }
}

...

var result = UseConnection (con => QueryData(con, ...));

```

---

### gute Idee?

ja! - LINQ, Rx sind gute Beispiele

# Daten und Typen

## unveränderlich bitte

*Werte* in FP sollten *immutable* sein

::: notes
- verändern von Daten sind Seiteneffekte
- reine Funktionen und unveränderliche Daten 
:::

---

### wie?

- `readonly`, nur *getter*
- veränderte Kopie liefern
- `void` und `()` hinterfragen
- optional: intern unveränderliche Datenstrukturen

::: notes
- Tools wie ReSharper helfen
- `System.Collections.Immutable`
:::

---

### Beispiel

```csharp
public class Person {
    public string Name { get; }
    public int    Alter { get; }

    public Person(string name, int alter) {
        Name = name;
        Alter = alter; 
    }

    public Person ÄndereAlter(int neuesAlter) {
        return new Person (Name, neuesAlter);
    }
}
```
---

### gute Idee?

ja - so weit wie möglich / sinnvoll

::: notes
- irgendwann wird ein sinnvolles Programm Zustand verwalten müssen
- Beispiel am .net Framework nehmen (String, DateTime, ...)
:::

## Typ-Aliase

```csharp
using Name = System.String;
```

::: notes
- innerhalb einer Datei *nett*
- leider werden die nicht exportiert
- keine generischen Paramter möglich
:::

## Domänen-Typen

```csharp
public class Name {
    public string Value { get; }

    public Name(string name) {
        Value = name;
    }

    public override int GetHashCode() {
        return Value.GetHashCode();
    }
    public override string GetString() {
        return Value;
    }
}
```

::: notes
- Idee aus DDD
- in FP sehr üblich
:::

# Result Datentyp

## Vorstellung

soll

- *entweder* einen generischen Wert als **Erfolg**
- *oder* einen generischen Fehler als **Fehlschlag**

darstellen

```csharp
class Result<tError, tResult> ...
``` 

::: notes
- Tupel, Records, etc. stellen **UND** Typen dar
- wir wollen einen **ODER** Typ
:::

## Verwendung

können nicht direkt sehen ob ein *Erfolgsfall* oder *Fehler* vorliegt

```csharp
if (result.IstFehler)
    ... result.Fehler ...
else
    ... result.Ergebnis ...
```

sonst *Exceptions*?

## Idee

wie im Lambda Kalkül: Muster der Verwendung abstrahieren

```csharp
public tOut Match<tOut>( Func<tError, tOut>  fromFail
                       , Func<tResult, tOut> fromSuccess)
{
    return _isError 
        ? fromFail(_error) 
        : fromSuccess(_result);
}
```

::: notes
- das ist die charakteristische Funktion des Typs (ihr *Catamorphismus*)
- Verwendung des Datentyps kann komplett über diese Funktion erfolgen
:::

---

### Beispiel

im Fehlerfall einen Default-Wert zurückgeben

```csharp
public static tResult WithDefault<tError, tResult>(
    this Result<tError, tResult> result, 
    tResult defaultValue )
{
    return result.Match(_ => defaultValue, x => x);
}
```

---

### Implementation

```csharp
public class Result<tError, tResult>
{
    private readonly bool _isError;
    private readonly tError _error;
    private readonly tResult _result;

```

## Alternative: Vererbung

```csharp
public abstract class Result<tError, tResult> {
    public abstract tOut Match<tOut>( 
        Func<tError, tOut> fromFail,
        Func<tResult, tOut> fromSuccess);

class Failure<tError, tResult> : Result<tError, tResult> {
    private readonly tError _failure;
    public override tOut Match<tOut>(...) {
        return fromFail(_failure);

class Success<tError, tResult> : Result<tError, tResult> {
    public override tOut Match<tOut>(...) {
        return fromSuccess(_result);
 ```

## Pattern-Matching
ab C# 7.1

```csharp
public abstract class Result<tError, tResult> {
    public tOut Match<tOut>(
        Func<tError, tOut> fromFail,
        Func<tResult, tOut> fromSuccess) {
        switch (this) {
            case FailureCase f:
                return fromFail(f.Error);
            case SuccessCase s:
                return fromSuccess(s.Result);
            default:
                throw new NotSupportedException();
        }
    }
```

## Higher-Order Funktionen

```csharp
public static Result<Exception, tResult> Try<tResult>(
    this Func<tResult> action)
{
    try
    {
        return ToSuccessResult<Exception, tResult>(action());
    }
    catch (Exception failure)
    {
        return ToFailedResult<Exception, tResult>(failure);
    }
}
```

---

### TryParse Muster

```csharp
delegate bool Parser<tOut>(string input, out tOut output);

static Result<tError, tOut> TryParseWith<tError, tOut>(
    this string input, 
    Parser<tOut> parser, 
    Func<string, tError> onError)
{
    return parser(input, out var result)
        ? ToSuccessResult<tError, tOut>(result)
        : ToFailedResult<tError, tOut>(onError(input));
}
```

---

### Beispiel

```csharp
var eingabe = "33";
var zahlResult = eingabe.TryParseWith<int>(int.TryParse);
```

## Funktor

**Idee**: 

```csharp
// haben:
tOut f (tIn input)

// und
Result<tErr, tIn> value;

// wollen:
Result<tErr, tOut> f_value;
```

---

```csharp
static Result<tError, tOut> 
    Map<tError, tIn, tOut> (
        this Result<tError, tIn> result,
        Func<tIn, tOut> map )
{
    return result.Match(
        fromFail: err => 
            ToFailedResult<tError, tOut>(err),
        fromSuccess: suc => 
            ToSuccessResult<tError, tResult>(
                mapResult(suc)));
}
```

---

## BiFunktor

können auch den Fehler *mappen*

```csharp
Result<tErrorOut, tResultOut> 
    BiMap<tErrorIn, tErrorOut, tResultIn, tResultOut> (
        this Result<tErrorIn, tResultIn> result
        , Func<tErrorIn, tErrorOut> mapError
        , Func<tResultIn, tResultOut> mapResult )
{
    return result.Match(
        fromFail: err => 
            ToFailedResult<tErrorOut, tResultOut>(
                mapError(err)),
        fromSuccess: suc => 
            ToSuccessResult<tErrorOut, tResultOut>(
                mapResult(suc)));
}
```

---

### Andere Funktoren

- `Task<T>`
- `IEnumerable<T>` (`.Select`)
- `Func<tIn, T>`

## Applikative
- `Apply`, `liftA2`

## Traversable
- `Traversable` über `IEnumerable`

## Monade und LINQ
- `Bind` und die *Selects*
- Beispiel vorstellen

# Fragen ?

# Quellen

## 
- Bild von Church: [Wikipedia](https://en.wikipedia.org/wiki/File:Alonzo_Church.jpg)

# Vielen Dank