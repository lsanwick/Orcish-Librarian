Orcish.register('View.BasicSearch', Orcish.extend({

  initialize: function(app) {
    this.app = app;
    this.attachSearchBarEvents();
    this.attachTapEvents();
  },

  attachSearchBarEvents: function() {
      
  },

  attachTapEvents: function() {
    tappable('#basicSearch .navButton', { noScroll: true, onTap: this.handleNavTap.bind(this) });
    tappable('#basicSearch .cardResult', { activeClassDelay: 150, onTap: this.handleResultTap.bind(this) });
  },

  handleNavTap: function() {
    this.app.toggleMenu();
  },

  handleResultTap: function() {
    console.log('Result');
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