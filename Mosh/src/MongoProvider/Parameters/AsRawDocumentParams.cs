using System;
using System.Collections.Generic;
using System.Linq;
using System.Management.Automation;
using System.Text;

namespace CodeOwls.MongoProvider.Parameters
{
    class AsRawDocumentParams : DynamicParamsBase
    {
        [Parameter]
        [Alias("Raw")]
        public SwitchParameter AsDocument { get; set; }

        [Parameter]
        public string[] Fields { get; set; }

        internal override bool IsAnyParameterSpecified
        {
            get
            {
                return base.IsAnyParameterSpecified ||
                       AsDocument.IsPresent ||
                       null != Fields;
            }
        }

    }

}
