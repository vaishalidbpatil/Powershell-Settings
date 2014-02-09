namespace CodeOwls.MongoProvider.ItemOperations
{
    interface IRemoveItem
    {
        object RemoveItemParameters { get; }
        void RemoveItem(string path, bool recurse);
    }
}