using System;
using System.Collections.Generic;
using System.Linq;
using System.Web;
using System.Text;
using System.ComponentModel.DataAnnotations;
using System.Threading.Tasks;

namespace LearnMVC.Models
{
    public class ResultModel
    {
    }

    public class AutoGenDatesResult
    {
        public int Date { get; set; }
        public string Month { get; set; }
        public string Year { get; set; }
        public DateTime Completedate { get; set; }
        public string Day { get; set; }
        public int Week { get; set; }
        public string PubHol { get; set; }
        public string Weekend { get; set; }
        public string SalProc { get; set; }
    }
}