(function(){

  var currentFocus = $();

  Orcish.register('App', Orcish.extend({

    initialize: function() {    
      this.dataSource = new Orcish.Data.LocalSource(this);
      this.basicSearch = new Orcish.View.BasicSearch(this);
      this.attachScrollEvents();
    },

    attachScrollEvents: function() {
    
      document.body.style.height = screen.height + 'px';
      setTimeout(function() {
        window.scrollTo(0, 0);
        //document.body.style.height = '100%';
      }, 1);

    $('input,select').bind('focus',function(e) { 
      $('html, body').animate({scrollTop:0,scrollLeft:0}, 'slow'); 
    });

      $(document).on('touchstart', function(event) {
        // currentFocus.blur();
      })      
      .on('focus', 'input[type=text]', function() {
        // currentFocus = $(this);
        // window.scrollTo(0, 0);
        // setTimeout(function(){ window.scrollTo(0,0) }, 1  );
        // $(document.body).addClass('unscrollable');
      })
      .on('blur', 'input[type=text]', function() {
        // currentFocus = $();
        // $(document.body).removeClass('unscrollable');
      });
    },

    getDataSource: function() {
      return this.dataSource;
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

  }));

})()