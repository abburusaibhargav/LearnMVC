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
    
    public partial class Menu
    {
        public string MenuID { get; set; }
        public string MenuName { get; set; }
        public string DisplayName { get; set; }
        public string Controller { get; set; }
        public string ActionMethod { get; set; }
        public Nullable<int> SortOrder { get; set; }
        public Nullable<bool> Active { get; set; }
        public Nullable<System.DateTime> CreatedDate { get; set; }
        public string CreatedBy { get; set; }
    }
}
