/*
 * Small script, generate a server on port 7777, generate random
 * value and hash it with sha512.
 *
 */

// import function/module
var http = require('http');
var buffer = require('buffer');
var crypto = require('crypto');

//create server object
http.createServer(function (request, response) {

  // init object for crypto random
  var shasum = crypto.createHash('sha512');
  var buf = crypto.randomBytes(1024);

  // create sha512 hash with buf
  shasum.update(buf);

  // print shasumhash in hexa
  var digest = shasum.digest('hex');
  var content = digest;

  // build answer and add hexa sum into the end
  response.writeHead(200, {'Content-Type': 'text/plain'});
  response.end(content);

}).listen(7777);

// printing debug
console.log('Server running at http://127.0.0.1:7777/');
