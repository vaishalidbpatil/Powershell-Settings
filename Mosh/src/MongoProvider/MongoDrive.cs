using System;
using System.Collections.Generic;
using System.Linq;
using System.Management.Automation;
using System.Text;
using System.Text.RegularExpressions;
using System.Threading;
using CodeOwls.MongoProvider.PathNodes;
using MongoDB;
using MongoDB.Configuration;
using MongoDB.Serialization;

namespace CodeOwls.MongoProvider
{
    public class MongoDrive : PSDriveInfo
    {
        private bool _disposed;
        private readonly MongoDriveParameters _driveParameters;

        internal MongoDrive(MongoDriveParameters driveParameters, PSDriveInfo drive) : base( drive )
        {
            _driveParameters = driveParameters;
        }

        internal PathNode Resolve(Context context, string path)
        {            
            if( _disposed)
            {
                throw new ObjectDisposedException( "MongoDrive" );
            }

            Regex re = new Regex(@"^[-_a-z0-9:]+:/?");
            path = path.Replace('\\', '/');
            path = re.Replace(path, "");

            PathNode factory = new RootNode(context);

            var nodeMonikers = path.Split(new char[] {'/'}, StringSplitOptions.RemoveEmptyEntries);

            foreach (var nodeMoniker in nodeMonikers)
            {
                factory = factory.Resolve(nodeMoniker);
                if (null == factory)
                {
                    break;
                }
            }

            return factory;
        }
        
        internal Mongo Connect( MongoProvider provider )
        {
            var cxn =  BuildMongoConnectionString(_driveParameters, provider.Credential);
            
            var mongo = new Mongo( cxn );
            mongo.Connect();
            return mongo;           
        }

        private string BuildMongoConnectionString(MongoDriveParameters driveParameters, PSCredential credential)
        {
            string cxn = BuildMongoConnectionString(driveParameters);

            if( null != credential &&
                null != credential.UserName &&
                null != credential.Password )
            {
                MongoConnectionStringBuilder builder = new MongoConnectionStringBuilder( cxn );
                builder.Username = credential.UserName;
                builder.Password = credential.Password.ToUnsecureString();
                cxn = builder.ToString();
            }

            return cxn;
        }

        private string BuildMongoConnectionString(MongoDriveParameters driveParameters)
        {
            if( null != driveParameters.ConnectionString )
            {
                return driveParameters.ConnectionString;
            }

            MongoConnectionStringBuilder builder = new MongoConnectionStringBuilder();
            driveParameters.Servers.ToList().ForEach( builder.AddServer );
            builder.Pooled = driveParameters.Pooled.IsPresent;
            builder.ConnectionLifetime = driveParameters.ConnectionLifetime;
            builder.ConnectionTimeout = driveParameters.ConnectionTimeout;
            builder.MaximumPoolSize = driveParameters.MaximumPoolSize;
            builder.MinimumPoolSize = driveParameters.MinimumPoolSize;
            
            return builder.ToString();
        }
    }
}
