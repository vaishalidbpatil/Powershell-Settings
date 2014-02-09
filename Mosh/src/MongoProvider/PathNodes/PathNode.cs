using System;
using System.Collections;
using System.Collections.Generic;
using System.Linq;
using System.Management.Automation;
using CodeOwls.MongoProvider.ItemOperations;
using MongoDB;

namespace CodeOwls.MongoProvider.PathNodes
{
    abstract class PathNode : IGetItem
    {
        private readonly Context _context;

        private readonly StringComparer _nodeNameComparer;

        protected internal PathNode(Context context)
        {
            _context = context;
            _nodeNameComparer = StringComparer.InvariantCulture;
        }

        protected internal PathNode( Context context, StringComparer nodeNameComparer )
        {
            _context = context;
            _nodeNameComparer = nodeNameComparer;
        }

        public virtual PathNode Resolve(string nodeName)
        {
            var children = GetNodeChildren();
            return (from child in children
                    let childName = child.Name
                    where _nodeNameComparer.Equals(nodeName, childName)
                    select child).FirstOrDefault();
        }

        public virtual object GetItemParameters
        {
            get { return null; }
        }

        public virtual object GetChildItemsParameters
        {
            get { return null; }
        }

        public abstract PathNodeValue GetNodeValue();

        public abstract IEnumerable<PathNode> GetNodeChildren();
        public virtual IEnumerable<PathNode> GetNodeChildren( string filter )
        {
            throw new NotSupportedException( "this node does not support the use of native filters");
        }

        public abstract string Path { get; }
        public abstract string Name { get; }

        public Context Context
        {
            get { return _context; }
        }

        protected void RemoveChildItems()
        {
            foreach( PathNode node in GetNodeChildren() )
            {
                var ri = node as IRemoveItem;
                if( null == ri )
                {
                    continue;                    
                }
                ri.RemoveItem( node.Name, true );
            }
        }

        protected PSObject DocumentToPSObject<T>( Document document ) where T : new()
        {
            var pso = PSObject.AsPSObject( new T() );
            foreach( var key in document.Keys )
            {
                object value = document[key];
                if( value is Document )
                {
                    value = DocumentToPSObject<T>(value as Document);
                }

                pso.Properties.Add( new PSNoteProperty( key, value ));
            }
            return pso;
        }

        protected PSObject DocumentToPSObject(Document document)
        {
            return DocumentToPSObject<PSDocumentObject>(document);
        }

        protected Document ToDocument(object value)
        {
            if( value is Hashtable )
            {
                return HashtableToDocument(value as Hashtable);
            }
            return PSObjectToDocument(value);                       
        }

        protected Document PSObjectToDocument(object value)
        {
            var pso = value as PSObject ?? PSObject.AsPSObject(value);

            Document doc = pso.BaseObject as Document;
            if (null != doc)
            {
                return doc;
            }

            doc = new Document();
            int position = 0;

            var collectionTypes = new[] {typeof (Array), typeof (Hashtable), typeof(IList)};

            var props = pso.Properties;
            var psProps = from p in props
                             where p.Name.StartsWith("PS")
                             select p;
            var valueProps = from p in props
                             where null != p.Value && 
                                ( p.Value.GetType().IsValueType || p.Value.GetType() == typeof(string) || p.Name == "_id" ) &&
                                !( from ps in psProps where ps.Name == p.Name select ps ).Any()
                             select p;
            var collProps = from p in props
                            where null != p.Value &&
                               ( collectionTypes.Contains( p.Value.GetType() ) ||
                               p.Value.GetType().IsArray)
                            select p;

            var refProps = from p in props
                           where null != p.Value &&
                                 !p.Value.GetType().IsValueType &&
                                 !(from ps in psProps where ps.Name == p.Name select ps).Union(
                                          from ps in valueProps where ps.Name == p.Name select ps
                                      ).Union(
                                          from ps in collProps where ps.Name == p.Name select ps
                                      ).Any()
                             select p;

            psProps.ToList().ForEach(p => doc.Insert(p.Name, p.Value.ToString(), position++));
            valueProps.ToList().ForEach( p=>doc.Insert( p.Name,p.Value, position++));
            collProps.ToList().ForEach(p => doc.Insert(p.Name, CollectionToDocumentField(p.Value), position++));
            refProps.ToList().ForEach( p=> doc.Insert( p.Name, PSObjectToDocument(p.Value), position++));
            return doc;
        }

        private ArrayList CollectionToDocumentField(object value)
        {
            IEnumerable e = value as IEnumerable;


            var ra = new ArrayList();

            foreach( var i in e )
            {
                ra.Add(i);

            }

            return ra;
        }

        protected Document HashtableToDocument(Hashtable find)
        {
            IDictionary<string,object> map = new Dictionary<string, object>();
            foreach( var key in find.Keys )
            {                               
                map.Add( key.ToString(), find[key]);
            }

            Document document = new Document( map );
            return document;
        }

        protected Document StringListToIndexDocument(IEnumerable<string> fields)
        {
            var document = new Document();
            fields.ToList().ForEach(
                s=> document.Add( s, 1 )
                );
            return document;
        }
    }
}