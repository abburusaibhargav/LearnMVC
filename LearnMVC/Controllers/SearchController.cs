using System;
using System.Collections.Generic;
using System.Configuration;
using System.Data;
using System.Data.SqlClient;
using System.Linq;
using System.Web;
using System.Web.Mvc;
using LearnMVC.Models;

namespace LearnMVC.Controllers
{
    public class SearchController : Controller
    {
      
        /// /Entity Framework data connection to database
        
        AppDataConnectionEntity connectionEntity = new AppDataConnectionEntity();
        // GET: Search

        public ActionResult AllUserList()
        {
            var userlist = connectionEntity.Search_Get_User_List().ToString();
            var userviewlist = userlist.FirstOrDefault();
            return View(userviewlist);
            
        }

        // GET: Search/Details/5
        public ActionResult Details(string UserID)
        {
            if(Session["UserID"] != null)
            {
                return View(connectionEntity.Users.Where(x => x.UserID == UserID).FirstOrDefault());
            }
            else
            {
                return RedirectToAction("Index", "Home");
            }
        }

        // GET: Search/Create
        public ActionResult Create()
        {
            return View();
        }

        // POST: Search/Create
        [HttpPost]
        public ActionResult Create(User user)
        {
            if(Session["UserID"] != null)
            {
                try
                {
                    string fname = user.first_name;
                    string lname = user.last_name;
                    string gender = user.gender;
                    string email = user.email;
                    string phone = user.Phone;
                    string uname = user.Username;
                    string pwd = user.password;

                    connectionEntity.Insert_User_Details(fname, lname, gender, phone, email, uname, pwd);
                    ViewData["Message"] = "User Created Successfully.";
                    return RedirectToAction("Create", "Search");
                }
                catch
                {
                    ViewData["Message"] = "User Creation Failed.";
                    return RedirectToAction("Create", "Search");
                }
            }
            else
            {
                return RedirectToAction("Login", "Account");
            }
                      
        }

        // GET: Search/Edit/5
        public ActionResult Edit(User User)
        {
            return View();
        }

        // POST: Search/Edit/5
        [HttpPost]
        public ActionResult Edit(int id, FormCollection collection, User user)
        {
            try
            {
                connectionEntity.Update_User_Details(user.UserID, user.first_name, user.last_name, user.gender, user.email, user.Phone);
                return RedirectToAction("Index","Search");
            }
            catch
            {
                return View();
            }
        }

        // GET: Search/Delete/5
        public ActionResult Delete(int id)
        {
            return View();
        }

        // POST: Search/Delete/5
        [HttpPost]
        public ActionResult Delete(int id, FormCollection collection)
        {
            try
            {
                // TODO: Add delete logic here

                return RedirectToAction("Index");
            }
            catch
            {
                return View();
            }
        }
    }
}
