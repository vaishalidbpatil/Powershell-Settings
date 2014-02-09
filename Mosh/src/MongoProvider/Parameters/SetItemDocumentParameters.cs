using System;
using System.Collections.Generic;
using System.Linq;
using System.Management.Automation;
using System.Text;

namespace CodeOwls.MongoProvider.Parameters
{
    class SetItemDocumentParameters : DynamicParamsBase
    {
        [Parameter]
        [Alias("Update")]
        public object Set { get; set; }
        [Parameter]
        public object Inc { get; set; }
        [Parameter]
        public object Unset { get; set; }
        [Parameter]
        public object Push { get; set; }
        [Parameter]
        public object PushAll { get; set; }
        [Parameter]
        public object AddToSet { get; set; }
        [Parameter]
        public object Pop { get; set; }
        [Parameter]
        public object Pull { get; set; }
        [Parameter]
        public object PullAll { get; set; }
        [Parameter]
        public object Rename { get; set; }
        [Parameter]
        public object Bit { get; set; }

        internal override bool IsAnyParameterSpecified
        {
            get
            {
                return base.IsAnyParameterSpecified ||
                       null != 
                       ( Set ??
                       Inc??
                       Unset ??
                       Push ??
                       PushAll ??
                       AddToSet ??
                       Pop ??
                       Pull ??
                       PullAll ??
                       Rename ??
                       Bit );

            }
        }
    }
}
