namespace CodeOwls.MongoProvider.Parameters
{
    abstract class DynamicParamsBase
    {
        internal virtual bool IsAnyParameterSpecified
        {
            get { return false; }
        }

    }
}