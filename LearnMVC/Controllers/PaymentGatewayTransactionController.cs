using System;
using System.Collections.Generic;
using System.Configuration;
using System.Linq;
using System.Security.Cryptography;
using System.Text;
using System.Web;
using System.Web.Mvc;
using LearnMVC.Models;

public class PaymentGatewayTransactionController : Controller
{
    AppDataConnectionEntity connectionEntity = new AppDataConnectionEntity();
    
    [HttpGet]
    public ActionResult PaymentPage()
    {
        return View();
    }

    [HttpPost]
    public void PaymentPage(PaymentModel payment)
    {
        try
        {
            string firstname = payment.fname;
            string amount = payment.itemamount;
            string productinfo = payment.iteminfo;
            string email = payment.email;
            int phone = 97915;

            string surl = ConfigurationManager.AppSettings["paysuccessurl"].ToString();
            string furl = ConfigurationManager.AppSettings["payfailureurl"].ToString();
            string key = ConfigurationManager.AppSettings["MERCHANT_KEY"].ToString();
            string salt = ConfigurationManager.AppSettings["MERCHANT_SALT"].ToString();
            string txnid = Generatetransid();
            string serviceprovider = "payu_paisa";

            connectionEntity.RecordPaymentDetails(txnid, "", firstname, amount, email, phone.ToString(), "PAY U", serviceprovider, "");

            RemotePost remotepay = new RemotePost();

            remotepay.Url = ConfigurationManager.AppSettings["PAYU_BASE_URL"].ToString();
            remotepay.Add("key", key);
            remotepay.Add("txnid", txnid);
            remotepay.Add("amount", amount);
            remotepay.Add("firstname", firstname);
            remotepay.Add("productinfo", productinfo);
            remotepay.Add("email", email);
            remotepay.Add("phone", phone.ToString());
            remotepay.Add("surl", surl);
            remotepay.Add("furl", furl);
            remotepay.Add("service_provider", serviceprovider);
   
            string hashtext = key + "|" + txnid + "|" + amount + "|" + productinfo + "|" + firstname + "|" + email + "|||||||||||" + salt;
            string hash = Generatehashid(hashtext);
            remotepay.Add("hash", hash);

            remotepay.Post();
        }
        catch (Exception)
        {
            throw;
        }
    }

    public ActionResult PaymentStatus(FormCollection form)
    {
        try
        {
            string merc_hash_string = string.Empty;
            string merc_hash = string.Empty;
            string order_id = string.Empty;
            string hash_seq = ConfigurationManager.AppSettings["hashSequence"].ToString();

            if(form["status"].ToString() == "success")
            {
                connectionEntity.RecordPaymentDetails(
                    Request.Form["txnid"],
                    "",
                    Request.Form["firstname"],
                    Request.Form["amount"],
                    Request.Form["email"],
                    Request.Form["phone"],
                    "PAY U",
                    "payu_paisa",
                    "Payment Successful");

                ViewBag.Name = Request.Form["firstname"];
                ViewBag.Amount = Request.Form["amount"];
                ViewBag.OrderID = Request.Form["txnid"];
                ViewBag.Transtatus = "Payment is successful";
                //}
            }
            else
            {
                ViewBag.Transtatus = "Payment is failed";
                Response.Write("Hash value did not matched");
            }
        }
        catch(Exception ex)
        {
            Response.Write("<span style='color:red'>" + ex.Message + "</span>");
        }
        return View();
    }
    #region TxnID and Hash Request Method
    private string Generatetransid()
    {
        Random random = new Random();
        string hash = Generatehashid(random.ToString() + DateTime.Now);
        string transid = hash.ToString().Substring(0, 30);

        return transid;
    }
    private string Generatehashid(string text)//Generate Hash 512
    {
        string hex = "";
        byte[] message = Encoding.UTF8.GetBytes(text);

        UnicodeEncoding unicode = new UnicodeEncoding();
        SHA512Managed hashstring = new SHA512Managed();
        byte[] hashvalue;
        hashvalue = hashstring.ComputeHash(message);

        foreach (byte x in hashvalue)
        {
            hex += String.Format("{0:x2}", x);
        }

        return hex;
    }
    #endregion

    #region Payment - Post Method
    public class RemotePost
    {
        private System.Collections.Specialized.NameValueCollection Collection = new System.Collections.Specialized.NameValueCollection();

        public string Url = "";
        public string Method = "post";
        public string FormName = "PaymentPage";

        public void Add(string name, string value)
        {
            Collection.Add(name, value);
        }

        public void Post()
        {
            System.Web.HttpContext.Current.Response.Clear();
            System.Web.HttpContext.Current.Response.Write("<html><head>");

            System.Web.HttpContext.Current.Response.Write(string.Format("</head><body onload=\"document.{0}.submit()\">", FormName));
            System.Web.HttpContext.Current.Response.Write(string.Format("<form name=\"{0}\" method=\"{1}\" action=\"{2}\" >", FormName, Method, Url));

            for (int i = 0; i < Collection.Keys.Count; i++)
            {
                System.Web.HttpContext.Current.Response.Write(
                    string.Format("<input name=\"{0}\" type=\"hidden\" value=\"{1}\">",
                    Collection.Keys[i], Collection[Collection.Keys[i]])
                    );
            }

            System.Web.HttpContext.Current.Response.Write("</form>");
            System.Web.HttpContext.Current.Response.Write("</body></html>");

            System.Web.HttpContext.Current.Response.End();
        }
    }

    #endregion 

    private string EncodeDecode(string text, string Type)
    {

        string result = "";
        if(Type == "Encode")
        {
            byte[] message = Encoding.UTF8.GetBytes(text);

            UnicodeEncoding unicode = new UnicodeEncoding();
            SHA512Managed hashstring = new SHA512Managed();
            byte[] hashvalue;

            hashvalue = hashstring.ComputeHash(message);
            foreach (byte x in hashvalue)
            {
                result += String.Format("{0:x2}", x);
            }
        }
        
        return result;
    }
}
