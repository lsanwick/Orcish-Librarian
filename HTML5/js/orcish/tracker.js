Orcish.register('MediaTracker', Orcish.extend({

  initialize: function() {
    this.resources = [ ];    
  },

  add: function(url, type, responseType) {
    this.resources.push({
      url: url,
      type: type,
      responseType: responseType
    });
  },

  start: function(options) {
    var responses = [ ];
    options.complete = options.complete || function(){};
    options.error = options.error || function(){};
    options.success = options.success || function(){};
    var firedError = false;
    var waiting = this.resources.length;
    this.resources.forEach(function(resource, idx) {
      Orcish.ajax({
        url: resource.url,
        type: resource.type,
        responseType: resource.responseType,
        error: function() {
          if (!firedError) {
            firedError = true;
            options.error(resource.url, idx);
          }
          if (--waiting == 0) { options.complete(responses) }
        },
        success: function(response) {
          responses[idx] = response;
          if (--waiting == 0) { 
            options.success(responses);
            options.complete(responses);
          }
        }
      })
    })
  }

}));

// --------------------------------------------------------------------------
//  AJAX helper

Orcish.register('ajax', function(options) {
  options = options || { };
  options.url = options.url || window.location.href;
  options.complete = options.complete || function(){};
  options.error = options.error || function(){};
  options.success = options.success || function(){};
  options.type = options.type || 'GET';
  options.responseType = options.responseType || 'text';
  var xhr = new XMLHttpRequest();
  xhr.open(options.type, options.url, true);
  xhr.responseType = options.responseType.toLowerCase();
  xhr.onreadystatechange = function() {
    if (xhr.readyState == 4) {
      if (xhr.status == 200) {
        options.success(xhr.response);
      } else {
        options.error();
      }
      options.complete();
    }
  }
  xhr.send(null);
});