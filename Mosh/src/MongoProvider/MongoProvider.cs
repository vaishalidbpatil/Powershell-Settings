using System;
using System.Collections.Generic;
using System.Linq;
using System.Management.Automation;
using System.Management.Automation.Provider;
using CodeOwls.MongoProvider.ItemOperations;
using CodeOwls.MongoProvider.Parameters;
using CodeOwls.MongoProvider.PathNodes;

namespace CodeOwls.MongoProvider
{
    [CmdletProvider("Mongo", ProviderCapabilities.Filter|ProviderCapabilities.ShouldProcess|ProviderCapabilities.Credentials)]
    public class MongoProvider : NavigationCmdletProvider
    {
        protected override bool IsValidPath(string path)
        {
            return true;
        }

        protected override bool ItemExists(string path)
        {
            using (new CurrentContextSession(this))
            {
                return null != NodeFromPath(path);
            }
        }

        protected override bool HasChildItems(string path)
        {
            using (new CurrentContextSession(this))
            {
                var node = NodeFromPath(path);
                if( null == node )
                {
                    return false;
                }

                var children = node.GetNodeChildren();
                return null != children && children.Any();
            }
        }

        protected override bool IsItemContainer(string path)
        {
            using (new CurrentContextSession(this))
            {
                var node = NodeFromPath(path);
                if (null == node)
                {
                    return false;
                }

                return node.GetNodeValue().IsContainer;
            }
        }

        protected override void GetItem(string path)
        {
            using (new CurrentContextSession(this))
            {
                IEnumerable<PathNode> nodes = GetNodesFromPath(path);

                if (null == nodes)
                {
                    return;
                }

                WritePathNodes(nodes);
            }
        }

        protected override object GetItemDynamicParameters(string path)
        {
            using( new CurrentContextSession(this))
            {
                var node = NodeFromPath(path);
                if(null == node)
                {
                    return null;
                }

                return node.GetItemParameters;
            }
        }

        protected override void GetChildNames(string path, ReturnContainers returnContainers)
        {            
            using (new CurrentContextSession(this))
            {
                var children = GetChildNodesOfPath(path);
                if (String.IsNullOrEmpty(path))
                {
                    path = "/";
                }

                foreach (var child in children)
                {
                    WriteItemObject(child.Name, path, child.GetNodeChildren().Any());
                }
            }
        }

        protected override object GetChildItemsDynamicParameters(string path, bool recurse)
        {
            using( new CurrentContextSession( this ))
            {
                var node = NodeFromPath(path);
                if (null == node)
                {
                    return null;
                }

                return node.GetChildItemsParameters;
            }
        }

        protected override void GetChildItems(string path, bool recurse)
        {
            using (new CurrentContextSession(this))
            {
                IEnumerable<PathNode> children = GetChildNodesOfPath(path);

                WriteChildItem(path, recurse, children);
            }
        }

        private IEnumerable<PathNode> GetChildNodesOfPath(string path)
        {
            IEnumerable<PathNode> children = null;

            var node = NodeFromPath(path);
            if (null == node)
            {
                return children;
            }

            if (String.IsNullOrEmpty(Filter))
            {
                children = node.GetNodeChildren();
            }
            else
            {
                children = node.GetNodeChildren(Filter);
            }
            return children;
        }

        protected override void NewItem(string path, string itemTypeName, object newItemValue)
        {
            using (new CurrentContextSession(this))
            {
                bool isParent;
                var node = NodeFromPathOrParent(path, out isParent) as INewItem;
                if (null == node)
                {
                    return;
                }

                var child = ChildNameFromPath(path);
                var value = node.NewItem(child, itemTypeName, newItemValue);
                WritePathNode(path, value);
            }
        }

        protected override object NewItemDynamicParameters(string path, string itemTypeName, object newItemValue)
        {
            using (new CurrentContextSession(this))
            {
                bool isParent;
                var node = NodeFromPathOrParent(path, out isParent) as INewItem;
                if (null == node)
                {
                    return null;
                }
                return node.NewItemParameters;
            }
        }

        protected override void RemoveItem(string path, bool recurse)
        {
            using (new CurrentContextSession(this))
            {
                var node = NodeFromPath(path) as IRemoveItem;
                if (null == node)
                {
                    return;
                }

                var child = ChildNameFromPath(path);
                node.RemoveItem(child, recurse);
            }
        }

        protected override object RemoveItemDynamicParameters(string path, bool recurse)
        {
            using (new CurrentContextSession(this))
            {
                var node = NodeFromPath(path) as IRemoveItem;
                if (null == node)
                {
                    return null;
                }

                return node.RemoveItemParameters;
            }
        }

        protected override void SetItem(string path, object value)
        {
            using (new CurrentContextSession(this))
            {
                var node = NodeFromPath(path) as ISetItem;
                if (null == node)
                {
                    return;
                }

                var child = ChildNameFromPath(path);
                node.SetItem(child, value);
            }
        }

        protected override object SetItemDynamicParameters(string path, object value)
        {
            using (new CurrentContextSession(this))
            {
                var node = NodeFromPath(path) as ISetItem;
                if (null == node)
                {
                    return null;
                }

                return node.SetItemParameters;
            }
        }

        protected override System.Management.Automation.PSDriveInfo NewDrive(System.Management.Automation.PSDriveInfo drive)
        {
            var p = DynamicParameters as MongoDriveParameters;
            if( null == p )
            {
                throw new ArgumentException( "expected dynamic parameter of type " + typeof(MongoDriveParameters).FullName );
            }
            var mongoDrive = new MongoDrive(p, drive);

            if (p.Verify.IsPresent)
            {
                // verify connection when drive is created.
                using (var c = mongoDrive.Connect( this ))
                {
                }
            }

            return mongoDrive;

        }

        protected override object NewDriveDynamicParameters()
        {
            return new MongoDriveParameters();
        }

        internal MongoDrive Drive
        {
            get
            {
                var drive = PSDriveInfo as MongoDrive;

                if (null == drive)
                {
                    drive = this.ProviderInfo.Drives.FirstOrDefault() as MongoDrive;
                }

                return drive;
            }
        }

        private void WritePathNodes(IEnumerable<PathNode> nodes)
        {
            nodes.ToList().ForEach(node => WritePathNode(node.Path, node));
        }

        void WritePathNode(string path, PathNode node)
        {
            PathNodeValue value = null;
            value = node.GetNodeValue();

            if (null == value)
            {
                return;
            }

            WriteItemObject(value.Value, path, value.IsContainer);
        }

        private void WritePathNode(string path, PathNodeValue nodeValue)
        {
            if (null != nodeValue)
            {
                WriteItemObject(nodeValue.Value, path, nodeValue.IsContainer);
            }
        }

        void WriteChildItem(string path, bool recurse, IEnumerable<PathNode> children)
        {
            if (null == children || 0 == children.Count())
            {
                return;
            }

            children.ToList().ForEach(
                f =>
                {
                    var i = f.GetNodeValue();
                    if (null == i)
                    {
                        return;
                    }
                    var childPath = path + "/" + i.Name;
                    WritePathNode(childPath, f);
                    if (recurse)
                    {
                        var kids = f.GetNodeChildren();
                        WriteChildItem(path + "/" + i.Name, recurse, kids);
                    }
                });
        }

        IEnumerable<PathNode> GetNodesFromPath(string path)
        {
            var dynamicParams = DynamicParameters as NativeFindItemParameters;
            bool dynamicParamsSpecified = false;
            if( null != dynamicParams )
            {
                dynamicParamsSpecified = dynamicParams.IsAnyParameterSpecified;
            }

            // if we have a filter specified, it means we're looking for mulitple children
            //  so defer resolution to the child node locator and 
            //  select the first result returned
            if (dynamicParamsSpecified || !String.IsNullOrEmpty(Filter))
            {
                return GetChildNodesOfPath(path);
            }
                                  
            var node = NodeFromPath(path);
            if( null != node )
            {
                return new[]{node};
            }

            return null;
        }

        PathNode NodeFromPath( string path )
        {
            return Drive.Resolve(Context, path);
        }

        PathNode NodeFromPathOrParent(string path, out bool isParent)
        {
            isParent = false;
            var node = Drive.Resolve(Context, path);
            if( null != node )
            {
                return node;
            }

            path = SessionState.Path.ParseParent(path, Drive.Root);
            node = Drive.Resolve(Context, path);
            if( null != node )
            {
                isParent = true;
            }
            return node;
        }

        string ChildNameFromPath( string path )
        {
            return SessionState.Path.ParseChildName(path);
        }

        private Context _context;
        Context Context
        {
            get
            {
                if (null == _context)
                {
                    _context = new Context(this, DynamicParameters, Drive.Connect( this ));
                }
                return _context;
            }
        }

        class CurrentContextSession : IDisposable
        {
            private readonly MongoProvider _outer;

            public CurrentContextSession(MongoProvider outer)
            {
                _outer = outer;
            }

            public void Dispose()
            {
                if (null == _outer._context)
                {
                    return;
                }

                _outer._context.Dispose();
                _outer._context = null;
            }
        }

    }
}
