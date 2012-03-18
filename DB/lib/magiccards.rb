
require 'sources/source'

class MagicCards < Source

  def fetch_sets
    sets = [ ]
    doc = fetch_document('http://magiccards.info/search.html')
    doc.search("select[@id=edition] option:not([@value=''])").each do |option|
      sets << { 
        :name => option.inner_text, 
        :key => option['value'].gsub(/\/en$/, '') 
      }
    end
    sets
  end
  
end
