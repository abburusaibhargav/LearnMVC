//$(document).ready(function () {
//    $("#OfficeName").autocomplete({
//        source: function (request, response) {
//            $.ajax({
//                url: '/Consignment/SearchOffice/',
//                data: "{'OfficeName': '" + request.term + "'}",
//                dataType: "json",
//                type: "POST",
//                contentTycontentType: "application/json; charset=utf-8",
//                success: function (data) {
//                    response($.map(data, function (item) {
//                        return item;
//                    }))
//                },
//                error: function (response) {
//                    alert(response.responseText);
//                },
//                failure: function (response) {
//                    alert(response.responseText);
//                }
//            });
//        },
//        select: function (e, i) {
//            $("#hfOfficeID").val(i.item.val);
//        },
//        minLength: 1
//    });
//});


//$(document).ready(function () {
//    $("#ConsignerStateID").change(function () {
//        $.get("/Consignment/GetCircleDataDDL", { StateID: $("#ConsignerStateID").val() },
//            function (data) {
//                $("#CircleID").empty();
//                $.each(data, function (index, row) {
//                    $("#CircleID").append("<option value='" + row.CircleID + "'>" + row.CircleName + "</option>")
//                });
//            });
//    })
//});
