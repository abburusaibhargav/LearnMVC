using System;
using System.Collections.Generic;
using System.Linq;
using System.Web;
using LearnMVC.Models;

namespace LearnMVC.Models
{
    public class SearchModel
    {
        public string UserID { get; set; }
        public DateTime Datefrom { get; set; }
        public DateTime DateTo { get; set; }
        public string ReportType { get; set; }
        public string AnnouncementClassification { get; set; }
        public string AuditRefID { get; set; }
    }
}
