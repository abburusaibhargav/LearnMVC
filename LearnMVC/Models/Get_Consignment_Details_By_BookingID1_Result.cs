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
    using System.ComponentModel.DataAnnotations;

    public partial class Get_Consignment_Details_By_BookingID1_Result
    {
        [Key]
        public string BookingID { get; set; }
        public string ConsigneeName { get; set; }
        public string ConsignerName { get; set; }
        public string StateName { get; set; }
        public string CircleName { get; set; }
        public string RegionName { get; set; }
        public string DivisionName { get; set; }
        public string DistrictName { get; set; }
        public string OfficeName { get; set; }
        public int Pincode { get; set; }
    }
}
