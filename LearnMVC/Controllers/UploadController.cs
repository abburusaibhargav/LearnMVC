using System;
using System.Collections.Generic;
using System.Configuration;
using System.Data;
using System.Data.Common;
using System.Data.OleDb;
using System.Data.SqlClient;
using System.IO;
using System.Linq;
using System.Web;
using System.Web.Mvc;
using System.Web.Routing;
using LearnMVC.Models;

namespace LearnMVC.Controllers
{
    public class UploadController : Controller
    {
        OleDbConnection Econ;
        SqlConnection sqlConnection = new SqlConnection(ConfigurationManager.ConnectionStrings["DatabaseConnection"].ConnectionString);
        AppDataConnectionEntity connectionEntity = new AppDataConnectionEntity();
        // GET: Upload

        public ActionResult Upload(string transactionid)
        {
            if(transactionid != null)
            {
                var uploadfiletransactiondetails = connectionEntity.UploadTransactionLogs.Where(x => x.ServerTransactionID == transactionid).FirstOrDefault();
             
                if (uploadfiletransactiondetails != null)
                {
                    ViewData["Upload Status"] = "Success";
                    ViewData["AfterTransaction"] = "Yes";

                    return View(uploadfiletransactiondetails);
                }
            }
            else
            {
                string guid = Guid.NewGuid().ToString();
                ViewData["GUID"] = guid;
            }
            return View();
        }
        [HttpPost]
        public ActionResult Upload(HttpPostedFileBase UploadFileName, UploadTransactionLog uploadTransaction)
        {
            string tranid = uploadTransaction.UploadTransactionID;
            string FileName = Path.GetFileNameWithoutExtension(UploadFileName.FileName);
            string filetype = Path.GetExtension(UploadFileName.FileName);
            string descr = uploadTransaction.UploadFileDescription;
            string uploadby = uploadTransaction.UploadedBy;
            DateTime uploaddate = (DateTime)uploadTransaction.UploadedOn;

            string fullfilename = FileName + filetype;

            uploadTransaction.UploadFileName = fullfilename;
            string dbfilepath = "~/Content/Uploads/" + fullfilename;
            string filepath = Path.Combine(Server.MapPath("~/Content/Uploads/"), fullfilename);

            UploadFileName.SaveAs(filepath);

            connectionEntity.Record_Upload_Transaction_Log(tranid, FileName, dbfilepath, descr, uploadby, uploaddate);

            if (filetype == ".xlsx" || filetype == ".xls")
            {
                string truncatetable = "Truncate Table Postal_Data_Staging";
                string updatetranid = "Update Postal_Data_Staging SET StageTransactionID='" + tranid + "',CreatedBy='" + Session["UserID"] + "'" +
                                                                                                                        ",CreatedOn='" + DateTime.Now.ToString() + "'";

                SqlCommand truncatecmd = new SqlCommand(truncatetable, sqlConnection);
                sqlConnection.Open();
                truncatecmd.ExecuteNonQuery();
                sqlConnection.Close();

                ImportExcelData(filepath);

                SqlCommand updatecmd = new SqlCommand(updatetranid, sqlConnection);
                sqlConnection.Open();
                updatecmd.ExecuteNonQuery();
                sqlConnection.Close();

                connectionEntity.Generate_Upload_Transaction_Summary(tranid, "OfficeDetails");

            }

          

            return RedirectToAction("Upload", new RouteValueDictionary(new { Controller = "Upload", Action = "Upload", transactionid = tranid }));
        }

        public ActionResult ProcessData(string tranid)
        {
            var trandetails = connectionEntity.UploadTranSummaries.Where(x => x.StageTranID == tranid).ToList();
           return View(trandetails);
        }
        //[HttpPost]
        //public ActionResult ProcessData(UploadTranSummary uploadTranSummary)
        //{
        //    return View();
        //}



        private void ExcelConn(string filepath)
        {
            string connstring = "Provider=Microsoft.ACE.OLEDB.12.0;Data Source =" + filepath + ";Extended Properties=Excel 12.0;";
            Econ = new OleDbConnection(connstring);
        }
        private void ImportExcelData(string filepath)
        {
            ExcelConn(filepath);
            string query = "SELECT State,CircleName,RegionName,DivisionName,District,OfficeName,OfficeType,Delivery,Pincode FROM [AP_Postal_Data$]";
            OleDbCommand oleDbCommand = new OleDbCommand(query, Econ);
            OleDbDataAdapter oleDbDataAdapter = new OleDbDataAdapter(oleDbCommand);
            DataSet ds = new DataSet();

            oleDbDataAdapter.Fill(ds);

            Econ.Open();

            DbDataReader dbDataReader = oleDbCommand.ExecuteReader();
            SqlConnection dbconnection = new SqlConnection(ConfigurationManager.ConnectionStrings["DatabaseConnection"].ConnectionString);

            SqlBulkCopy sqlBulkCopy = new SqlBulkCopy(dbconnection);

            sqlBulkCopy.DestinationTableName = "Postal_Data_Staging";
            sqlBulkCopy.ColumnMappings.Add("State", "State");
            sqlBulkCopy.ColumnMappings.Add("CircleName", "CircleName");
            sqlBulkCopy.ColumnMappings.Add("RegionName", "RegionName");
            sqlBulkCopy.ColumnMappings.Add("DivisionName", "DivisionName");
            sqlBulkCopy.ColumnMappings.Add("District", "District");
            sqlBulkCopy.ColumnMappings.Add("OfficeName", "OfficeName");
            sqlBulkCopy.ColumnMappings.Add("OfficeType", "OfficeType");
            sqlBulkCopy.ColumnMappings.Add("Delivery", "Delivery");
            sqlBulkCopy.ColumnMappings.Add("Pincode", "Pincode");
      
            dbconnection.Open();
            sqlBulkCopy.WriteToServer(dbDataReader);
            dbconnection.Close();

            Econ.Close();
        }
    }
}