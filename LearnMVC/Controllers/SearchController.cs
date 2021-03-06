using System;
using System.Collections.Generic;
using System.Configuration;
using System.Data;
using System.Data.SqlClient;
using System.Linq;
using System.Runtime.InteropServices;
using System.Web;
using System.Web.Mvc;
using System.Web.Routing;
using System.Reflection;
using LearnMVC.Models;

namespace LearnMVC.Controllers
{
    public class SearchController : Controller
    {

        /// /Entity Framework data connection to database

        AppDataConnectionEntity connectionEntity = new AppDataConnectionEntity();
        // GET: Search

        public ActionResult Index()
        {
            return View();
        }
        [HttpGet]
        public ActionResult AllUserList()
        { 
            
                string UserID = Session["UserID"].ToString();
                int CurrentPageIndex = 1;

                var result = GetAllUserList(UserID, CurrentPageIndex).ToList();
                TempData["TotalTblRecords"] = result.Count();
                TempData["TotalRecordsToFetch"] = connectionEntity.Get_User_List(UserID).Count();
                if (result != null)
                {
                    ViewBag.CurrentPage = CurrentPageIndex;
                    return View(result);
                }
                else
                {
                    return RedirectToAction("Index");
                }
           
        }
        [HttpPost]
        public ActionResult AllUserList(int CurrentPageIndex)
        {
            string UserID = Session["UserID"].ToString();
            var result = GetAllUserList(UserID, CurrentPageIndex).ToList();
            if (result != null)
            {
                TempData["TotalTblRecords"] = result.Count();
                ViewBag.CurrentPage = CurrentPageIndex;
                return View(result);
            }
            else
            {
                return RedirectToAction("Index");
            }
        }

        // GET: Search/Details/5
        public ActionResult Details(string UserID)
        {
            if (Session["UserID"] != null)
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
            if (Session["UserID"] != null)
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
     
        public ActionResult SearchAnnouncements(SearchModel searchModel)
        {
            if (searchModel.UserID != null && searchModel.Datefrom != null && searchModel.DateTo != null && searchModel.AnnouncementClassification!= null)
            {
                var results = connectionEntity.GetAnnouncements(searchModel.UserID, searchModel.Datefrom, searchModel.DateTo, searchModel.AnnouncementClassification).ToList();
                if (results != null)
                {
                    ViewBag.Count = results.Count();
                    ViewBag.AnnouncementsResults = results;

                }
            }
            return View();
        }
        [HttpPost]
        public ActionResult SearchAnnouncements(string UserID, SearchModel model)
        {
            string UID = UserID;
            DateTime From = model.Datefrom;
            DateTime To = model.DateTo;
            string AnnouncementClass = model.AnnouncementClassification;
            //var results = connectionEntity.GetAnnouncements(UserID, model.Datefrom, model.DateTo, model.AnnouncementClassification).ToList();
            //if(results != null)
            //{
            //    ViewBag.Count = results.Count();
            //    ViewBag.AnnouncementsResults = results;

            //}
            return RedirectToAction("SearchAnnouncements", "Search", new RouteValueDictionary(
                new 
                { Action = "SearchAnnouncements", Controller = "Search", UserID = UID, from = From, to = To, AnnouncementClassification = AnnouncementClass }));
        }
        
        public ActionResult SearchUploadTransactions(SearchModel searchModel)
        {
            if(Session["UserID"].ToString() != null && searchModel.Datefrom!=null && searchModel.DateTo!=null && searchModel.uploadfiletype != null)
            {
                var results = connectionEntity.Get_Upload_TransactionLog
                (Session["UserID"].ToString(), searchModel.Datefrom, searchModel.DateTo, searchModel.uploadfiletype).ToList();

                if (results.Count() > 0)
                {
                    ViewBag.UploadTranResults = results;
                }
            }
            
            return View();
        }

        public ActionResult SearchPostalList(SearchModel searchModel)
        {
            if(searchModel.searchBy != null && searchModel.searchvalue != null)
            {
                ViewBag.searchBy = searchModel.searchBy;
                ViewBag.searchvalue = searchModel.searchvalue;

                var results = connectionEntity.SearchPostalList(searchModel.searchBy, searchModel.searchvalue).ToList();
                if (results.Count() > 0)
                {
                    if (results.Count() > 20)
                    {
                        ViewBag.OverLimit = "Search has retreived " + results.Count() + " rows. Please modify your search criteria.";
                    }
                    else
                    {
                        ViewBag.Results = results;
                    }                   
                }
                else
                {
                    ViewBag.NoResults = "No Data Found";
                }
            }
            return View();
        }

        public JsonResult Search_PostalList(string term)
        {
         
                var results = connectionEntity.SearchPostalList("pincode", term).Select(y => y.Pincode).ToList();
                return Json(results, JsonRequestBehavior.AllowGet);
            
            
            //if (searchBy == "state")
            //{
            //    var results = connectionEntity.SearchPostalList(searchBy, term).Select(y => y.StateName).ToList();
            //    return Json(results, JsonRequestBehavior.AllowGet);
            //}
            //if (searchBy == "circle")
            //{
            //    var results = connectionEntity.SearchPostalList(searchBy, term).Select(y => y.CircleName).ToList();
            //    return Json(results, JsonRequestBehavior.AllowGet);
            //}
            //if (searchBy == "division")
            //{
            //    var results = connectionEntity.SearchPostalList(searchBy, term).Select(y => y.DivisionName).ToList();
            //    return Json(results, JsonRequestBehavior.AllowGet);
            //}
            //if (searchBy == "district")
            //{
            //    var results = connectionEntity.SearchPostalList(searchBy, term).Select(y => y.DistrictName).ToList();
            //    return Json(results, JsonRequestBehavior.AllowGet);
            //}
            //if (searchBy == "office")
            //{
            //    var results = connectionEntity.SearchPostalList(searchBy, term).Select(y => y.OfficeName).ToList();
            //    return Json(results, JsonRequestBehavior.AllowGet);
            //}
        }
        public ActionResult AutogenerateDates(string tranid)
        {
            return View();
        }

        [HttpPost]
        public ActionResult AutogenerateDates(SearchModel search)
        {
            return View();
        }

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
                return RedirectToAction("Index", "Search");
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

        [HttpPost]
        [ActionName("LookUpPincode")]
        public JsonResult LookUpPincode(int pincode)
        {
            var lookupresults = connectionEntity.Get_OfficeDetails_By_Pincode(pincode).ToList();
            if (lookupresults.Count() > 0)
            {
                ViewBag.PincodeResults = lookupresults;
            }
            else
            {
                ViewBag.PincodeNoResults = "No Results";
            }
            return Json(lookupresults, JsonRequestBehavior.AllowGet);
        }

        public List<Get_User_List_Result> GetAllUserList(string UserID, int currentpage)
        {
            int maxrows = 10;
            Pager pager = new Pager();

            var users = connectionEntity.Get_User_List(UserID)
                .Skip((currentpage - 1)* maxrows)
                .Take(maxrows)
                .ToList();

            double pagecount = (double)((decimal)connectionEntity.Get_User_List(UserID).Count() / Convert.ToDecimal(maxrows));

            pager.PageCount = (int)Math.Ceiling(pagecount);
            ViewBag.TotalPage = pager.PageCount;
            ViewBag.CurrentPage = currentpage;
            
            return users;
        }
    }
}
