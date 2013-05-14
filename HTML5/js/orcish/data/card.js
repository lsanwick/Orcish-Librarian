Orcish.register('Data.Card', Orcish.Data.Node.extend({

  setName: function(name) {
    this.name = name;
  },

  setDisplay: function(display) {
    display && (this.display = display);
  },

  setTcg: function(tcg) {
    tcg && (this.tcg = tcg);
  },

  getName: function() { return this.name },
  getDisplay: function() { return this.display || this.name },
  getTcg: function(){ return this.tcg || this.name }

}))