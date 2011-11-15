var restler       = require('restler');

var API_URL,
    API_OPTIONS;
function set_API_URL(api_url) {
  API_URL = api_url;
}
function set_API_OPTIONS(api_options) {
  API_OPTIONS = api_options;
}

function if_allowed(url, successFn, errorFn) {
  var factlink_blacklist_url = API_URL + '/site/?url=' + encodeURIComponent(url);

  console.log(API_OPTIONS.username);
  console.log(API_OPTIONS.password);
  console.log('url: ' + factlink_blacklist_url);

  restler.get(factlink_blacklist_url, 
    { parser:   restler.parsers.json,
      username: API_OPTIONS.username,
      password: API_OPTIONS.password
  })
  .on('complete', function(data) {
    if (data.blacklisted !== true) {
      successFn();
    } else {
      errorFn();
    }
  })
  .on('error', function(data) {
    console.log("BARON CHERE DE LA PROBLEMOS!");
    // TODO: What should happen when a call to the blacklist API fails?
    succesFn();
  });
}

exports.set_API_URL = set_API_URL;
exports.set_API_OPTIONS = set_API_OPTIONS;
exports.if_allowed = if_allowed;
