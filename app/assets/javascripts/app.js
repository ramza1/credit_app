//= require json2
//= require_self

function setOrientation() {
    //TODO: Calculate the 'right' header and footer heights for the current orientation/perspective.
    //	use hardcoded values for now.
    var headerHeight = 50, footerHeight = 50, header, content, footer;

    //set the height of the header:
    header = document.getElementById("header");
    if (header) {
        header.style.height = headerHeight + "px";
    }		
    //set the height of the content panel
    content = document.getElementById("content");
    if (content) {
        content.style.height = (window.innerHeight - headerHeight - footerHeight) + "px";
    }
    //set the height of the footer:
    footer = document.getElementById("footer");
    if (footer) {
        footer.style.height = footerHeight + "px";
    }			
}

window.addEventListener("orientationchange", setOrientation, false);
window.addEventListener("load", setOrientation, false);

var req;

function displayOutput(val) {
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

function webPay(data){
    var params=JSON.parse(data);
    var url=params.url
    delete params.url
    postData(url, params, onWebPay);
    showSpinner();
}

function onWebPay(req){
    hideSpinner();
    if (req.status === 200 || req.status === 0)  {
        displayOutput(req.responseText);
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
    e.style.display = "block";
}

function hideSpinner(){
    var e = document.getElementById('spinner_drop');
    e.style.display = "none";
}