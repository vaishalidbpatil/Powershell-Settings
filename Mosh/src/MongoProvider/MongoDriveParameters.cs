using System;
using System.Collections.Generic;
using System.Linq;
using System.Management.Automation;
using System.Text;

namespace CodeOwls.MongoProvider
{
    public class MongoDriveParameters
    {
        [Parameter(Mandatory=true, ParameterSetName="connectionStringSet")]
        [Alias( "cxn" )]
        public string ConnectionString { get; set; }

        [Parameter(Mandatory = true, ParameterSetName = "optionSet")]
        public string[] Servers { get; set; }

        [Parameter(ParameterSetName = "optionSet")]
        public int MaximumPoolSize { get; set; }

        [Parameter(ParameterSetName = "optionSet")]
        public int MinimumPoolSize { get; set; }

        [Parameter(ParameterSetName = "optionSet")]
        [Alias("Lifetime")]
        public TimeSpan ConnectionLifetime{ get; set; }

        [Parameter(ParameterSetName = "optionSet")]
        [Alias("Timeout")]
        public TimeSpan ConnectionTimeout { get; set; }

        [Parameter(ParameterSetName = "optionSet")]
        public SwitchParameter Pooled { get; set; }

        [Parameter]
        public SwitchParameter Verify{ get; set; }        
    }
}
