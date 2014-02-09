using CodeOwls.MongoProvider.PathNodes;

namespace CodeOwls.MongoProvider.ItemOperations
{
    interface INewItem
    {
        object NewItemParameters { get; }
        PathNode NewItem(string path, string type, object value);
    }
}
