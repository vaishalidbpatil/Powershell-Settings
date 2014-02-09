namespace CodeOwls.MongoProvider.PathNodes
{
    class PathNodeValue
    {
        public PathNodeValue( object value, string name, bool isContainer )
        {
            Value = value;
            Name = name;
            IsContainer = isContainer;
        }

        public object Value { get; private set; }
        public string Name { get; private set; }
        public bool IsContainer { get; private set; }
    }
}