using System.Collections;
using System.Management.Automation;

namespace CodeOwls.MongoProvider.Parameters
{
    class NativeFindItemParameters : AsRawDocumentParams
    {
        [Parameter]
        [Alias("Where", "Selector")]
        public Hashtable Find { get; set; }

        [Parameter]
        [Alias("Max", "Take")]
        public int Limit { get; set; }

        [Parameter]
        public int Skip { get; set; }

        internal override bool IsAnyParameterSpecified
        {
            get
            {
                return base.IsAnyParameterSpecified ||
                       null != Find ||
                       0 != Limit ||
                       0 != Skip;
            }
        }
    }
}