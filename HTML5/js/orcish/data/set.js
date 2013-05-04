(function(){

  var CORE_SET = 1;
  var EXPANSION_SET = 2;
  var SPECIAL_SET = 3;
  
  var FORMAT_STANDARD = 1;
  var FORMAT_MODERN = 2;
  var FORMAT_LEGACY = 3;


  Orcish.register('Data.Set', Orcish.Data.Node.extend({
    
    format: FORMAT_LEGACY,
    type: SPECIAL_SET,

    setKey: function(key) {
      this.key = key;
    },

    setName: function(name) {
      this.name = name;
    },

    setDisplayName: function(displayName) {
      displayName && (this.displayName = displayName);
    },

    setTcgName: function(tcgName) {
      tcgName && (this.tcgName = tcgName);
    },

    setFormat: function(format) { 
      format && (this.format = format);
    },

    setType: function(type) {
      type && (this.type = type);
    },

    getKey: function() { return this.key },
    getName: function() { return this.name },
    getDisplayName: function() { return this.displayName || this.name },
    getTcgName: function(){ return this.tcgName || this.name },
    getFormat: function(){ return this.format },
    getType: function(){ return this.type }

  }))

})()