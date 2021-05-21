using System;
using System.Collections.Generic;
using System.Linq;
using System.Net.Mail;
using System.Web;
using System.Web.Mvc;
using LearnMVC.Models;

namespace LearnMVC.Controllers
{
    public class MessagesController : Controller
    {
        AppDataConnectionEntity connectionEntity = new AppDataConnectionEntity();
        public ActionResult ViewMessages()
        {
            var allmessages = connectionEntity.GetMessages(Session["UserID"].ToString()).ToList();
            var replyrequested = connectionEntity.GetMessages(Session["UserID"].ToString()).Where(x => x.ReplyRequired == true).ToList();
            var fyimessages = connectionEntity.GetMessages(Session["UserID"].ToString()).Where(x => x.Acknowledged == false).ToList();

            ViewBag.allmsgcount = allmessages.Count();
            ViewBag.replycount = replyrequested.Count();
            ViewBag.fyicount = fyimessages.Count();

            ViewBag.allmessages = allmessages;
            ViewBag.replyrequested = replyrequested;
            ViewBag.fyi = fyimessages;

            return View();
        }

        [HttpPost]
        public ActionResult Send(string request, MailSystemModel mail, Message message)
        {
            if(mail.Receivermailid != null)
            {
                if (ModelState.IsValid)
                {
                    try
                    {
                        MailMessage mailMessage = new MailMessage();
                        mailMessage.To.Add(mail.Receivermailid);
                        mailMessage.Subject = "Ad-hoc Mail";
                        mailMessage.From = new MailAddress("abburusaibhargav@gmail.com", "AVSSB - Learn MVC");
                        mailMessage.Body = mail.MailBody + "<br/>" +
                            "<br/>" +
                            "Regards,<br />" +
                            "AVSSB - Learn MVC<br/>" +
                            "This is system generated mail. Replies to this inbox are not monitored.";
                        mailMessage.IsBodyHtml = true;
                        SmtpClient smtpClient = new SmtpClient();
                        smtpClient.Send(mailMessage);

                        ViewBag.Message = "Mail Sent Successfully..!";
                    }
                    catch
                    {
                        ViewBag.Message = "Mail Sending Failed..!";
                        return RedirectToAction("Index", "Home");
                    }


                }
                return RedirectToAction("Index", "Home");
            }

            if (message.SenderID != null)
            {
                if(request == "new")
                {
                    string msg = message.Message1;
                    string senderid = Session["UserID"].ToString();
                    string receiverid = message.ReceiverID;
                    string subject = message.MessageSubject;

                    var results = connectionEntity.CreateandReplyMessages(request, null, senderid, receiverid, subject, msg, message.ReplyRequired,null,null).ToList();
                    ViewBag.Status = results;
                }
            }

            return RedirectToAction("Index", "Home");
        }

        [HttpPost]
        public ActionResult Acknowledge(string messageid,bool Acknowledged)
        {
            string action = "acknowledge";
            string senderid = Session["UserID"].ToString();

            var results = connectionEntity.CreateandReplyMessages(action, messageid, senderid, "", "", "", null, Acknowledged, "").ToList();
            ViewBag.Status = results;
            
            
            return RedirectToAction("ViewMessages", "Messages");
        }
    }
}