using LearnMVC.Models;
using Rotativa;
using System.Collections.Generic;
using System.Linq;
using System.Web.Mvc;

namespace LearnMVC.Controllers
{
    public class GeneratePDFController : Controller
    {
        AppDataConnectionEntity connectionEntity = new AppDataConnectionEntity();
        public ActionResult PDF_AllUserList()
        {
            var report = new ActionAsPdf("Result_AllUserList", null);
            return report;
        }

        public List<Get_User_List_Result> Result_AllUserList()
        {
            var results = connectionEntity.Get_User_List(Session["UserID"].ToString()).ToList();
            return results;
        }
    }
}