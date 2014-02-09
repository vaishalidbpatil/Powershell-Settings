using System;
using System.Runtime.InteropServices;
using System.Security;
using System.Text;
using MongoDB;

namespace CodeOwls.MongoProvider
{
    class Context : IDisposable
    {
        public Context( MongoProvider provider, object dynamicParameters, Mongo mongo )
        {
            Provider = provider;
            DynamicParameters = dynamicParameters;
            Mongo = mongo;
        }
        public MongoProvider Provider { get; private set; }
        public object DynamicParameters { get; private set; }
        public Mongo Mongo { get; private set; }

        #region Implementation of IDisposable

        public void Dispose()
        {
            if( null != Mongo )
            {
                Mongo.Disconnect();
                Mongo.Dispose();
                Mongo = null;
            }
        }

        #endregion
    }

    static class Paths
    {
        internal static string Create( Context context, IMongoCollection collection, string documentName )
        {
            var driveName = context.Provider.Drive.Name;
            var databaseName = collection.DatabaseName;
            var collectionName = collection.Name;

            return Create(driveName, databaseName, collectionName, documentName);
        }

        internal static string Create(Context context, IMongoCollection collection)
        {
            var driveName = context.Provider.Drive.Name;
            var databaseName = collection.DatabaseName;
            var collectionName = collection.Name;

            return Create(driveName, databaseName, collectionName, null);
        }

        internal static string Create(Context context, IMongoDatabase database)
        {
            var driveName = context.Provider.Drive.Name;

            return Create(driveName, database.Name, null, null);
        }


        internal static string Create(Context context)
        {
            var driveName = context.Provider.Drive.Name;
            return Create(driveName, null, null, null);
        }

        static string Create(string driveName, string databaseName, string collectionName, string documentName)
        {
            StringBuilder builder = new StringBuilder();
            builder.AppendFormat("{0}:/", driveName);
            if (null != databaseName)
            {
                builder.AppendFormat("/{0}", databaseName);
            }
            if( null != collectionName )
            {
                builder.AppendFormat("/{0}", collectionName);
            }
            if (null != documentName)
            {
                builder.AppendFormat("/{0}", documentName);
            }
            return builder.ToString();
        }

        internal static string Create(Context context, IMongoDatabase database, string userName)
        {
            return Create(context, database, userName);
        }
    }

    public static class SecureStringExtensions
    {
        public static string ToUnsecureString(this SecureString securePassword)
        {
            if (securePassword == null)
                throw new ArgumentNullException("securePassword");

            IntPtr unmanagedString = IntPtr.Zero;
            try
            {
                unmanagedString = Marshal.SecureStringToGlobalAllocUnicode(securePassword);
                return Marshal.PtrToStringUni(unmanagedString);
            }
            finally
            {
                Marshal.ZeroFreeGlobalAllocUnicode(unmanagedString);
            }
        }

    }
}
