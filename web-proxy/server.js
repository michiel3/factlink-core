/*
    Factlink
     
    A simple proxy server which will proxy requests
    
    Used for implementing Factlink JavaScript on 
    client-sites
*/

const PROXY_URL = "http://localhost:8080/";
const STATIC_URL = "http://localhost/";

// The actual server
var server = require('express').createServer();
var fs = require('fs');

// We're using Jade
server.set('view engine', 'jade');

server.get('/parse', function(req, res) {
  var site = req.query.url;

	// Quick fixes for visiting sites without http
	http_regex = new RegExp("^http(s?)");
	if (http_regex.test(site) === false) {
		// Not starting with http, so add:
		site = "http://" + site
	}

  console.info( "Serving: " + site );

  // The actual request using restler so we can follow redirects
  var req = require('restler').get( site );

  // When the request is finished, handle the response data

	req.on("error", function(data) {
		var html = "<html><body><span>An error occured when trying to visit " + site + ".<br/><br/>Please check the URL or <a href='http://www.google.com/'>do a web-search</a>.</span></body></html>";
		console.log("[ERROR] Faild on " + site);
		
		res.write( html );
		res.end(); 
	});
	
  req.on('complete', function(data) {
	
    // Replace the closing head tag with a base tag
    var html = data.replace('<head>', '<head><base href="' + site + '" />');
    html = html.replace('</head>', '<script src="' + STATIC_URL + 'proxy/scripts/proxy.js"></script></head>');

    // Write the replaced HTML to 
    res.write( html );
    res.end();
  });

});

server.get('/header', function(req, res) {
    res.render('header', {
        layout: false,
        locals: {
            static_url: STATIC_URL,
            url: req.query.url
        }
    });
});

server.get('/', function(req, res) {
    res.render('index', {
        layout: false,
        locals: {
            proxy_url: PROXY_URL,
            url: req.query.url
        }
    });
});

server.listen(8080);