(function(){

  Orcish.register('Data.Manager', Orcish.extend({

    initialize: function(baseUrl) {
      this.baseUrl = baseUrl;
    },

    loadCard: function(key, callback) {

    },

    loadSet: function(key, callback) {
      loadText(baseUrl)
    },

    findCardsByTitle: function(text, callback) {
      
    },    

    findNameHashesByText: function(text) {
      /*
      var hashes = [ ];
      var view = new Uint8Array(this.cardTitleSearchBlob);
      var scope = { start: 0, length: view.length };
      var separator = '|'.charCodeAt(0);
      text = ArrayBuffer.fromString(text);
      while (true) {
        var instance = this.cardTitleSearchBlob.indexOf(text, scope.start, scope.length);
        if (instance == -1) { break; }
        var hashStart = instance;            
        while (view[hashStart] != separator) { ++hashStart; }
        var hashEnd = ++hashStart;
        while (view[hashEnd] != separator) { ++hashEnd; }
        scope.start = hashEnd;
        scope.length = view.length - hashEnd;
        hashes.push(parseInt(this.cardTitleSearchBlob.slice(hashStart, hashEnd).toString()));
      }
      return hashes;
      */
    }

  }));

  
  // ------------------------------------------------------------------------
  //  Boyer–Moore–Horspool string searches in ArrayBuffer

  ArrayBuffer.prototype.indexOf = function(needle, start, length) {
    start = typeof start == 'number' ? start : 0;
    length = typeof length == 'number' ? length : (this.byteLength - start);
    var needleView = new Uint8Array(needle, 0, needle.byteLength);
    var haystackView = new Uint8Array(this, start, length);
    return memmem(needleView, haystackView) + start;
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

})()