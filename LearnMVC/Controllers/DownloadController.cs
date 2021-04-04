using LearnMVC.Models;
using OfficeOpenXml;
using System;
using System.Collections.Generic;
using System.Data;
using System.IO;
using System.Linq;
using System.Web;
using System.Web.Mvc;
using System.Web.UI.WebControls;
using ClosedXML.Excel;
using System.Web.UI;
using System.Web.Routing;

namespace LearnMVC.Controllers
{
    public class DownloadController : Controller
    {
        AppDataConnectionEntity connectionEntity = new AppDataConnectionEntity();
        GridView gridView = new GridView();

        public IList<UploadTransactionLog> GetDownloadExcelData(string tranid)
        {
            var resultlist = connectionEntity.UploadTransactionLogs.Where(x => x.ServerTransactionID == tranid).ToList();

            return resultlist;
        }


        // GET: Download
        public ActionResult DownloadtoExcelResult( string DownloadTranID, string transid, string Report)
        {
            if(DownloadTranID != null)
            {
                string guid = Guid.NewGuid().ToString();
                ViewBag.GUID = guid;
                return View();
            }
            else
            {
                return RedirectToAction("DownloadToExcel", "Download", new RouteValueDictionary
                                                  (new { Controller = "Download", Action = "DownloadToExcel", tranid = transid, report = Report }));
            }
            
        }
        public ActionResult DownloadToExcel(string tranid, string report)
        {
            gridView.DataSource = GetDownloadExcelData(tranid);
            gridView.DataBind();

            Response.ClearContent();
            Response.Buffer = true;
            Response.AddHeader("content-disposition", "attachment ; filename=" + report+".xls");
            Response.ContentType = "application/ms-excel";
            Response.Charset = "";

            StringWriter stringWriter = new StringWriter();
            HtmlTextWriter htmlTextWriter = new HtmlTextWriter(stringWriter);

            gridView.RenderControl(htmlTextWriter);

            Response.Output.Write(stringWriter.ToString());
            Response.Flush();
            Response.End();

            return RedirectToAction("DownloadtoExcelResult", "Download", new RouteValueDictionary
                                                  (new { Controller = "Download", Action = "DownloadtoExcelResult", DownloadTranID = tranid }));
        }
    }
}