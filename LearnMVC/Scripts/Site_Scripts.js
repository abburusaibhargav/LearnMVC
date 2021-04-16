$("#btnsubmit").click(function () {
    $("#divloader").show();
    $.ajax({
        url: '~/Account/Login',
        type: "post",
        data: {},
        success: function (data) {
            $("#divloader").hide();
        },
        error: function (xhr) {
            $("#divloader").hide();
        }
    })
});