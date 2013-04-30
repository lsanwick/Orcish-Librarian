Orcish.register('View.BasicSearch', Orcish.extend({

  initialize: function(app) {
    this.app = app;
    this.dataSource = app.getDataSource();
    this.searchInput = $('#basicSearch input[name=search]');
    this.searchPrompt = $('#basicSearch .prompt');
    this.attachSearchBarEvents();
    this.attachTapEvents();
    this.setInitialFocus();
  },

  attachSearchBarEvents: function() {
    $('#basicSearch input[name=search]').on('input', this.handleSearchTextChange.bind(this));
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

  handleSearchTextChange: function() {
    var searchText = this.searchInput.val().trim()
    if (searchText.length > 0) {
      this.searchPrompt.hide();
    } else {
      this.searchPrompt.show();
    }
    this.setSearchText(searchText); 
  },

  setInitialFocus: function() {
    // grrr, stupid iOS
    // for this to work, we have to set a property of the UIWebView
    // setKeyboardDisplayRequiresUserAction
    // ... but it will never work in Safari :(
  },

  setSearchText: function(text) {
    var self = this;
    self.dataSource.findCardsByTitle(text, {
      success: function(cards) {
        self.setCards(cards);
      },
      failure: function(errorCode) {
        // TODO: should there be an error handler here?
        // what are the possible error conditions? 
        //  - network failure
        //  -  
      }
    });
  },

  setCards: function(cards) {     
    var self = this;
    var results = $('<div class="results" />');
    $.each(cards, function() {
      var row = self.createCardResultRow(this);
      results.append(row);
    });
    $('#basicSearch .results').replaceWith(results);
  },

  createCardResultRow: function(card) {
    return $('<div class="cardResult">' +
        '<div class="cardTitle">' + h(card.title) + '</div>' + 
        '<div class="setTitle">' + h(card.setTitle) + '</div>' +
        '<div class="prices"></div>' +
      '</div>');
  }

}));