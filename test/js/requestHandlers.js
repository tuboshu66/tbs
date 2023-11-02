var querystring = require("querystring");
var fs = require("fs");

function getText(response) {
    var text = "Winnie the Witch";
    console.log(text);
    response.writeHead(200, {"Content-Type": "text/plain"});
    response.write(text);
    response.end();
}

function getImage(response) {
    console.log("getImage");
    fs.readFile("./images/abracadabra.jpg", "binary", function(error, file) {
        if(error) {
          response.writeHead(500, {"Content-Type": "text/plain"});
          response.write(error + "\n");
          response.end();
        } else {
          response.writeHead(200, {"Content-Type": "image/jpg"});
          response.write(file, "binary");
          response.end();
        }
    });
}

function getBigImage(response) {
    console.log("getBigImage");
    fs.readFile("./images/view.jpg", "binary", function(error, file) {
        if(error) {
          response.writeHead(500, {"Content-Type": "text/plain"});
          response.write(error + "\n");
          response.end();
        } else {
          response.writeHead(200, {"Content-Type": "image/jpg"});
          response.write(file, "binary");
          response.end();
        }
    });
}

function get(query, response) {
    console.log("query: " + query);
    var queryObj = querystring.parse(query);
    for (key in queryObj) {
        console.log("key: " + key + ", value: " + queryObj[key]);
    }
    var type = queryObj["type"];
    switch(type) {
        case "text":
            getText(response);
        break;

        case "image":
            getImage(response);
        break;

        case "bigimage":
            getBigImage(response);
        break;

        default:
            var text = "type " + type + " is unknown.";
            console.log(text);
            response.writeHead(200, {"Content-Type": "text/plain"});
            response.write(text);
            response.end();
        break;
    }
}

function hello(query, response) {
    console.log("Hello World");
    response.writeHead(200, {"Content-Type": "text/plain"});
    response.write("Hello World");
    response.end();
}

function read(query, response){
console.log('程序开始运行');
fs.readFile('/usr/local/nginx/mjnginx.conf',function(err,data){
    if(err){
        return console.log(err);
    }
    console.log(data.toString());
});
console.log('程序结束运行');
}

exports.get = get;
exports.hello = hello;
exports.read = read
