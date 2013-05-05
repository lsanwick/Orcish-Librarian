
// --------------------------------------------------------------------------
//  Base Orcish class system

Orcish = {  

  register: function(namespace, object) {
    object = object || { };
    var spaces = namespace.split('.');
    var node = this;
    while (spaces.length > 0) {
      var space = spaces.shift();
      if (spaces.length > 0) {
        node[space] = node[space] || { };
      } else {
        node[space] = object;
      }
      node = node[space];
    }
  },

  extend: function(prototype) {
    if (typeof prototype.super != 'undefined') {
      throw "Cannot use reserved name 'super' in class definition.";
    }
    prototype.initialize = prototype.initialize || 
      function(){ this.super && this.super.initialize && this.super.initialize.apply(this, arguments) };
    var Object = function(){ prototype.initialize.apply(this, arguments) };
    Object.prototype = { };
    for (var k in this) {
      if (this.hasOwnProperty(k) && typeof this[k] == 'function') {
        Object[k] = this[k];
      }
    }
    prototype.super = this.prototype || { intitialize: prototype.initialize };
    $.extend(Object.prototype, prototype.super, prototype);
    return Object;
  }

};

// --------------------------------------------------------------------------

function h(text) {
  return String(text)
    .replace(/&/g, '&amp;')
    .replace(/"/g, '&quot;')
    .replace(/'/g, '&#39;')
    .replace(/</g, '&lt;')
    .replace(/>/g, '&gt;');
}

