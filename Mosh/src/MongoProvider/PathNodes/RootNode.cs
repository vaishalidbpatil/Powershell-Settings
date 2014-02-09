using System;
using System.Collections.Generic;
using System.Linq;
using System.Text;
using CodeOwls.MongoProvider.ItemOperations;
using MongoDB;

namespace CodeOwls.MongoProvider.PathNodes
{
    class RootNode : PathNode, INewItem
    {
        private readonly Mongo _mongo;

        public RootNode(Context context) : base(context)
        {
            _mongo = context.Mongo;
        }

        #region Overrides of Node

        public override string Path
        {
            get { return Paths.Create(Context); }
        }

        public override PathNodeValue GetNodeValue()
        {
            return new PathNodeValue( _mongo, "", true );
        }

        public override IEnumerable<PathNode> GetNodeChildren()
        {
            return (from db in _mongo.GetDatabases()
                    select new DatabaseNode(Context, db)).Cast<PathNode>();
        }
        public override string Name
        {
            get { return ""; }
        }

        #endregion

        #region Implementation of INewItem

        public object NewItemParameters
        {
            get { return null; }
        }

        public PathNode NewItem(string path, string type, object value)
        {
            var db = _mongo.GetDatabase(path);
            var name = Guid.NewGuid().ToString("N");
            var c = db.GetCollection(name);
            var d = new Document();
            c.Insert( d );
            c.Remove( d );
            db.Metadata.DropCollection(name);

            return new DatabaseNode(Context, db);
        }

        #endregion
    }
}
