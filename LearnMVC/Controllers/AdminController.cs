using System;
using System.Collections.Generic;
using System.Linq;
using System.Web;
using System.Web.Mvc;
using LearnMVC.Models;

namespace LearnMVC.Controllers
{
    public class AdminController : Controller
    {
        AppDataConnectionEntity connectionEntity = new AppDataConnectionEntity();
        // GET: Admin
        public ActionResult Index()
        {
            if (Session["UserID"] == null)
            {
                return RedirectToAction("Login", "Account");
            }
            else
            {
                return View();
            }   
        }

        public ActionResult Announcements()
        {
            ViewBag.User = Session["UserID"].ToString();
            return View();
        }

        [HttpPost]
        public ActionResult Announcements(Announcement announcement)
        {
            var result = connectionEntity.InsertAnnouncements(
                                                                announcement.AnnouncementTitle, 
                                                                announcement.AnnouncementContent, 
                                                                announcement.CreatedBy, 
                                                                announcement.AnnouncementClassification
                                                                );
            if(result != null)
            {
                ViewBag.Result = announcement.AnnouncementID;
                return RedirectToAction("Index", "Home");
            }
            else
            {
                ViewBag.Result = "Announcement Update Failed";
                return RedirectToAction("Announcements", "Home");
            }
            
        }
    }
}