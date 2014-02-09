using CodeOwls.MongoProvider.PathNodes;

namespace CodeOwls.MongoProvider.ItemOperations
{
    interface IGetItem
    {
        object GetItemParameters { get; }
        PathNodeValue GetNodeValue();
    }
}