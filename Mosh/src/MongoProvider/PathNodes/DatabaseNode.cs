using System;
using System.Collections.Generic;
using System.Linq;
using System.Management.Automation;
using System.Text.RegularExpressions;
using CodeOwls.MongoProvider.ItemOperations;
using MongoDB;

namespace CodeOwls.MongoProvider.PathNodes
{
    class DatabaseNode: PathNode, INewItem, IRemoveItem
    {
        private readonly IMongoDatabase _db;

        public DatabaseNode(Context context, IMongoDatabase db) : base(context)
        {
            _db = db;
        }

        #region Overrides of PathNode

        public override string Path
        {
            get { return Paths.Create(Context, _db ); }
        }
        public override PathNodeValue GetNodeValue()
        {
            return new PathNodeValue( _db, Name, true );
        }

        public override IEnumerable<PathNode> GetNodeChildren()
        {
            var re = new Regex(@"^" + Regex.Escape(Name + "."), RegexOptions.IgnoreCase);
            var names = _db.GetCollectionNames();
            IEnumerable<PathNode> results = (
                                                from coll in names
                                                let c = re.Replace(coll, "")
                                                select (PathNode) new CollectionNode(Context, _db.GetCollection(c))
                                            ).Union(
                                                from user in _db.Metadata.ListUsers().Documents
                                                select (PathNode) new DatabaseUserNode(Context, _db, user)
                                            );

            return results;
        }

        public override string Name
        {
            get { return _db.Name; }
        }

        #endregion

        #region Implementation of IRemoveItem

        public object RemoveItemParameters
        {
            get { return null; }
        }

        public void RemoveItem(string path, bool recurse)
        {
            if (recurse)
            {
                RemoveChildItems();
            }

            var desc = String.Format("This will remove the database '{0}' from the mongo server.", _db.Name);
            var warn = String.Format("Do you want to remove database '{0}' from the mongo server?", _db.Name);
            if( Context.Provider.ShouldProcess( desc, warn, "Removing " + _db.Name ) )
            {               
                if (Context.Provider.Force || Context.Provider.ShouldContinue(warn, "Confirm remove of " + _db.Name))
                {
                    _db.Metadata.DropDatabase();                    
                }
            }
        }

        #endregion

        #region Implementation of INewItem

        public object NewItemParameters
        {
            get { return null; }
        }

        public PathNode NewItem(string path, string type, object value)
        {
            type = type ?? "collection";
            
            switch( type.ToLowerInvariant() )
            {
                case( "user"):

                    return NewUser(path, value);

                case("collection"):
            
                    return NewCollectionNode(path);

                default:

                    throw new NotSupportedException( "item type [" + type + "] is not supported at this location");
            }
        }

        private PathNode NewUser(string path, object value)
        {
            if (null == value)
            {
                if( null == Context.Provider.Host.UI )
                {
                    throw new InvalidOperationException( "no value was supplied for a password, and the current host does not support prompting for credentials");
                }

                var cred = Context.Provider.Host.UI.PromptForCredential(
                    "New Database User Credentials",
                    "Enter the password for the new database user",
                    path,
                    Name
                    );

                value = cred.Password.ToUnsecureString();
            }

            _db.Metadata.AddUser(path, value.ToString());
            var userDocument = _db.Metadata.FindUser(path);
            userDocument.Set(Constants.NameField, path);
            return new DatabaseUserNode(Context, _db, path);
        }

        PathNode NewCollectionNode( string path)
        {
            var c = _db.GetCollection(path);
            var d = new Document();
            c.Insert( d );
            c.Remove( d );
            return new CollectionNode(Context, c);
        }

        #endregion
    }
}