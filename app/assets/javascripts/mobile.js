//= require json2
//= require_self

//window.addEventListener("load", webPay, false);
var Payment={
    notify:function(data){
        console.log("data",JSON.parse(data))
        //var result=JSON.stringify(data);
        //console.log("result",result)
    }
}
function webPay(){
    alert("ABOUT TO WEBPAY")
    var form=document.getElementById('web_pay');
    form.submit();
}

