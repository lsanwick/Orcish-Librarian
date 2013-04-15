Orcish.register('View.BasicSearch', Orcish.extend({

  initialize: function(app) {
    this.app = app;
    this.searchInput = $('#basicSearch input[name=search]');
    this.searchPrompt = $('#basicSearch .prompt');
    this.attachSearchBarEvents();
    this.attachTapEvents();
  },

  attachSearchBarEvents: function() {
    var self = this;      
    $('#basicSearch input[name=search]')
      .on('input', this.handleSearchTextChange.bind(this))
      .on('focus', this.handleSearchTextFocus.bind(this))
      .on('blur', this.handleSearchTextBlur.bind(this));
  },

  attachTapEvents: function() {
    var self = this;
    tappable('#basicSearch .navButton', { noScroll: true, onTap: function(){ self.handleNavTap() } });
    tappable('#basicSearch .cardResult', { activeClassDelay: 150, onTap: function(){ self.handleResultTap(this) } });
  },

  handleNavTap: function() {
    this.app.toggleMenu();
  },

  handleResultTap: function(row) {
    console.log('Result');
  },

  handleSearchTextFocus: function() {

  },

  handleSearchTextBlur: function() {

  },

  handleSearchTextChange: function() {
    if (this.searchInput.val().trim().length > 0) {
      this.searchPrompt.hide();
    } else {
      this.searchPrompt.show();
    }
  }

}));
/*
$ ->

  $(document).on 'touchmove', (e) ->
    e.preventDefault

  view = $('#basicSearch');

  tappable '#basicSearch .menuButton', noScroll: true, onTap: ->
    console.log('MENU') 

  bar = $ '.searchBar', view
  input = $ '.searchInput', bar
  prompt = $ '.searchPrompt', bar
  initialPromptText = prompt.val
  results = $ '.results', view

  # hide & show the search field 'prompt' appropriately
  input.focus ->
    bar.addClass 'focus'

  input.blur ->
    bar.removeClass 'focus'

  input.on 'input', ->
    if this.value == ''
      bar.removeClass 'textEntered'
    else
      bar.addClass 'textEntered'

  # results rows
  tappable '#basicSearch .cardResult', 
    activeClassDelay: 150, 
    onTap: (x, y) ->
      console.log(y);
  
*/