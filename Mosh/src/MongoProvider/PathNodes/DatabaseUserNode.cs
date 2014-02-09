using System;
using System.Collections.Generic;
using System.Linq;
using System.Net;
using System.Text;
using CodeOwls.MongoProvider.ItemOperations;
using MongoDB;

namespace CodeOwls.MongoProvider.PathNodes
{
    class DatabaseUserNode : PathNode, IRemoveItem
    {
        private readonly IMongoDatabase _database;
        private Document _userDocument;
        private readonly string _userName;

        public DatabaseUserNode(Context context, IMongoDatabase database, string userName) : base(context)
        {
            _database = database;
            _userName = userName;
        }

        public DatabaseUserNode(Context context, IMongoDatabase database, Document user )
            : base(context)
        {
            if( ! user.ContainsKey("user"))
            {
                throw new ArgumentException( "The document provided does not contain user information");
            }

            _database = database;
            _userDocument = user;
            _userName = user["user"].ToString();
        }

        #region Overrides of PathNode

        public override PathNodeValue GetNodeValue()
        {
            if( null == _userDocument )
            {
                _userDocument = _database.Metadata.FindUser(_userName);
            }

            var psobject = DocumentToPSObject<PSDatabaseUserDocumentObject>(_userDocument);
            return new PathNodeValue( psobject, Name, false );
        }

        public override IEnumerable<PathNode> GetNodeChildren()
        {
            return null;
        }

        public override string Path
        {
            get { return Paths.Create(Context, _database, _userName); }
        }

        public override string Name
        {
            get { return _userName; }
        }

        #endregion

        #region Implementation of IRemoveItem

        public object RemoveItemParameters
        {
            get { return null; }
        }

        public void RemoveItem(string path, bool recurse)
        {
            _database.Metadata.RemoveUser( path );
        }

        #endregion
    }
}
