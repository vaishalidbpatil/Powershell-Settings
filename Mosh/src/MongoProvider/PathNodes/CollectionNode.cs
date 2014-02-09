using System;
using System.Collections;
using System.Collections.Generic;
using System.Collections.ObjectModel;
using System.Linq;
using System.Management.Automation;
using CodeOwls.MongoProvider.ItemOperations;
using CodeOwls.MongoProvider.Parameters;
using MongoDB;

namespace CodeOwls.MongoProvider.PathNodes
{
    class CollectionNode : PathNode, INewItem, IRemoveItem
    {
        private readonly IMongoCollection _collection;
        private static bool NameField;

        public CollectionNode(Context context, IMongoCollection collection) : base(context)
        {
            _collection = collection;
        }

        #region Overrides of Node

        public override string Path
        {
            get { return Paths.Create(Context, _collection ); }
        }

        public override PathNode Resolve(string nodeName)
        {
            Document selector = new Document( Constants.NameField, nodeName );
            var cursor = GetCursorForCurrentContext(selector);
            if( null == cursor || null == cursor.Documents || ! cursor.Documents.Any() )
            {
                selector = new Document("_id", nodeName);
                cursor = GetCursorForCurrentContext(selector);
            }

            if (null == cursor || null == cursor.Documents || !cursor.Documents.Any())
            {
                return null;
            }

            var doc = cursor.Documents.FirstOrDefault();
            if( null == doc )
            {
                return null;
            }

            return new DocumentNode(Context, _collection, doc);
        }

        public override object GetChildItemsParameters
        {
            get { return new NativeFindItemParameters(); }
        }

        public override IEnumerable<PathNode> GetNodeChildren()
        {
            ICursor cursor = GetCursorForCurrentContext();

            var err = _collection.Database.GetLastError();
            return (from doc in cursor.Documents
                    select new DocumentNode(Context, _collection, doc)).ToList().Cast<PathNode>()
                    .Union(
                        (from index in _collection.Metadata.Indexes
                             select new CollectionIndexNode( Context, _collection, index.Value )).Cast<PathNode>()
                    );
        }

        private ICursor GetCursorForCurrentContext()
        {
            return GetCursorForCurrentContext(null);
        }

        private ICursor GetCursorForCurrentContext( Document selector )
        {
            var param = Context.DynamicParameters as NativeFindItemParameters;
            if (null == param)
            {
                var fieldParam = Context.DynamicParameters as AsRawDocumentParams;
                if (null != fieldParam)
                {
                    param = new NativeFindItemParameters()
                                {
                                    AsDocument = fieldParam.AsDocument,
                                    Fields = fieldParam.Fields,
                                    Find = null,
                                    Limit = 0,
                                    Skip = 0
                                };
                }
            }
            
            ICursor cursor = null;
            if (null != param )
            {
                param.Limit = Math.Max(0, param.Limit);
                param.Skip = Math.Max(0, param.Skip);
                if (null == selector && null != param.Find)
                {
                    selector = HashtableToDocument(param.Find);                    
                }

                Document fields = null;
                if( null != param.Fields )
                {
                    NameField = ! param.Fields.Contains(Constants.NameField);
                    if( NameField)
                    {
                        var ra = new string[param.Fields.Length];
                        param.Fields.CopyTo( ra, 1 );
                        param.Fields[0] = Constants.NameField;
                    }

                    fields = StringListToIndexDocument(param.Fields);
                }

                cursor = _collection.Find(selector, param.Limit, param.Skip, fields);
            }
            else if( null != selector )
            {
                cursor = _collection.Find(selector);
            }
            else
            {
                cursor = _collection.FindAll();
            }

            return cursor;
        }

        public override IEnumerable<PathNode> GetNodeChildren( string filter )
        {            
            var cursor = _collection.Find( filter );
            return (from doc in cursor.Documents
                    select new DocumentNode(Context, _collection, doc)).ToList().Cast<PathNode>();
        }

        public override PathNodeValue GetNodeValue()
        {
            return new PathNodeValue( _collection, Name, true );
        }

        public override string Name
        {
            get { return _collection.Name; }
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

            var desc = String.Format("This will remove the collection '{0}' from database '{1}'.", _collection.Name, _collection.DatabaseName);
            var warn = String.Format("Do you want to remove collection '{0}' from database '{1}'?", _collection.Name, _collection.DatabaseName);
            if (Context.Provider.ShouldProcess(desc, warn, "Removing " + _collection.Name))
            {
                if (Context.Provider.Force || Context.Provider.ShouldContinue(warn, "Confirm remove of " + _collection.Name))
                {
                    _collection.Database.Metadata.DropCollection(_collection.Name);
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
            type = type ?? "document";
            switch (type.ToLowerInvariant())
            {
                case ("document"):
                    return CreateNewDocument(path, value);
                case ("index"):
                    return CreateNewIndex(path, value);
                default:
                    throw new NotSupportedException("item type [" + type + "] is not supported at this location");
            }
        }

        PathNode CreateNewDocument(string path, object value)
        {
            Document document = ToDocument(value);

            if( path != Name )
            {
                document[Constants.NameField] = path;    
            }
            else if (document.ContainsKey(Constants.NameField) )
            {
                document[Constants.NameField] = document[Constants.NameField];
            }
            else if (document.ContainsKey(Constants.NameFieldForNewItems))
            {
                document[Constants.NameField] = document[Constants.NameFieldForNewItems];
            }

            _collection.Insert( document );
            return new DocumentNode(Context, _collection, document);
        }

        PathNode CreateNewIndex(string path, object value)
        {
            Document document = ToDocument(value);
            document[Constants.NameField] = path;

            _collection.Metadata.CreateIndex( path, document, true);
            return new CollectionIndexNode(Context, _collection, _collection.Metadata.Indexes[ path ]);
        }

        #endregion       
    }

}