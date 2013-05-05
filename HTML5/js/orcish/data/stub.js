(function(){

  Orcish.register('Data.CardStub', Orcish.Data.Node.extend({

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

    setSetKey: function(setKey) {
      this.setKey = setKey;
    },

    setSetName: function(setName) {
      this.setName = setName;
    },

    setSetTcgName: function(setTcgName) {
      setTcgName && (this.setTcgName = setTcgName);
    },

    setSetDisplayName: function(setDisplayName) {
      setDisplayName && (this.setDisplayName = setDisplayName);
    },

    getKey: function() { return this.key },
    getName: function() { return this.name },
    getDisplayName: function() { return this.displayName || this.name },
    getTcgName: function(){ return this.tcgName || this.name },
    getSetKey: function() { return this.setKey },
    getSetName: function() { return this.setName },
    getSetDisplayName: function() { return this.setDisplayName || this.setName },
    getSetTcgName: function(){ return this.setTcgName || this.setName },

  }))

})()