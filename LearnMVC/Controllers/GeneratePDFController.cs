//using System;
//using System.Collections.Generic;
//using System.IO;
//using System.Linq;
//using System.Text;
//using System.Web;
//using System.Web.Mvc;
//using iText.Layout;
//using LearnMVC.Models;
//using iText.IO;
//using iTextSharp.text.pdf;

//namespace LearnMVC.Controllers
//{
//    public class GeneratePDFController : Controller
//    {
//        // GET: GeneratePDF
//        public FileResult UserList()
//        {
//            MemoryStream stream = new MemoryStream();
//            StringBuilder stringBuilder = new StringBuilder();
//            DateTime dateTime = DateTime.Now;
//            string PDFFileName = string.Format("SamplePdf" + dateTime.ToString("yyyyMMdd") + "-" + ".pdf");
//            var doc = new Document();
//            doc.SetMargins(0f, 0f, 0f, 0f, 0f, 0f, 0f);
//            PdfPTable tablelayout = new 

//            return File(stream, "application/pdf", PDFFileName);
//        }
//    }
//}