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


        public ActionResult AdjustTimezone(string request, string TimezoneID)
        {
            if (request == "resultforupdate")
            {
                var timezone = connectionEntity.GetHomePageTime(Session["UserID"].ToString()).Where(x => x.TimezoneID == TimezoneID).ToList();
                ViewBag.updatetimezone = timezone;
            }

            if (request == "resultfordelete")
            {
                var timezone = connectionEntity.GetHomePageTime(Session["UserID"].ToString()).Where(x => x.TimezoneID == TimezoneID).ToList();
                ViewBag.deletetimezone = timezone;
            }

            if (request == "resultforreactivate")
            {
                var timezone = connectionEntity.GetHomePageTime(Session["UserID"].ToString()).Where(x => x.Active == false).ToList();
                ViewBag.reactivatetimezone = timezone;
            }

            var viewtimezone = connectionEntity.GetHomePageTime(Session["UserID"].ToString()).Where(x => x.Active == true).ToList();
            ViewBag.viewtimezone = viewtimezone;

            ViewBag.UpdateDDL = connectionEntity.GetHomePageTime(Session["UserID"].ToString()).Where(x => x.Active == true).ToList();
            ViewBag.DeleteDDL = connectionEntity.GetHomePageTime(Session["UserID"].ToString()).Where(x => x.Active == true).ToList();
            ViewBag.ReactivateDDL = connectionEntity.GetHomePageTime(Session["UserID"].ToString()).Where(x => x.Active == false).ToList();

            return View();
        }

        [HttpPost]
        public ActionResult AdjustTimezone(Models.TimeZone timeZone, string request)
        {
            var result = connectionEntity.InsertUpdateDeleteTimezone(Session["USerID"].ToString(), request, timeZone.Country,
                timeZone.Timezone1, timeZone.TimezoneID).FirstOrDefault();

            if(result == "Inserted" || result == "Updated" || result == "Deleted" || result == "Reactivated")
            {
                ViewBag.Result = result + " successfully";
            }

            return RedirectToAction("AdjustTimezone", "Admin" );
        }

        public ActionResult ModifyProducts(string ProductID)
        {
            if(ProductID != null)
            {
                if(ProductID == "all")
                {
                    var productsallinfo = connectionEntity.GetProducts("admin").ToList();
                    if (productsallinfo.Count() > 0)
                    {
                        ViewBag.ProductsAllinfo = productsallinfo;
                    }
                }
                else
                {
                    var productInfo = connectionEntity.GetProducts("admin").Where(x => x.ProductID == ProductID).ToList();
                    ViewBag.ProductInfo = productInfo;
                }
            }

            var products = connectionEntity.GetProducts("admin").ToList();
            if (products.Count() > 0)
            {
                ViewBag.Products = products;
            }


            return View();
        }

        [HttpPost]
        public ActionResult ModifyProducts(string ProductID, string ProductName, bool Active,string ProductPageURL, HttpPostedFileBase ProductImageURL)
        {
            string UserID = Session["UserID"].ToString();
            if(ProductImageURL != null)
            {
                string FileName = Path.GetFileNameWithoutExtension(ProductImageURL.FileName);
                string filetype = Path.GetExtension(ProductImageURL.FileName);

                if (filetype.ToLower() == ".jpg" || filetype.ToLower() == ".png" || filetype.ToLower() == ".jpeg")
                {
                    string fullfilename = FileName + filetype;
                    string dbpath = "Content/Products/" + fullfilename;

                    string filepath = Path.Combine(Server.MapPath("~/Content/Products/"), fullfilename);

                    ProductImageURL.SaveAs(filepath);
                    connectionEntity.ModifyProducts(UserID,ProductID, ProductName, ProductPageURL, dbpath, Active);
                }
                
            }

           connectionEntity.ModifyProducts(UserID,ProductID, ProductName, ProductPageURL, null, Active);
                return RedirectToAction("ModifyProducts", "Admin");
        }
    }
}