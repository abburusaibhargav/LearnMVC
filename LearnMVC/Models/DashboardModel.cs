using System;
using System.Collections.Generic;
using System.Linq;
using System.Web;

namespace LearnMVC.Models
{
    public class DashboardModel
    {
        public string loginuserrole { get; set; }
        public int TotalConsignmentTillDate { get; set; }
        public int TotalOffices { get; set; }
        public int TotalDeliveryOffices { get; set; }
        public int TotalnonDeliveryOffices { get; set; }
        public int TotalBranchOffices { get; set; }
        public int TotalSubBranchOffices { get; set; }
        public int TotalHeadOffices { get; set; }
        public string TotalAnnualIncome { get; set; }
        public string TotalMaintenanceCost { get; set; }
        public DateTime CreatedDate { get; set; }
    }
}