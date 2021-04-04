using System;
using System.Collections.Generic;
using System.Linq;
using System.Web;

namespace LearnMVC.Models.Consignment
{
    public class BookConsignment
    {
        public string BookingID { get; set; }
    }
    
    public class CreateDomesticBooking
    {
        public string BookingID { get; set; }
        public string ConsigmentServerBookingID { get; set; }
        public string ConsigneeName { get; set; }
        public string ConsignerName { get; set; }
        public string ConsignmentType { get; set; }
        public int ConsigneePincode { get; set; }
        public int ConsignerPincode { get; set; }
        public string ConsigneeAddress { get; set; }
        public string ConsignerAddress { get; set; }
        public string ConsigneeStateID { get; set; }
        public string ConsigneeStateName { get; set; }
        public string ConsignerStateID { get; set; }
        public string ConsignerStateName { get; set; }
        public string RegionID { get; set; }
        public string RegionName { get; set; }
        public string OfficeTypeID { get; set; }
        public string OfficeTypeName { get; set; }
        public string DeliveryID { get; set; }
        public string DeliveryTypeName { get; set; }
        public string OfficeID { get; set; }
        public string OfficeName { get; set; }
        public string CircleID { get; set; }
        public string CircleName { get; set; }
        public string DivisionID { get; set; }
        public string DivisionName { get; set; }
        public string DistrictID { get; set; }
        public string DistrictName { get; set; }
    }
}