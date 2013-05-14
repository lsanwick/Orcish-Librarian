(function(){

  var NAME_SEPARATOR = '|'.charCodeAt(0);

  Orcish.register('Data.Manager', Orcish.extend({

    initialize: function(baseUrl) {
      this.baseUrl = baseUrl;
      this.dataQueue = new Orcish.Queue();
      loadSets(this);
      loadCardNameSearchBlob(this);
    },

    findCardsByText: function(text) {
      var self = this;
      self.dataQueue.addJob(false, function(job) {
        var names = findNamesByText(self, normalizeTextForSearch(text));
        names = sortNamesByAppearanceOfSearchText(names, text);
        console.log(names);
        self.dataQueue.finished(job);
      })
    }

  }));

  function loadSets(self) {
    self.dataQueue.addJob(false, function(job) {
      Orcish.ajax({
        url: self.baseUrl + '/db/sets.json', 
        success: function(text) {
          self.sets = [ ];
          $.parseJSON(text).forEach(function(rawSet) {
            self.sets.push(new Orcish.Data.Set(rawSet));
          })
        },
        complete: function() {
          self.dataQueue.finished(job);
        }
      })
    })
  }

  // ------------------------------------------------------------------------
  //  Search methods for a blob of card titles and hash values 
  //  e.g. |gideonjura|123456|GIDEONSAVENGER|789012|...|

  function loadCardNameSearchBlob(self) {
    self.dataQueue.addJob(false, function(job) {
      Orcish.ajax({
        url: self.baseUrl + '/db/names.blob',
        responseType: 'ArrayBuffer',
        success: function(blob) {
          self.namesBlob = blob;
        },
        complete: function() {
          self.dataQueue.finished(job);
        }
      })
    })
  }

  function findNamesByText(self, text) {
    var names = [ ];
    if (text.length < 3) {
      return names;
    }
    var view = new Uint8Array(self.namesBlob);
    var offset = 0;
    text = ArrayBuffer.fromString(text);
    while (true) {
      var instance = self.namesBlob.indexOf(text, offset);
      if (instance == -1) { break; }
      var nameStart = instance;
      var nameEnd = instance;
      while (view[nameStart] != NAME_SEPARATOR) { --nameStart; }
      while (view[nameEnd] != NAME_SEPARATOR) { ++nameEnd; }
      offset = nameEnd;
      names.push(String.fromArrayBuffer(self.namesBlob.slice(nameStart + 1, nameEnd)));
    }
    return names;
  }

  // ------------------------------------------------------------------------
  //  Boyer–Moore–Horspool string searches in ArrayBuffer

  ArrayBuffer.prototype.indexOf = function(needle, start, length) {
    start = typeof start == 'number' ? start : 0;
    length = typeof length == 'number' ? length : (this.byteLength - start);
    var needleView = new Uint8Array(needle, 0, needle.byteLength);
    var haystackView = new Uint8Array(this, start, length);
    var idx = memmem(needleView, haystackView);
    if (idx == -1) {
      return -1;
    } else {
      return idx + start;
    }
  }

  function memmem(needle, haystack) {
    var idx = 0;
    var hLength = haystack.byteLength;
    var nLength = needle.byteLength;
    var last = nLength - 1;
    var badCharacters = new Uint8Array(256);
    for (var i = 0; i < badCharacters.length; i++) {
      badCharacters[i] = nLength;
    }
    for (var i = 0; i < last; i++) {
      badCharacters[needle[i]] = last - i;
    }
    while (hLength >= nLength) {
      for (var i = last; haystack[idx+i] == needle[i]; i--) {
        if (i == 0) {
          return idx;
        }
      }
      hLength -= badCharacters[haystack[idx + last]];
      idx += badCharacters[haystack[idx + last]];
    }
    return -1;
  }

  // ------------------------------------------------------------------------
  //  Create a UTF-8 ArrayBuffer from a JavaScript string

  ArrayBuffer.fromString = function(string) {
    var encoded = unescape(encodeURIComponent(string));
    var buffer = new ArrayBuffer(encoded.length);
    var view = new Uint8Array(buffer);
    for (var i = 0; i < encoded.length; i++) {
      view[i] = encoded.charCodeAt(i);
    }
    return buffer;
  }

  // ------------------------------------------------------------------------
  //  Create a JavaScript string from a UTF-8 ArrayBuffer

  String.fromArrayBuffer = function(buffer) {    
    var view = new Uint8Array(buffer);
    var encodedBytes = new Array(view.length);
    for (var i = 0; i < view.length; i++) {
      encodedBytes[i] = String.fromCharCode(view[i]);
    }
    return decodeURIComponent(escape(encodedBytes.join('')));
  }

  // ------------------------------------------------------------------------
  //  Normalize text for search (no special characters, all lower-case, etc.)

  function normalizeTextForSearch(text) {
    return text.toLowerCase().replace(/[^a-z0-9_]/, '');
  }

  function sortNamesByAppearanceOfSearchText(names, text) {
    var indexes = { };
    for (var i = 0; i < names.length; i++) {
      indexes[names[i]] = names[i].indexOf(text);      
    }
    return names.sort(function(a, b) {
      if (indexes[a] == indexes[b]) {
        return 0;
      } else if (b == -1 || a < b) {
        return -1;
      } else {
        return 1;
      }
    })
  }

})()