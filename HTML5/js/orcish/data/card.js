Orcish.register('Data.Card', Orcish.Data.Node.extend({
  
  key: null,
  setKey: null,
  name: null,
  tcgName: null,
  displayName: null,
  gathererId: null,
  manaCost: null,

  initialize: function(values) {
    this.super.initialize(values);
    this.displayName = this.displayName || this.name;
    this.tcgName = this.tcgName || this.name;
  }

}))