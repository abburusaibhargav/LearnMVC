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
    [RequireHttps]
    public class HomeController : Controller
    {
        AppDataConnectionEntity connectionEntity = new AppDataConnectionEntity();

        public ActionResult Index(string UserID)
        {
            //Response.AddHeader("Refresh", "5");
            var Announcements = GetAnnouncements();

            if (UserID != null)
            {
                if (Session["UserID"] != null)
                {
                    var userdetails = connectionEntity.Users.Where(x => x.UserID == UserID).FirstOrDefault();
                    Session["Username"] = userdetails.first_name + " " + userdetails.last_name;
                }
            }

            if(Announcements != null)
            {
                ViewBag.Announcements = Announcements;
            }
            else
            {
                ViewBag.Announcements = null;
            }

            return View();
        }
        public ActionResult Help()
        {
            return View();
        }

        public ActionResult GetHomeLandingImages()
        {
            var images = GetLandingImages();
            if(images != null)
            {
                ViewBag.Images = images;    
            }
            else
            {
                ViewBag.Images = "No data";
            }
            return PartialView("HomeLandingImages");
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

        public List<LandingImage> GetLandingImages()
        {
            List<LandingImage> landingImages = new List<LandingImage>();
            landingImages = connectionEntity.LandingImages.Where(x => x.Active == true).OrderBy(s => s.SortOrder).ToList();

            return landingImages;
           
        }

        public List<Announcement> GetAnnouncements()
        {
            List<Announcement> announcements = new List<Announcement>();
            announcements = connectionEntity.Announcements
                                .Where(x => x.Active == true)
                                .OrderByDescending(date => date.CreatedDate)
                                .ToList();

            return announcements;
        }
    }
}