using System;
using System.Collections;
using System.Collections.Generic;
using System.Linq;
using System.Management.Automation;
using CodeOwls.MongoProvider.ItemOperations;
using CodeOwls.MongoProvider.Parameters;
using MongoDB;

namespace CodeOwls.MongoProvider.PathNodes
{
    class DocumentNode : PathNode, IRemoveItem, ISetItem
    {

        private readonly IMongoCollection _collection;
        private readonly Document _doc;

        public DocumentNode(Context context, IMongoCollection collection, Document doc) : base(context)
        {
            _collection = collection;
            _doc = doc;
        }

        #region Overrides of Node

        public override string Path
        {
            get { return Paths.Create(Context, _collection, Name); }
        }

        public override object GetItemParameters
        {
            get
            {
                return new AsRawDocumentParams();
            }
        }

        public override PathNodeValue GetNodeValue()
        {
            var param = Context.DynamicParameters as AsRawDocumentParams;
            object value = _doc;
            if( null == param || ! param.AsDocument.IsPresent )
            {
                value = DocumentToPSObject(_doc);
            }
            return new PathNodeValue( value, Name, false );
        }

        public override IEnumerable<PathNode> GetNodeChildren()
        {
            return null;
        }

        public override string Name
        {
            get
            {
                if( _doc.Keys.Contains( Constants.NameField) )
                {
                    return _doc[Constants.NameField].ToString();
                }

                return _doc.Id.ToString();
            }
        }

        #endregion

        #region Implementation of IRemoveItem

        public object RemoveItemParameters
        {
            get { return null; }
        }

        public void RemoveItem(string path, bool recurse)
        {
            var desc = String.Format("This will remove the document '{0}' from collection '{1}' in database '{2}'.", Name, _collection.Name, _collection.DatabaseName);
            var warn = String.Format("Do you want to remove document '{0}' from collection '{1}' in database '{2}'?", Name, _collection.Name, _collection.DatabaseName);
            if (Context.Provider.ShouldProcess(desc, warn, "Removing " + Name))
            {
                if (Context.Provider.Force || Context.Provider.ShouldContinue(warn, "Confirm remove of document " + Name))
                {
                    _collection.Remove(_doc);
                }
            }
        }

        #endregion

        #region Implementation of ISetItem

        public object SetItemParameters
        {
            get { return new SetItemDocumentParameters(); }
        }

        public void SetItem(string path, object value)
        {
            var doc = ToDocument(value);
            var p = Context.DynamicParameters as SetItemDocumentParameters;
            if( null != p && p.IsAnyParameterSpecified )
            {                             
                var selector = new Document( Constants.NameField, path );
                doc = CreateUpdateDocument( p );                         

                _collection.Update( selector, doc );
                
                return;
            }
            _collection.Save( doc );
        }

        #endregion

        Document CreateUpdateDocument( SetItemDocumentParameters p )
        {
            var doc = new Document();

            var map = new Dictionary<string, object>
                          {
                              {"$set", p.Set},
                              {"$inc", p.Inc},
                              {"$pop", p.Pop},
                              {"$pull", p.Pull},
                              {"$pullAll", p.PullAll},
                              {"$push", p.Push},
                              {"$pushAll", p.PushAll},
                              {"$rename", p.Rename},
                              {"$unset", p.Unset},
                              {"$bit", p.Bit}
                          };

            map.ToList().ForEach( pair=> AppendUpdateAtomDocument(doc, pair.Key, pair.Value ) );

            return doc;
        }
        void AppendUpdateAtomDocument( Document target, string key, object value )
        {
            if( null == value )
            {
                return;
            }

            var atom = ToDocument(value);
            target.Add( key, atom );
        }
    }
}