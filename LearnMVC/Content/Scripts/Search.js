
//$(document).ready(function () {
//    $("#btnlookuppincode").click(function () {
//        var pincode = $('#ConsignerPincode').val();
//        $.ajax({
//            cache: 'false',
//            type: "POST",
//            data: { pincode: pincode },
//            url: '@Url.Action("LookUpPincode", "Search")',
//            dataType: 'json',  // add this line
//            "success": function (data) {
//                if (data != null) {
//                    var vdata = data;
//                    $("#ConsignerState").val(vdata[0].StateName);
//                    //$("#FName").val(vdata[0].FatherName);
//                    //$("#Phone").val(vdata[0].Phone1);
//                }
//            }
//        });
//    });
//});