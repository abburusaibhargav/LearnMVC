//------------------------------------------------------------------------------
// <auto-generated>
//     This code was generated from a template.
//
//     Manual changes to this file may cause unexpected behavior in your application.
//     Manual changes to this file will be overwritten if the code is regenerated.
// </auto-generated>
//------------------------------------------------------------------------------

namespace LearnMVC.Models
{
    using System;
    using System.Collections.Generic;
    
    public partial class ConsignmentDetail
    {
        [System.Diagnostics.CodeAnalysis.SuppressMessage("Microsoft.Usage", "CA2214:DoNotCallOverridableMethodsInConstructors")]
        public ConsignmentDetail()
        {
            this.ConsigneeDetails = new HashSet<ConsigneeDetail>();
        }
    
        public string ConsignmentBookingRefID { get; set; }
        public string BookingID { get; set; }
        public string BookingOfficeID { get; set; }
        public string DestinationOfficeID { get; set; }
        public int DestinationPincode { get; set; }
        public string CreatedBy { get; set; }
        public Nullable<System.DateTime> CreatedOn { get; set; }
        public string ConsignmentStatus { get; set; }
        public Nullable<System.DateTime> StatusDate { get; set; }
        public string DestinationAddress { get; set; }
    
        [System.Diagnostics.CodeAnalysis.SuppressMessage("Microsoft.Usage", "CA2227:CollectionPropertiesShouldBeReadOnly")]
        public virtual ICollection<ConsigneeDetail> ConsigneeDetails { get; set; }
    }
}
