Orcish.register('Data.Node', Orcish.extend({

  initialize: function(values) {
    this.setValues(values);
  },

  setValues: function(values) {
    var proto = Object.getPrototypeOf(this);
    for (var k in values) {
      if (values.hasOwnProperty(k)) {
        var setter = 'set' + k.slice(0,1).toUpperCase() + k.slice(1);
        if (typeof proto[setter] == 'function') {
          this[setter](values[k]);
        }
      }
    }
  }

}))