using System;
using System.Collections.Generic;
using System.IO;
using System.Linq;
using System.Web;
using System.Web.Mvc;
using System.Web.Routing;
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
            if (result != null)
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
        public ActionResult LandingImageControl()
        {
            var result = connectionEntity.LandingImages.Where(x => x.Active == true).OrderByDescending(s => s.SortOrder).Take(1).FirstOrDefault();

            if(result != null)
            {
                ViewBag.MaxSortOrder = result.SortOrder + 1;
            }
            else
            {
                ViewBag.MaxSortOrder = 1;
            }
            return View();
        }

        [HttpPost]
        public ActionResult LandingImageControl(HttpPostedFileBase LandingImagePath, LandingImage landingImage)
        {
            if (ModelState.IsValid)
            {
                string FileName = Path.GetFileNameWithoutExtension(LandingImagePath.FileName);
                string filetype = Path.GetExtension(LandingImagePath.FileName);

                if (filetype.ToLower() == ".jpg" || filetype.ToLower() == ".png" || filetype.ToLower() == ".jpeg")
                {
                    string fullfilename = FileName + filetype;
                    string dbpath = "~/Content/LandingImages/" + fullfilename;

                    string filepath = Path.Combine(Server.MapPath("~/Content/LandingImages/"), fullfilename);

                    LandingImagePath.SaveAs(filepath);

                    string result = connectionEntity.InsertLandingPageImages(
                        landingImage.LandingImageName,
                        dbpath,
                        landingImage.SortOrder,
                        Session["UserID"].ToString()
                        ).ToString();

                    if(result != null)
                    {
                        ViewBag.Result = "Image Insert Successful.";
                    }
                       
                }
                else
                {
                    ViewBag.FileExtensionError = "Please only upload images in .jpg or .png file format.";
                    TempData["Result"] = "Please only upload images in .jpg or .png file format.";
                }
            }
            ModelState.Clear();
            Dispose();
            
            return RedirectToAction("LandingImageControl");
        }
    }
}