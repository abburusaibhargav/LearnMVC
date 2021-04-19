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

                if(authstatus == "captchaerror")
                {
                    ViewBag.Captcha = "Please enter valid Captcha";
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
                    else
                    {
                        return RedirectToAction("Login", "Account", new RouteValueDictionary(new { Controller = "Login", Action = "Account", authstatus = "nouserfound" }));
                    }
                }
            }
                return RedirectToAction("Login", "Account", new RouteValueDictionary(new { Controller = "Login", Action = "Account", authstatus = "captchaerror" }));
        }
        public ActionResult Logout(string result)
        {
            Session["UserID"] = null;
            Dispose();
            ModelState.Clear();

            return RedirectToAction("Index", "Home");
        }
        [HttpPost]
        public ActionResult CreateUser(User user)
        {
            string fname = user.first_name;
            string lname = user.last_name;
            string email = user.email;
            string pwd = user.password;
            string gender = user.gender;
            string phone = user.Phone;
            string uname = fname + lname;

            try
            {
                string result = string.Empty;
                result = connectionEntity.Insert_User_Details(fname, lname, gender, phone, email, uname, pwd).ToString();

                if (result == "User Created")
                {
                    ViewBag.Result = result + " successfully.";
                }
                else
                {
                    ViewBag.Result = result + " failed.";
                }
            }
            catch
            {
                return View();
            }
            return RedirectToAction("Login", "Account");

        }
    }
}