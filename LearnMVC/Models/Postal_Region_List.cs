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
    
    public partial class Postal_Region_List
    {
        [System.Diagnostics.CodeAnalysis.SuppressMessage("Microsoft.Usage", "CA2214:DoNotCallOverridableMethodsInConstructors")]
        public Postal_Region_List()
        {
            this.Postal_Division_List = new HashSet<Postal_Division_List>();
        }
    
        public string RegionID { get; set; }
        public string CircleID { get; set; }
        public string RegionName { get; set; }
        public bool Active { get; set; }
        public string CreatedBy { get; set; }
        public Nullable<System.DateTime> CreatedDate { get; set; }
        public string ModifiedBy { get; set; }
        public Nullable<System.DateTime> ModifiedDate { get; set; }
    
        [System.Diagnostics.CodeAnalysis.SuppressMessage("Microsoft.Usage", "CA2227:CollectionPropertiesShouldBeReadOnly")]
        public virtual ICollection<Postal_Division_List> Postal_Division_List { get; set; }
        public virtual Postal_Circle_List Postal_Circle_List { get; set; }
    }
}
