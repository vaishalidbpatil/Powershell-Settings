using System;
using System.Collections.Generic;
using System.Linq;
using System.Text;
using CodeOwls.MongoProvider.ItemOperations;
using MongoDB;

namespace CodeOwls.MongoProvider.PathNodes
{
    class CollectionIndexNode : PathNode, IRemoveItem
    {
        private readonly IMongoCollection _collection;
        private readonly Document _indexDocument;

        public CollectionIndexNode(Context context, IMongoCollection collection, Document indexDocument ) : base(context)
        {
            if( ! indexDocument.ContainsKey("name"))
            {
                throw new ArgumentException( "the provided document does not contain index information");
            }
            _collection = collection;
            _indexDocument = indexDocument;
        }

        #region Overrides of PathNode

        public override PathNodeValue GetNodeValue()
        {
            var psobject = DocumentToPSObject<PSCollectionIndexDocumentObject>(_indexDocument);
            return new PathNodeValue( psobject, Name, false );
        }

        public override IEnumerable<PathNode> GetNodeChildren()
        {
            return null;
        }

        public override string Path
        {
            get { return Paths.Create(Context, _collection, Name); }
        }

        public override string Name
        {
            get { return _indexDocument["name"].ToString(); }
        }

        #endregion

        #region Implementation of IRemoveItem

        public object RemoveItemParameters
        {
            get { return null; }
        }

        public void RemoveItem(string path, bool recurse)
        {
            _collection.Metadata.DropIndex( Name );
        }

        #endregion
    }
}
