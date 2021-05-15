using System;
using System.Collections.Generic;
using System.Configuration;
using System.Data;
using System.Data.SqlClient;
using System.IO;
using System.Linq;
using System.Web;
using System.Web.Mvc;
using System.Web.Routing;
using LearnMVC.Models;

namespace LearnMVC.Controllers
{
    public class DashboardController : Controller
    {
        AppDataConnectionEntity connectionEntity = new AppDataConnectionEntity();
        // GET: Dashboard
        public ActionResult Index()
        {
            string UserID = Session["UserID"].ToString();
            string Usertype;
            connectionEntity.LoadDashboardData(UserID);

            if(UserID == "UR-AVS-M-937216")
            {
                 Usertype = "SuperUser";
            }
            else
            {
                 Usertype = "StandardUser";
            }

            var dashboardResults = connectionEntity.GetDashBoardData(Usertype, UserID).ToList();
            if(dashboardResults != null)
            {
                ViewBag.DashBoardResults = dashboardResults;
            }
            else
            {
                ViewBag.NoResults = "No Data Found.";
            }
            return View();
        }
    }
}