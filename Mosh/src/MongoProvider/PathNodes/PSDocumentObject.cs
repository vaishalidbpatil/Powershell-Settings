using System.Management.Automation;

namespace CodeOwls.MongoProvider.PathNodes
{
    /// <summary>
    /// This is an empty type used to identify Mongo document objects for formatting
    /// </summary>
    public class PSDocumentObject 
    {
        public string ItemType { get { return "Document"; } }
    }

    /// <summary>
    /// This is an empty type used to identify Mongo document objects for formatting
    /// </summary>
    public class PSDatabaseUserDocumentObject
    {
        public string ItemType { get { return "User"; } }
    }

    /// <summary>
    /// This is an empty type used to identify Mongo document objects for formatting
    /// </summary>
    public class PSCollectionIndexDocumentObject
    {
        public string ItemType { get { return "Index"; } }
    }
}