var cheerio = require("cheerio");
var http = require("http");

// Utility function that downloads a URL and invokes
// callback with the data.
function download(url, callback) {
  http.get(url, function(res) {
    var data = "";
    res.on('data', function (chunk) {
      data += chunk;
    });
    res.on("end", function() {
      callback(data);
    });
  }).on("error", function() {
    callback(null);
  });
}

var url = "http://nodejs.org/changelog.html";

download(url, function(data) {
  if (data) {
    var $ = cheerio.load(data);
      console.log($("#apicontent > p > a")[0].attribs.id);
  } else console.log("error");  
});