using System;
using System.Collections.Generic;
using System.Linq;
using System.Web;
using System.Web.Mvc;
using LearnMVC.Models;

namespace LearnMVC.Controllers
{
    public class ProductController : Controller
    {
        AppDataConnectionEntity connectionEntity = new AppDataConnectionEntity();
        public ActionResult Index()
        {
            var products = connectionEntity.GetProducts("products").ToList();            
            ViewBag.ProductsCount = products.Count();
            if (products.Count > 0)
            {
                ViewBag.Products = products;
            }
            return View();
        }

        public ActionResult Presentations()
        {
            return View();
        }
    }
}