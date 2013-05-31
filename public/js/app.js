
window.addEventListener("load", webPay, false);

var req;
var url;
function displayOutput(val) {
    alert("DISPLAYING: "+val);
    var sOut = val.replace(/</g,"&lt;").replace(/>/g,"&gt;");
    sOut = '<b>HTTP Status: </b>' + req.status + 
    '<br/><br/><b>Response Text:</b><br/>' + sOut;
    var ele = document.getElementById('contentContainer');
    if (ele) {
        ele.innerHTML = sOut;
    }
}

function handleResponse() {
    if (req.readyState === 4) {
        //FOR PLAYBOOK, NEED TO CHECK FOR STATUS=0 WHEN XHR REQUESTS ARE MADE TO LOCAL RESOURCES
        //	(NOT NECESSARY FOR SMARTPHONE, WHERE STATUS=200 WILL SUFFICE.
        if (req.status === 200 || req.status === 0)  {
            displayOutput(req.responseText);
        }
        else {
            displayOutput("Error (" + req.status + "): " + req.statusText);
        }
    }
}

function updateContent(url) {
    try {
        req = new XMLHttpRequest();
        req.open('GET', url, true);
        req.onreadystatechange = handleResponse;
        req.send(null);
    } 
    catch(e) {
        debug.log("updateContent", e, debug.exception);
    }
}

function updateContentPost(url,params) {
    try {
        var params = "parm1=123";
        req = new XMLHttpRequest();
        req.open('POST', url, false);
		
        //Send the proper header information along with the request
        req.setRequestHeader("Content-type", "application/x-www-form-urlencoded");
        req.setRequestHeader("Content-length", params.length);
        req.setRequestHeader("Connection", "close");

        req.onreadystatechange = handleResponse;
        req.send(params);
    } 
    catch(e) {
        debug.log("updateContentPost", e, debug.exception);
    }
}


function webPay(){
	//alert("DISPLAYING: ");
    //var params=urlArgs();
    //doTest1();
    var url="/api/v1/web_pay_data.js"
    getData(url,{transaction_id:"689804762"}, function(req){
        if (req.status === 200 || req.status === 0)  {
            alert("DISPLAYING: "+req.responseText);
            console.log("server",req.responseText);
             var data=eval(req.responseText);
             console.log(data);
            var ele = document.getElementById('contentContainer');
            if (ele) {
                ele.innerHTML = data.pay_data;
                var form=document.getElementById('web_pay');
                form.submit()
            }
            //displayOutput(req.responseText);
        }else{
            displayOutput("Error (" + req.status + "): " + req.statusText);
        }
    })
    /***
    if(params){
        showSpinner();
        var payment=JSON.parse(params.pay).payment
        var url=payment.url
        delete payment.url
        alert("POSTING TO: "+url);
        postData(url, payment, onWebPay);
    }**/
}

function doTest1(){
    var data={"status":"success","payment":{"product_id":"4223","pay_item_id":"101","amount":676700,"currency":"566","site_redirect_url":"http://poploda.com/notify","txn_ref":763216888,"site_name":"www.poploda.com","hash":"e5fb909ea08e296f18d79cb3727978a09d90161c0c96267a903dec486008d83453d9fbfa1e2483ef32b8c7763de3942d33ff13c102ba35da96036dcc473a46af","url":"https://webpay.interswitchng.com/paydirect/pay"}}
	
    var payment=data.payment
    url=payment.url
    delete payment.url
    alert("POSTING TO: "+url);
    postData(url, payment, onWebPay);}

function onWebPay(req){
    hideSpinner();
    if (req.status === 200 || req.status === 0)  {
        data=eval(req.responseText);
        // this.hideProgress();
        // this.hideLoadProgress();
        console.log(data)
        //displayOutput(req.responseText);
    }else{
        displayOutput("Error (" + req.status + "): " + req.statusText);
    }  
}

function urlArgs() {
    var args = {};
    var query = location.search.substring(1);
    var pairs = query.split("&");
    for(var i = 0; i < pairs.length; i++) {
        var pos = pairs[i].indexOf('=');
        if (pos == -1) continue;
        var name = pairs[i].substring(0,pos);
        var value = pairs[i].substring(pos+1);
        value = decodeURIComponent(value);
        args[name] = value;
    }
    return args;
}

function encodeFormData(data) {
    if (!data) return ""; // Always return a string
    var pairs = []; // To hold name=value pairs
    for(var name in data) {
        if (!data.hasOwnProperty(name)) continue;
        if (typeof data[name] === "function") continue;
        var value = data[name].toString();
        name = encodeURIComponent(name.replace(" ", "+"));
        value = encodeURIComponent(value.replace(" ", "+"));
        pairs.push(name + "=" + value); // Remember name=value pair
    }
    return pairs.join('&'); // Return joined pairs separated with & 
}

function postData(url, data, callback) { 
    var request = new XMLHttpRequest(); 
    request.open("POST", url); 
    request.onreadystatechange=function(){
        if (request.readyState === 4 && callback)
            callback(request);
    };
    request.setRequestHeader("Content-type", "application/x-www-form-urlencoded");
    encodedData=encodeFormData(data);
    request.setRequestHeader("Content-length", encodedData.length);
    request.setRequestHeader("Connection", "close");
    request.send(encodedData);
}

function getData(url, data, callback) {
    var request = new XMLHttpRequest();
    request.open("GET", url + "?" + encodeFormData(data)); 
    request.onreadystatechange = function() {
        if (request.readyState === 4 && callback) callback(request);
    };
    request.send(null);
}

function showSpinner(){
    var e = document.getElementById('spinner_drop');
    e.style.display = 'block';
}

function hideSpinner(){
    var e = document.getElementById('spinner_drop');
    e.style.display = "none";
}