using System;
using System.Collections.Generic;
using System.Linq;
using System.Web;

namespace LearnMVC.Models
{
    public class MailSystemModel
    {
        public string MailRefID { get; set; }
        public string Receivermailid { get; set; }
        public string MailBody { get; set; }
        public string Status { get; set; }
    }
}