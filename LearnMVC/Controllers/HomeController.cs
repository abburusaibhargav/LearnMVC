using LearnMVC.Models;
using System.Collections.Generic;
using System.Data;
using System.Linq;
using System.Net.Mail;
using System.Web.Mvc;

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

                if (Session["UserID"] != null)
                {
                    var homepagetime = GetHomePageTimeZone(Session["UserID"].ToString());
                ViewBag.TimeZone = homepagetime;
                }
                else
                {
                    var homepagetime = GetHomePageTimeZone(null);
                ViewBag.TimeZone = homepagetime;
            }

            if (UserID != null)
            {
                if (Session["UserID"] != null)
                {
                    var userdetails = connectionEntity.Users.Where(x => x.UserID == UserID).FirstOrDefault();
                    Session["Username"] = userdetails.first_name + " " + userdetails.last_name;
                }
            }

            if (Announcements != null)
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
            if (images != null)
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
            if (ModelState.IsValid)
            {
                try
                {
                    MailMessage mailMessage = new MailMessage();
                    mailMessage.To.Add(mail.Receivermailid);
                    mailMessage.Subject = "Ad-hoc Mail";
                    mailMessage.From = new MailAddress("abburusaibhargav@gmail.com", "AVSSB - Learn MVC");
                    mailMessage.Body = mail.MailBody + "<br/>" +
                        "<br/>" +
                        "Regards,<br />" +
                        "AVSSB - Learn MVC<br/>"+
                        "This is system generated mail. Replies to this inbox are not monitored." ;
                    mailMessage.IsBodyHtml = true;
                    SmtpClient smtpClient = new SmtpClient();
                    smtpClient.Send(mailMessage);

                    ViewBag.Message = "Mail Sent Successfully..!";
                }
                catch
                {
                    ViewBag.Message = "Mail Sending Failed..!";
                    return RedirectToAction("Index", "Home");
                }
               

            }
            return RedirectToAction("Index", "Home");
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

        public List<GetHomePageTime_Result> GetHomePageTimeZone(string UserID)
        {
            List<GetHomePageTime_Result> timeZones = new List<GetHomePageTime_Result>();
            timeZones = connectionEntity.GetHomePageTime(UserID).ToList();

            return timeZones;
        }
    }
}