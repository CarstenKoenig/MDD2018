---
author: Carsten König
title: Funktionale Programmierung in C#
date: 10. April 2018
---

# Agenda

##

- Einführung
- Funktionen
- Daten
- funkktionale Muster

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

## Lambda Kalkül

- Variablen/Symbole $x,y,a,b,...$
- Abstraktion $(\lambda \ x . \ M)$
- Applikation $(\lambda \ x . \ f \ x) \ N \ = \ f \ N$

---

### Boolsche Werte

$$true := (\lambda \ t \ f \ . \ t)$$

$$false := (\lambda \ t \ f \ . \ f)$$

---

### Boolsche Werte

```csharp
true  = (t, f)    => t;
false = (t, f)    => f;
```

---

```csharp
lcIf  = (cond, then, else) => cond (then, else);

and   = (a, b)    => a (b, false);
```

---

### natürliche Zahlen

```csharp
zero =      (s, z)   => z;
one  =      (s, z)   => s (z);
two  =      (s, z)   => s (s (z));

succ = n => (s, z)   => s (n (s,z));

iter = (n, next, i0) => n (next, i0);

plus = (a, b)        => a (succ, b);
```

# Funktionen

## reine Funktionen

eine Funktion sollte zu jeder möglichen Eingabe **genau eine** Ausgabe liefern

## keine *Seiteneffekte*

Funktionen sollen keine (*beobachtbaren*) Seiteneffekte haben

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

```csharp
static int y = 7;

int f (int x)
{
    return x + y;
}
```

---

```csharp
static int y = 7;

int f (int x)
{
    return x + y;
}
```

**nein - hängt davon ab ob sich `y` ändert**

::: notes
Gute Idee?

- einfach testbar
- leichter zu verstehen (kein globaler Zustand)
- weniger Probleme mit paralleler Abarbeitung
:::

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

::: notes
gute Idee?

Arbeit mit `Func<...>` in C# sehr lästig - auch weil Typinferenz nur sehr eingeschränkt ist
:::

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

::: notes
gute Idee?

ja! - LINQ, Rx sind gute Beispiele
:::

## Komposition

$$ f: A \rightarrow B $$
$$ g: B \rightarrow C $$

zu neuer Funktion *verknüpft*

$$ g \circ f : A \rightarrow C$$
$$ a \mapsto g (f(a)) $$

---

### in C\#

```csharp
public static Func<tA, tC> After<tA, tB, tC>(
    this Func<tB,tC> g, 
    Func<tA,tB> f)
{
    return a => g(f(a));
}
```

::: notes
gute Idee?

macht in C# keinen Sinn
:::

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

::: notes
gute Idee?

- ja - so weit wie möglich / sinnvoll
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

## Try

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
var eingabe = "33";
var zahlResult = eingabe.TryParseWith<int>(int.TryParse);
// = Success(33)

eingabe = "x"
...
// = Fehler
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

## Funktor

```csharp
double Halbieren(int x) {
    return x / 2.0;
}

var resultH = result.Map(Halbieren);
// = Fehler falls result = Fehler
// = Erfolg Hälfte falls result = Erfolg
```

---

### Abstrakt: 

mache aus einer Funktion 

$$ A \rightarrow B$$

eine Funktion 

$$ Result<E,A> \rightarrow Result<E,B> $$

---

```csharp
Func<Result<tError, tIn>, Result<tError, tOut>> 
    FMap<tError, tIn, tOut> (Func<tIn, tOut> map)
{
    return result => result.Match(
        ToFailedResult<tError, tOut>,
        inp => map(inp).ToSuccessResult<tError, tOut>());
}
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

### Andere Funktoren

- `Task<T>`
- `IEnumerable<T>` (`.Select`)
- `Func<tIn, T>`

::: notes
- den Fehler kann man auch mappen ~> Bimap
- der letze Fall sehr interessant - mit Komposition
:::

## Applikative

```csharp
Result<tErr, Func<A,B>> resF = ...;
Result<tErr, A> resA = ...;

resF.Apply(resA);
// = Fehler falls resF oder resA Fehler
// = Erfolg  f(a) sonst
```

---

### Abstrakt: 

mache aus einer Funktion in einem Result

$$ Result <E, A \rightarrow B > $$

eine Funktion 

$$ Result<E,A> \rightarrow Result<E,B> $$

---

```csharp
Result<tError, tOut> Apply<tError, tIn, tOut>(
    this Result<tError, Func<tIn, tOut>> resF, 
    Result<tError, tIn> resX)
{
    return resF.Match(
        fromFail: ToFailedResult<tError, tOut>,
        fromSuccess: f => resX.Match(
            fromFail: ToFailedResult<tError, tOut>,
            fromSuccess: x => 
                ToSuccessResult<tError, tOut>( f(x) )));
}
```

---

### Funktion mit 2 Argumenten

```csharp
Result<tError, tOut> LiftA2<tError, tIn1, tIn2, tOut>(
    Func<tIn1, tIn2, tOut> f, 
    Result<tError, tIn1> res1,
    Result<tError, tIn2> res2) 
{
    return Curry(f)
        .ToSuccessResult<tError, Func<tIn1, Func<tIn2, tOut>>>()
        .Apply(res1)
        .Apply(res2);
}
```

## Monade

**Idee:** verknüpfe ein `Result`, dass ein `A` liefert mit einer Funktion
die aus einem `A` ein anderes `Result` macht

```csharp
// haben
Result<tErr, A> resA;

Result<tErr, B> f(A a);

// wollen
Result<tErr, B> resB;
```

---

als Funktion

```csharp
Result<tError, tOut> Bind<tError, tIn, tOut>(
    Result<tError, tIn> result, 
    Func<tIn, Result<tError, tOut>> bind)
```

---

```csharp
public static Result<tError, tOut> Bind<tError, tIn, tOut>(
    this Result<tError, tIn> result, 
    Func<tIn, Result<tError, tOut>> bind)
{
    return result.Match(
        ToFailedResult<tError, tOut>,
        fromSuccess: bind);
}
```

---

### LINQ

```csharp
      Result<string, int> ergebnis =
          from zahl1 in Console
            .ReadLine()
            .TryParseWith<int>(int.TryParse)
          from zahl2 in Console
            .ReadLine()
            .TryParseWith<int>(int.TryParse)
          select zahl1 + zahl2;

      Console.WriteLine(ergebnis.Match(
          err => $"Konnte \"{err}\" nicht umwandeln",
          zahl => $"Ergebnis ist {zahl}"));
```

---

müssen `Select`, und zwei `SelectMany` Varianten implementiern

```csharp 
public static Result<tError, tOut> 
    Select<tError, tIn, tOut>(
        this Result<tError, tIn> result, 
        Func<tIn, tOut> map) {
    return result.Map(map);
}

public static Result<tError, tResult> 
    SelectMany<tError, tSource, tResult>(
        this Result<tError, tSource> source, 
        Func<tSource, Result<tError, tResult>> selector) {
    return source.Bind(selector);
}
```

---

```csharp
public static Result<tErr, tRes> 
    SelectMany<tErr, tSource, tCol, tRes>(
        this Result<tErr, tSrc> source,
        Func<tSrc, Result<tErr, tCol>> collectionSelector,
        Func<tSrc, tCol, tRes> resultSelector)
{
    return source.Bind(src =>
        collectionSelector(src)
            .Map(col => resultSelector(src, col)));
}
```

## Traversable

**Idee:** mache aus einer *Aufzählung* von `Result` Werten ein `Result`, dass
eine Aufzählung von Werten liefert

```csharp
// haben
IEnumerable<Result<tErr, tRes>>

// wollen
Result<tErr, IEnumerable<tRes>>
```

---

**Verallgemeinert**

```csharp
Result<tError, IEnumerable<tOut>> Traverse<tError, tIn, tOut>(
    this IEnumerable<tIn> inputs, 
    Func<tIn, Result<tError, tOut>> toResult)
{
    var successes = new List<tOut>();
    var hadError = false;
    var firstError = default(tError);
    ...

```

---

```csharp
    ...
    foreach (var input in inputs)
    {
        toResult(input).Match(
            err =>
            {
                firstError = err;
                hadError = true;
                return 0;
            },
    ...
}
```

---

```csharp
            ...
            res =>
            {
                successes.Add(res);
                return 1;
            });
        if (hadError)
            return firstError
                .ToFailedResult<tError, IEnumerable<tOut>>();
    } // foreach (var input in inputs)
    return successes
        .ToSuccessResult<tError, IEnumerable<tOut>>();
}
```

---

damit

```csharp
Result<tError, IEnumerable<tOut>> Sequence<tError, tOut>(
    IEnumerable<Result<tError, tOut>> results)
{
    return results.Traverse(x => x);
}
```

# Fragen ?

# Vielen Dank

# Quellen

## 
- Bild von Church: [Wikipedia](https://en.wikipedia.org/wiki/File:Alonzo_Church.jpg)