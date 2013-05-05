(function(){

  var NAME_HASH_SEPARATOR = '|'.charCodeAt(0);

  Orcish.register('Data.Manager', Orcish.extend({

    initialize: function(baseUrl) {
      this.baseUrl = baseUrl;
      this.dataQueue = new Orcish.Queue();
      loadSets(this);
      loadCardNameSearchBlob(this);
    },

    findCardStubsByTitle: function(text, callback) {
      var self = this;
      text = text.trim().toUpperCase().replace(/[^A-Z0-9_]/g, '');
      self.dataQueue.addJob(false, function(job) {
        var hashes = findNameHashesByText(self, text);
        var tracker = new Orcish.MediaTracker();
        for (var i = 0; i < hashes.length; i++) {
          tracker.add(self.baseUrl + '/data/names/' + hashes[i]);
        }
        tracker.start({
          success: function(data) {
            var cardStubs = transformRawCardStubs(data);
          },
          complete: function() {
            self.dataQueue.finished(job);
          }
        })
      })
    }

  }));

  function loadSets(self) {
    self.dataQueue.addJob(false, function(job) {
      Orcish.ajax({
        url: self.baseUrl + '/data/sets.txt', 
        success: function(text) {
          self.sets = transformRawSets(text);
        },
        complete: function() {
          self.dataQueue.finished(job);
        }
      })
    })
  }

  function transformRawSets(text) {    
    var sets = [ ];
    text.splitData().forEach(function(row) {
      if (row.length > 0) {
        sets.push(new Orcish.Data.Set({
          key: parseInt(row[0]), 
          name: row[1], 
          displayName: row[2], 
          tcgName: row[3], 
          format: row[4] ? parseInt(row[4]) : null,
          type: row[5] ? parseInt(row[5]) : null
        }))
      }
    })
    return sets;
  }

  function transformRawCardStubs(rawStubs) {
    var stubs = [ ];
    rawStubs.forEach(function(stub) {
      stub = stub.split("\t");
      stubs.push(new Orcish.Data.CardStub({
        key: parseInt(stub[0]),
        name: stub[1],
        displayName: stub[2],
        tcgName: stub[3],
        setKey: parseInt(stub[4]),
        setName: stub[5],
        setDisplayName: stub[6],
        setTcgName: stub[7],
        versionCount: stub[8] ? parseInt(stub[8]) : null
      }))
    })
    return stubs;
  }

  // ------------------------------------------------------------------------
  //  Search methods for a blob of card titles and hash values 
  //  e.g. |GIDEONJURA|123456|GIDEONSAVENGER|789012|...|

  function loadCardNameSearchBlob(self) {
    self.dataQueue.addJob(false, function(job) {
      Orcish.ajax({
        url: self.baseUrl + '/data/names.txt',
        responseType: 'ArrayBuffer',
        success: function(blob) {
          self.nameSearchBlob = blob;
        },
        complete: function() {
          self.dataQueue.finished(job);
        }
      })
    })
  }

  function findNameHashesByText(self, text) {
    var hashes = [ ];
    if (text.length < 3) {
      return hashes;
    }
    var view = new Uint8Array(self.nameSearchBlob);
    var offset = 0;
    text = ArrayBuffer.fromString(text);
    while (true) {
      var instance = self.nameSearchBlob.indexOf(text, offset);
      if (instance == -1) { break; }
      var hashStart = instance;
      while (view[hashStart] != NAME_HASH_SEPARATOR) { ++hashStart; }
      var hashEnd = ++hashStart;
      while (view[hashEnd] != NAME_HASH_SEPARATOR) { ++hashEnd; }
      offset = hashEnd;
      hashes.push(parseInt(String.fromArrayBuffer(self.nameSearchBlob.slice(hashStart, hashEnd))));
    }
    return hashes;
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
  //  Split text by rows and tabs

  String.prototype.splitData = function() {
    var result = [ ];
    var rows = this.split("\n");
    for (var i = 0; i < rows.length; i++) {
      if (rows[i] != '') {
        rows[i] = rows[i].split("\t");
        for (var j = 0; j < rows[i].length; j++) {
          rows[i][j] = rows[i][j] ? rows[i][j] : null;
        }
        result.push(rows[i]);
      }
    }
    return result;
  }

})()