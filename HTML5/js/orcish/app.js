
Orcish.register('App', Orcish.extend({

  initialize: function() {    
    this.basicSearch = new Orcish.View.BasicSearch(this);
    this.attachScrollEvents();
  },

  attachScrollEvents: function() {
    $(document).on('touchmove', '.unscrollable', function(event){
      event.preventDefault();
    })
    .on('focus', 'input[type=text]', function(){
      $(document.body).addClass('unscrollable');
    })
    .on('blur', 'input[type=text]', function(){
      $(document.body).removeClass('unscrollable');
    });
  },

  pushView: function(view) {

  },

  popView: function() {

  },

  toggleMenu: function() {
    if (this.isMenuVisible) {
      this.isMenuVisible = false;
      $(document.body).removeClass('menuOut');
    } else {
      this.isMenuVisible = true;
      $(document.body).addClass('menuOut');
    }
  }


}))