namespace CodeOwls.MongoProvider.ItemOperations
{
    interface ISetItem
    {
        object SetItemParameters { get; }
        void SetItem(string path, object value);
    }
}