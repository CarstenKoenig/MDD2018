using System;

namespace Lambda
{
    public abstract class Boolean
    {
        internal abstract T Apply<T>(T a, T b);

        public override string ToString()
        {
            return Apply("wahr", "falsch");
        }
    }

    public class True : Boolean
    {
        internal override T Apply<T>(T a, T b)
        {
            return a;
        }
    }

    public class False : Boolean
    {
        internal override T Apply<T>(T a, T b)
        {
            return b;
        }
    }


    public abstract class Nat
    {
        internal abstract T Apply<T>(Func<T, T> succ, T zero);

        public override string ToString()
        {
            return ToInt().ToString();
        }

        public int ToInt()
        {
            return Apply(n => n + 1, 0);
        }
    }

    public class Zero : Nat
    {
        internal override T Apply<T>(Func<T, T> succ, T zero)
        {
            return zero;
        }
    }

    public class Succ : Nat
    {
        private readonly Nat _prev;

        public Succ(Nat n)
        {
            _prev = n;
        }

        internal override T Apply<T>(Func<T, T> succ, T zero)
        {
            return succ(_prev.Apply(succ, zero));
        }
    }


    public static class Calculus
    {
        public static T LcIf<T>(Boolean a, T t, T f)
        {
            return a.Apply(t, f);
        }

        public static Boolean And(Boolean a, Boolean b)
        {
            return a.Apply(b, new False());
        }

        public static Nat Succ(Nat a)
        {
            return new Succ(a);
        }

        public static Nat FromInt(int i)
        {
            if (i <= 0) return new Zero();
            return Succ(FromInt(i - 1));
        }

        public static Nat Plus(Nat a, Nat b)
        {
            return a.Apply(Succ, b);
        }
    }

    class Program
    {
        static void Main(string[] args)
        {
            var t = new True();
            var f = new False();

            CheckAnd(f, f);
            CheckAnd(t, f);
            CheckAnd(f, t);
            CheckAnd(t, t);

            var sieben = Calculus.Plus(Calculus.FromInt(3), Calculus.FromInt(4));
            System.Console.WriteLine("3 + 4 = {0}", sieben);

        }

        static void CheckAnd(Boolean a, Boolean b)
        {
            System.Console.WriteLine("{0} and {1} = {2}", a, b, Calculus.And(a, b));
        }
    }


}
