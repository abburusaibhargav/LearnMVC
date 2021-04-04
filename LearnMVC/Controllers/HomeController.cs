using System;
using System.Collections.Generic;
using System.Linq;
using System.Web;
using System.Web.Mvc;
using System.Web.Mvc.Ajax;
using System.Data;
using LearnMVC.Models;

namespace LearnMVC.Controllers
{
    public class HomeController : Controller
    {
        AppDataConnectionEntity connectionEntity = new AppDataConnectionEntity();

        public ActionResult Index(string UserID)
        {
            var Announcements = connectionEntity.Announcements
                                .Where(x => x.Active == true)
                                .OrderByDescending(date => date.CreatedDate)
                                .ToList();

            if(Announcements != null)
            {
                ViewBag.Announcements = Announcements;
            }
            else
            {
                ViewBag.Announcements = null;
            }

            if (UserID != null)
            {
                if (Session["UserID"] != null)
                {
                    var userdetails = connectionEntity.Users.Where(x => x.UserID == UserID).FirstOrDefault();
                    Session["Username"] = userdetails.first_name + " "+ userdetails.last_name;
                }
            } 
            return View();
        }
        public ActionResult Help()
        {
            return View();
        }

        public ActionResult Admin()
        {
            string UserID = Session["UserID"].ToString();
            return View();
        }

        [HttpPost]
        public ActionResult MailSystem(MailSystemModel mail)
        {
            return RedirectToAction("Index","Home");
        }
    }
}