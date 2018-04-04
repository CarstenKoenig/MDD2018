using System;

namespace ResultDemo.Inheritance
{
    public abstract class Result<tError, tResult>
    {
        internal Result()
        {

        }

        public abstract tOut Match<tOut>(Func<tError, tOut> fromFail, Func<tResult, tOut> fromSuccess);


        public static Result<tError, tResult> Failure(tError error)
        {
            return new Failure<tError, tResult>(error);
        }

        public static Result<tError, tResult> Success(tResult result)
        {
            return new Success<tError, tResult>(result);
        }

    }

    class Failure<tError, tResult> : Result<tError, tResult>
    {
        private readonly tError _failure;

        internal Failure(tError failure)
        {
            _failure = failure;
        }

        public override tOut Match<tOut>(Func<tError, tOut> fromFail, Func<tResult, tOut> fromSuccess)
        {
            return fromFail(_failure);
        }
    }

    class Success<tError, tResult> : Result<tError, tResult>
    {
        private readonly tResult _result;

        internal Success(tResult result)
        {
            _result = result;
        }


        public override tOut Match<tOut>(Func<tError, tOut> fromFail, Func<tResult, tOut> fromSuccess)
        {
            return fromSuccess(_result);
        }
    }
}