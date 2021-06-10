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
using Rotativa;
using iTextSharp;
using iText;
using System.IO;
using System.Drawing;
using System.Drawing.Imaging;
using QRCoder;
using Microsoft.Extensions.Logging;

namespace LearnMVC.Controllers
{
    public class ConsignmentController : Controller
    { 
        //Initialize Database Connection
        AppDataConnectionEntity connectionEntity = new AppDataConnectionEntity();
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

            //ConsigneeAddress = ConsigneeAddress.Replace(",", "<br/>");
            string BookingID = string.Empty;

            BookingID = connectionEntity.Create_Consignment_Booking(ConsigneeName, ConsignerName, ConsigneeAddress, ConsignerAddress,
                ToStateID, CircleID, RegionId, divisionId, districtId, OfficeId, officeTypeId, delivery, ToPincode, createdby).First().ToString();

            if(BookingID != null)
            {
                if(BookingID.Trim() == "Unable to create booking.")
                {
                    return RedirectToAction("BookingConfirm", "Consignment",
                    new RouteValueDictionary(
                        new { Action = "BookingConfirm", Controller = "Consignment", status = false }));
                }
                else
                {
                    return RedirectToAction("BookingConfirm", "Consignment",
                                       new RouteValueDictionary(
                                           new { Action = "BookingConfirm", Controller = "Consignment", status = true, BookingID = BookingID.ToString() }));
                }   
            }
            else
            {
                return View();
            }
        
        }

        public ActionResult BookingConfirm(bool status,string BookingID)
        {
            if(Session["UserID"] == null)
            {
                return RedirectToAction("Login", "Account");
            }

           if(status == true)
            {
                if(BookingID != null)
                {
                    var results = connectionEntity.Get_Consignment_Details_By_BookingID(BookingID).ToList();
                    ViewBag.Results = results;
                    ViewBag.BookingID = BookingID.ToString();
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
        public ActionResult UpdateConsignmentStatus(string BookingID)
        {
            if(BookingID != null)
            {
                var resultforstatusupdate = connectionEntity.Get_Consignment_Status_By_BookingID(BookingID).ToList();

                var consignmenthistory = connectionEntity.Get_Consignment_History(BookingID).ToList();
                ViewBag.ConsignmentHistory = consignmenthistory;
                ViewBag.BookingID = BookingID;

                List<ConsignmentStatu> consignmentStatuses = connectionEntity.ConsignmentStatus.Where(x => x.Active == true).ToList();
                ViewBag.ConsignmentStatus = new SelectList(consignmentStatuses, "ConsignmentStatusID", "ConsignmentStatusName");

                if (resultforstatusupdate != null)
                {
                    ViewBag.Rows = "Records Found for Update..";
                    ViewBag.Results = resultforstatusupdate;
                    return View();
                }
                else
                {
                    ViewBag.Rows = "No Records Found for Update..";
                }
                
            }
            return View();
        }

        [HttpPost]
        public ActionResult UpdateConsignmentStatus(ConsignmentDetail consignment)
        {
            string BookingID = consignment.BookingID;
            string StatusID = consignment.ConsignmentStatusID;
            string userid = Session["UserID"].ToString();

            var results = connectionEntity.UpdateConsignmentStatus1(BookingID, StatusID, userid);
        
            if (results.ToString() == "Updated")
            {
                ViewBag.Status = "Consignment Status Updated Successfully..!";
            }
            else
            {
                ViewBag.Status = "Consignment Status Update failed..!";
            }
            return RedirectToAction("UpdateConsignmentStatus", "Consignment",
                                       new RouteValueDictionary(
                                           new { Action = "UpdateConsignmentStatus", Controller = "Consignment",BookingID = BookingID.ToString() }));
        }
        public ActionResult PrintConsignmentDetails(string BookingID)
        {
            var report = new ActionAsPdf("BookingConfirm", new { status = true, BookingID = BookingID});
            return report;
        }

        [HttpGet]
        public ActionResult Printpage(string BookingID)
        {
            ViewBag.BookingID = BookingID;

            var consignmenthistory = connectionEntity.Get_Consignment_History(BookingID).ToList();
            ViewBag.ConsignmentHistory = consignmenthistory;

            //using (MemoryStream memoryStream = new MemoryStream())
            //{
            //    using (Bitmap bitMap = new Bitmap(BookingID.Length * 10, 10))
            //    {
            //        using (Graphics graphics = Graphics.FromImage(bitMap))
            //        {
            //            Font oFont = new Font("IDAutomationHC39M", 16);
            //            PointF point = new PointF(2f, 2f);
            //            SolidBrush whiteBrush = new SolidBrush(Color.White);
            //            graphics.FillRectangle(whiteBrush, 0, 0, bitMap.Width, bitMap.Height);
            //            SolidBrush blackBrush = new SolidBrush(Color.DarkBlue);
            //            graphics.DrawString("*" + BookingID + "*", oFont, blackBrush, point);
            //        }
            //        bitMap.Save(memoryStream, ImageFormat.Jpeg);
            //        ViewBag.BarcodeImage = "data:image/png;base64," + Convert.ToBase64String(memoryStream.ToArray());
            //    }
            //}

            try
            {
                byte[] byteimage;

                //string qrtexts = TempData["uploadtransaction"].ToString();

                MemoryStream memoryStream = new MemoryStream();
                QRCodeGenerator qRCodeGenerator = new QRCodeGenerator();
                QRCodeData qRCodeData = qRCodeGenerator.CreateQrCode(BookingID, QRCodeGenerator.ECCLevel.Q);
                QRCode qRCode = new QRCode(qRCodeData);

                Bitmap bitmapQRImage = qRCode.GetGraphic(20);

                bitmapQRImage.Save(memoryStream, ImageFormat.Png);
                byteimage = memoryStream.ToArray();

                var baseimage = Convert.ToBase64String(byteimage);

                ViewBag.QRImage = "data:image/png;base64," + baseimage;
            }
            catch
            {
                ViewBag.ErrorMessage = "Unable to generate QR code.";
            }

            return View();
        }

        public ActionResult PrintConsignmentInvoice(string bookingID)
        {
            var report = new ActionAsPdf("Printpage", new { BookingID = bookingID});
            return report;
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