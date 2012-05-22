(function() {

    function $$(selector, el) {
        if (!el) { el = document }
        return Array.prototype.slice.call(el.querySelectorAll(selector));
    }

    function $(selector, el) {  
         if (!el) { el = document }
         return el.querySelector(selector);
    }
    
    var prices = [ ];
    var rows = $$('table.price_list_sh tr.default_8');
    for (var i = 0; i < rows.length; i++) {
        var row = rows[i];
        try {
            prices.push({
                'storeName':    $('a', $('td:nth-child(2)', row)).innerText,
                'storeId':      $('a', $('td:nth-child(2)', row)).href.replace(/^.*seller=([^&]*).*$/, '$1'),
                'condition':    $('td:nth-child(4)', row).innerText,
                'quantity':     $('td:nth-child(5)', row).innerText,
                'price':        $('td:nth-child(6)', row).innerText.replace(/^\$([0-9,\.]*)(.|\s)*$/, '$1')
            });
        }
        catch (e) {
            // not much we can do here
            // TODO: bubble up an error to the app's analytics
        }
    }
    
    // todo: notify app that we're done
    window.location = 'done://loading';
    window._orcish_librarian_prices = prices;
    
})();

// javascript:(function(){ var s = document.createElement('script'); s.src = 'http://direct.orcish.info/librarian/prices.js'; document.getElementsByTagName('head')[0].appendChild(s); })()

