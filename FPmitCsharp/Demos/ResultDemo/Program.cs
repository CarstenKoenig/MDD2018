using System;
using ResultDemo.Type;

namespace ResultDemo
{
    class Program
    {
        static void Main()
        {
            Result<string, int> ergebnis =
                from zahl1 in ZahlErfragen().TryParseWith<int>(int.TryParse)
                from zahl2 in ZahlErfragen().TryParseWith<int>(int.TryParse)
                select zahl1 + zahl2;

            Console.WriteLine(ergebnis.Match(
                err => $"Konnte \"{err}\" nicht in eine Zahl umwandeln",
                zahl => $"Ergebnis ist {zahl}"));
        }

        static string ZahlErfragen()
        {
            Console.Write("Zahl? ");
            return Console.ReadLine();
        }
    }

    public static class Result
    {
        public static tResult WithDefault<tError, tResult>(this Result<tError, tResult> result, tResult defaultValue)
        {
            return result.Match(_ => defaultValue, x => x);
        }



        public static Result<tErrorOut, tResultOut> BiMap<tErrorIn, tErrorOut, tResultIn, tResultOut>(this Result<tErrorIn, tResultIn> result, Func<tErrorIn, tErrorOut> mapError, Func<tResultIn, tResultOut> mapResult)
        {
            return result.Match(
                fromFail: err => ToFailedResult<tErrorOut, tResultOut>(mapError(err)),
                fromSuccess: suc => ToSuccessResult<tErrorOut, tResultOut>(mapResult(suc)));
        }

        public static Result<tError, tOut> Map<tError, tIn, tOut>(this Result<tError, tIn> result, Func<tIn, tOut> map)
        {
            return result.BiMap(x => x, map);
        }

        public static Result<tErrorOut, tResult> MapError<tErrorIn, tErrorOut, tResult>(this Result<tErrorIn, tResult> result, Func<tErrorIn, tErrorOut> mapError)
        {
            return result.BiMap(mapError, x => x);
        }


        public static Result<tError, tOut> Bind<tError, tIn, tOut>(this Result<tError, tIn> result, Func<tIn, Result<tError, tOut>> bind)
        {
            return result.Match(
                ToFailedResult<tError, tOut>,
                fromSuccess: bind);
        }

        public static Result<tError, tResult> ToFailedResult<tError, tResult>(this tError value)
        {
            return Result<tError, tResult>.Failure(value);
        }

        public static Result<tError, tResult> ToSuccessResult<tError, tResult>(this tResult value)
        {
            return Result<tError, tResult>.Success(value);
        }

        public static Result<Exception, tResult> Try<tResult>(this Func<tResult> action)
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

        public static Result<Exception, tOut> TryInvoke<tIn, tOut>(this Func<tIn, tOut> f, tIn arg)
        {
            return Try(() => f(arg));
        }
        public static Result<Exception, tOut> TryInvoke<tIn1, tIn2, tOut>(this Func<tIn1, tIn2, tOut> f, tIn1 arg1, tIn2 arg2)
        {
            return Try(() => f(arg1, arg2));
        }
        public static Result<Exception, tOut> TryInvoke<tIn1, tIn2, tIn3, tOut>(this Func<tIn1, tIn2, tIn3, tOut> f, tIn1 arg1, tIn2 arg2, tIn3 arg3)
        {
            return Try(() => f(arg1, arg2, arg3));
        }

        public static Result<tError, tOut> FromTryParse<tError, tOut>(this string input, Parser<tOut> parser, Func<string, tError> onFailed)
        {
            return parser(input, out var result)
                ? ToSuccessResult<tError, tOut>(result)
                : ToFailedResult<tError, tOut>(onFailed(input));
        }

        public static Result<tError, tOut> TryParseWith<tError, tOut>(this string input, Parser<tOut> parser, Func<string, tError> onError)
        {
            return FromTryParse(input, parser, onError);
        }

        public static Result<string, tOut> TryParseWith<tOut>(this string input, Parser<tOut> parser)
        {
            return FromTryParse(input, parser, x => x);
        }


        public static Result<tError, tOut> Select<tError, tIn, tOut>(this Result<tError, tIn> result, Func<tIn, tOut> map)
        {
            return result.Map(map);
        }

        public static Result<tError, tResult> SelectMany<tError, tSource, tResult>(this Result<tError, tSource> source, Func<tSource, Result<tError, tResult>> selector)
        {
            return source.Bind(selector);
        }

        public static Result<tError, tResult> SelectMany<tError, tSource, tCollection, tResult>(
            this Result<tError, tSource> source,
            Func<tSource, Result<tError, tCollection>> collectionSelector,
            Func<tSource, tCollection, tResult> resultSelector)
        {
            return source.Bind(src =>
                collectionSelector(src)
                    .Map(col => resultSelector(src, col)));
        }
    }

}
