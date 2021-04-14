using LearnMVC.Models;
using System;
using System.Collections.Generic;
using System.Linq;
using System.Web;
using System.Web.Mvc;
using LearnMVC.Models.Consignment;
using System.Web.Routing;
using System.Data;
using System.Data.SqlClient;

namespace LearnMVC.Controllers
{
    public class ConsignmentController : Controller
    {
        AppDataConnectionEntity connectionEntity = new AppDataConnectionEntity();
        // GET: Consignment

        public ActionResult Index(User user)
        {
            return View();
        }
        public ActionResult CreateBooking(string tranid)
        {
            if(Session["UserID"] != null)
            {
                if (tranid != null)
                {
                    return View();
                }
                else
                {
                    string guid = Guid.NewGuid().ToString();
                    ViewBag.GUID = guid.ToUpper();

                    List<Postal_State_List> postal_State_Lists_DDL = connectionEntity.Postal_State_List.Where(x=>x.Active == true).ToList();
                    ViewBag.StateDDL = new SelectList(postal_State_Lists_DDL, "StateID", "StateName");

                    List<Postal_Office_Type> postal_Office_Types_DDL = connectionEntity.Postal_Office_Type.Where(x => x.Active == true).ToList();
                    ViewBag.OfficeTypeDDL = new SelectList(postal_Office_Types_DDL, "OfficeTypeID", "OfficeTypeName");

                    List<Postal_Delivery_Type> postal_Delivery_Types_DDL = connectionEntity.Postal_Delivery_Type.Where(x => x.Active == true).ToList();
                    ViewBag.DeliveryTypeDDL = new SelectList(postal_Delivery_Types_DDL, "DeliveryID", "DeliveryType");

                    List<Postal_Region_List> postal_Region_DDL = connectionEntity.Postal_Region_List.Where(x => x.Active == true).ToList();
                    ViewBag.postal_Region_DDL = new SelectList(postal_Region_DDL, "RegionID", "RegionName");

                    List<Postal_Circle_List> postal_Circle_Lists_DDL = connectionEntity.Postal_Circle_List.Where(x => x.Active == true).ToList();
                    ViewBag.postal_Circle_Lists_DDL = new SelectList(postal_Circle_Lists_DDL, "CircleID", "CircleName");

                    List<Postal_Division_List> divisionddl = connectionEntity.Postal_Division_List.Where(x => x.Active == true).ToList();
                    ViewBag.divisionddl = new SelectList(divisionddl, "DivisionID", "DivisionName");

                    List<Postal_District_List> districtddl = connectionEntity.Postal_District_List.Where(x => x.Active == true).ToList();
                    ViewBag.districtddl = new SelectList(districtddl, "DistrictID", "DistrictName");

                    List<Postal_Office_List> officedataddl = connectionEntity.Postal_Office_List.Where(x => x.Active == true).ToList();
                    ViewBag.officedataddl = new SelectList(officedataddl, "OfficeID", "OfficeName");

                    List<Postal_Pincode_List> pincodeDDL = connectionEntity.Postal_Pincode_List.Where(x => x.Active == true).ToList();
                    ViewBag.pincodeDDL = new SelectList(pincodeDDL, "PincodeID", "Pincode");

                    return View();
                }
            }
            else
            {
               return RedirectToAction("Login", "Account");
            }   
        }
        [HttpPost]
        public ActionResult CreateBooking(CreateDomesticBooking createDomesticBooking, BookConsignment consignment)
        {
            string ConsigneeName = createDomesticBooking.ConsigneeName;
            string ConsignerName = createDomesticBooking.ConsignerName;
            string ConsigneeAddress = createDomesticBooking.ConsigneeAddress;
            string ConsignerAddress = createDomesticBooking.ConsignerAddress;
            string ToStateID = createDomesticBooking.ConsignerStateID;
            string CircleID = createDomesticBooking.CircleID;
            string RegionId = createDomesticBooking.RegionID;
            string divisionId = createDomesticBooking.DivisionID;
            string districtId = createDomesticBooking.DistrictID;
            string OfficeId = createDomesticBooking.OfficeID;
            string officeTypeId = createDomesticBooking.OfficeTypeID;
            string delivery = createDomesticBooking.DeliveryID;
            int ToPincode = createDomesticBooking.ConsignerPincode;
            string createdby = Session["UserID"].ToString();

            string BookingID = string.Empty;

            BookingID = connectionEntity.Create_Consignment_Booking(ConsigneeName, ConsignerName, ConsigneeAddress, ConsignerAddress,
                ToStateID, CircleID, RegionId, divisionId, districtId, OfficeId, officeTypeId, delivery, ToPincode, createdby).First().ToString();

            if(BookingID != null)
            {
                return RedirectToAction("BookingConfirm", "Consignment",
                    new RouteValueDictionary(
                        new { Action = "BookingConfirm", Controller = "Consignment", status = true, BookingID = BookingID.ToString() }));
            }
            else
            {
                return RedirectToAction("BookingConfirm", "Consignment",
                    new RouteValueDictionary(
                        new { Action = "BookingConfirm", Controller = "Consignment", status = false }));
            }
        
        }

        public ActionResult BookConsignmentDetails(string BookingID, BookConsignment consignment)
        {
            if (BookingID != null)
            {
                var BookingDetails = connectionEntity.Get_Consignment_Details_By_BookingID(BookingID).ToString();
                return View(BookingDetails);
            }
            else
            {
               return RedirectToAction("Index", "Consignment");
            }
          
        }

        public ActionResult BookingConfirm(bool status,string BookingID)
        {
           if(status == true)
            {
                if(BookingID != null)
                {
                    var results = connectionEntity.Get_Consignment_Details_By_BookingID(BookingID).ToList();
                    ViewBag.Results = results;

                    return View();
                }
            }
            return View();
        }

        [HttpGet]
        public ActionResult CheckConsignmentStatus(string BookingID)
        {
            if(BookingID != null)
            {
                var consignmentDetails = connectionEntity.ConsignmentDetails.Where(x => x.BookingID == BookingID).First();

                if (consignmentDetails != null)
                {
                    ViewBag.Rows = "Consignment Details Found..!";
                    return View(consignmentDetails);
                }
                else
                {
                    ViewBag.NoRows = "Consignment Details Not Found..!";
                    return View();
                }
            }
            else
            {
                return View();
            }   
        }

        [HttpGet]
        public ActionResult UpdateConsignmentStatus(string BookingID,string Type, ConsignmentDetail consignment)
        {
            if(BookingID != null)
            {
                if(Type == "get")
                {
                    var resultforstatusupdate = connectionEntity.ConsignmentDetails.Where(x => x.BookingID == BookingID).FirstOrDefault();

                    if (resultforstatusupdate != null)
                    {
                        ViewBag.Rows = "Records Found for Update..";
                        return View(resultforstatusupdate);
                    }
                    else
                    {
                        ViewBag.Rows = "No Records Found for Update..";
                    }
                }

                if(Type == "post")
                {
                    string Status = consignment.ConsignmentStatus;

                    var result = connectionEntity.UpdateConsignmentStatus1(BookingID, Status);

                    if (result.ToString() == "Updated")
                    {
                        ViewBag.Status = "Consignment Status Updated Successfully..!";
                    }
                    else
                    {
                        ViewBag.Status = "Consignment Status Update failed..!";
                    }
                }
            }

            ModelState.Clear();
            return View();
        }

        [HttpPost]
        public ActionResult UpdateConsignmentStatus(ConsignmentDetail consignment,string BookingID)
        {

            return View();
        }

        #region Drop Down List Data -> GET Methods | JSON Response
        public JsonResult GetCircleDataDDL(string StateID)
        {
            connectionEntity.Configuration.ProxyCreationEnabled = false;
            List<Postal_Circle_List> postal_Circle_Lists_DDL = connectionEntity.Postal_Circle_List.Where(x => x.StateID == StateID).ToList();
            return Json(postal_Circle_Lists_DDL, JsonRequestBehavior.AllowGet);
        }

        public JsonResult GetRegionDataDDL(string CircleID)
        {
            connectionEntity.Configuration.ProxyCreationEnabled = false;
            List<Postal_Region_List> regionddl = connectionEntity.Postal_Region_List.Where(x => x.CircleID == CircleID).ToList();
            return Json(regionddl, JsonRequestBehavior.AllowGet);
        }

        public JsonResult GetDivisionDataDDL(string RegionID)
        {
            connectionEntity.Configuration.ProxyCreationEnabled = false;
            List<Postal_Division_List> divisionddl = connectionEntity.Postal_Division_List.Where(x => x.RegionID == RegionID).ToList();
            return Json(divisionddl, JsonRequestBehavior.AllowGet);
        }

        public JsonResult GetDistrictDataDDL(string DivisionID)
        {
            connectionEntity.Configuration.ProxyCreationEnabled = false;
            List<Postal_District_List> districtddl = connectionEntity.Postal_District_List.Where(x => x.DivisionID == DivisionID).ToList();
            return Json(districtddl, JsonRequestBehavior.AllowGet);
        }
        public JsonResult GetOfficeDataDDL(string DistrictID)
        {
            connectionEntity.Configuration.ProxyCreationEnabled = false;
            List<Postal_Office_List> officedataddl = connectionEntity.Postal_Office_List.Where(x => x.DistrictID == DistrictID).ToList();
            return Json(officedataddl, JsonRequestBehavior.AllowGet);
        }
        public JsonResult GetPincodeDDL(string OfficeID)
        {
            connectionEntity.Configuration.ProxyCreationEnabled = false;
            List<Postal_Pincode_List> pincodeDDL = connectionEntity.Postal_Pincode_List.Where(x => x.OfficeID == OfficeID).ToList();
            return Json(pincodeDDL, JsonRequestBehavior.AllowGet);
        }
        #endregion
    }
}