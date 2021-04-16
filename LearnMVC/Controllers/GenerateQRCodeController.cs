using System;
using System.Collections.Generic;
using System.Configuration;
using System.Data;
using System.Data.Common;
using System.Data.OleDb;
using System.Data.SqlClient;
using System.Drawing;
using System.Drawing.Imaging;
using System.IO;
using System.Linq;
using System.Web;
using System.Web.Mvc;
using System.Web.Routing;
using LearnMVC.Models;
using QRCoder;
using ZXing;

namespace LearnMVC.Controllers
{
    public class GenerateQRCodeController : Controller
    {
        // GET: GenerateQRCode
        
        //public ActionResult GenerateQRCode()
        //{
        //    ViewBag.QRImage = null;
        //    return View();
        //}

         public ActionResult GenerateQRCode(string qrtext)
        {
            try
            {
                byte[] byteimage;

                //string qrtexts = TempData["uploadtransaction"].ToString();
 
                MemoryStream memoryStream = new MemoryStream();
                QRCodeGenerator qRCodeGenerator = new QRCodeGenerator();
                QRCodeData qRCodeData = qRCodeGenerator.CreateQrCode(qrtext, QRCodeGenerator.ECCLevel.Q);
                QRCode qRCode = new QRCode(qRCodeData);

                Bitmap bitmapQRImage = qRCode.GetGraphic(20);

                bitmapQRImage.Save(memoryStream, ImageFormat.Png);
                byteimage = memoryStream.ToArray();

                var baseimage = Convert.ToBase64String(byteimage);

                ViewBag.QRImage = "data:image/png;base64," + baseimage;
                ViewBag.SuccessMessage = "QR Code generated successfully.";

                ViewBag.QRImage = TempData.Peek("QRImage");
                ViewBag.SuccessMessage = TempData.Peek("GenerateResult");
            }
            catch
            {
                ViewBag.ErrorMessage = "Unable to generate QR code.";
                TempData["GenerateResult"] = ViewBag.ErrorMessage;
            }
            
            return View();
        }
    }

}