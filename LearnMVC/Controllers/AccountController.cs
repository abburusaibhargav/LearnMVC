using System;
using System.Collections.Generic;
using System.Data;
using System.Data.SqlClient;
using System.Linq;
using System.Web;
using System.Web.Mvc;
using System.Web.Routing;
using CaptchaMvc.HtmlHelpers;
using LearnMVC.Models;

namespace LearnMVC.Controllers
{
    public class AccountController : Controller
    {
        AppDataConnectionEntity connectionEntity = new AppDataConnectionEntity();
        // GET: Account


        public ActionResult Login(string authstatus)
        {
            if(authstatus != null)
            {
                if (authstatus == "pwdx")
                {
                    ViewData["Authenticated"] = "No";
                }
                
                if (authstatus == "nouserfound")
                {
                    ViewData["NoUser"] = "NoUser";
                }
            }
       
            return View();
        }
        [HttpPost]
        public ActionResult Login(User user)
        {

            if(this.IsCaptchaValid("Validate your Captcha"))
            {
                string uid = user.UserID;
                string pwd = user.password;

                var authcheck = connectionEntity.User_Login_Auth(uid, pwd).FirstOrDefault();
                var validate = authcheck;

                if (validate != null)
                {
                    if (validate.UserID == uid)
                    {
                        if (validate.Password == pwd)
                        {
                            Session["UserID"] = uid;
                            ViewData["Authenticated"] = "Yes";

                            return RedirectToAction("Index", "Home", new RouteValueDictionary(new { Controller = "Home", Action = "Index", UserID = uid }));
                        }
                        else
                        {
                            return RedirectToAction("Login", "Account", new RouteValueDictionary(new { Controller = "Login", Action = "Account", authstatus = "pwdx" }));
                        }
                    }
                }
            }
            return RedirectToAction("Login", "Account", new RouteValueDictionary(new { Controller = "Login", Action = "Account", authstatus = "nouserfound" }));
        }
        public ActionResult Logout(string result)
        {
            Session["UserID"] = null;
            Dispose();
            ModelState.Clear();

            return RedirectToAction("Index", "Home");
        }
    }
}