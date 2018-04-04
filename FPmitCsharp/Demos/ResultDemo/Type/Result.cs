using System;

namespace ResultDemo.Type
{
    public class Result<tError, tResult>
    {
        private readonly bool _isError;
        private readonly tError _error;
        private readonly tResult _result;

        private Result(tError error)
        {
            _isError = true;
            _error = error;
        }

        private Result(tResult result)
        {
            _isError = false;
            _result = result;
        }

        /// <summary>
        /// Fold / Catamorphism for the Result
        /// </summary>
        /// <remarks>
        /// Forces the user to consider both the fail and the success case
        /// </remarks>
        public tOut Match<tOut>(Func<tError, tOut> fromFail, Func<tResult, tOut> fromSuccess)
        {
            return _isError ? fromFail(_error) : fromSuccess(_result);
        }


        public static Result<tError, tResult> Failure(tError error)
        {
            return new Result<tError, tResult>(error);
        }


        public static Result<tError, tResult> Success(tResult result)
        {
            return new Result<tError, tResult>(result);
        }
    }
}