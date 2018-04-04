using System;

namespace ResultDemo.PatternMatch
{
    public abstract class Result<tError, tResult>
    {
        internal Result()
        {

        }

        public tOut Match<tOut>(Func<tError, tOut> fromFail, Func<tResult, tOut> fromSuccess)
        {
            switch (this)
            {
                case FailureCase f:
                    return fromFail(f.Error);
                case SuccessCase s:
                    return fromSuccess(s.Result);
                default:
                    throw new NotSupportedException();
            }
        }

        public static Result<tError, tResult> Failure(tError error)
        {
            return new FailureCase(error);
        }

        public static Result<tError, tResult> Success(tResult result)
        {
            return new SuccessCase(result);
        }


        public class FailureCase : Result<tError, tResult>
        {
            internal FailureCase(tError failure)
            {
                Error = failure;
            }

            public tError Error { get; }
        }


        public class SuccessCase : Result<tError, tResult>
        {
            internal SuccessCase(tResult result)
            {
                Result = result;
            }

            public tResult Result { get; }
        }
    }
}
