using System;
using System.Collections.Generic;
using System.Linq;
using System.Web;

namespace LearnMVC.Models
{
    public class SearchModel
    {
        public DateTime Datefrom { get; set; }
        public DateTime DateTo { get; set; }
        public string ReportType { get; set; }
        public string AuditRefID { get; set; }
    }
}