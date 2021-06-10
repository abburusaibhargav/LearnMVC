using System;
using System.Collections.Generic;
using System.ComponentModel.DataAnnotations;
using System.Linq;
using System.Web;

namespace LearnMVC.Models
{
    public class PaymentModel
    {
        public string transid { get; set; }
        public string transtatus { get; set; }
        public string itemamount { get; set; }
        public string iteminfo { get; set; }
        public string itemid { get; set; }
        public string fname { get; set; }        
        public string email { get; set; }
    }
}