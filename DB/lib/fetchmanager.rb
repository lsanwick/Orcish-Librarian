
require 'gatherer'

class FetchManager
  
  include Orcish
  
  def initialize
    @gatherer = Gatherer.new
  end
  
  def sets
    @gatherer.sets
  end
  
  def cards_for_set(set)
    cards = @gatherer.cards_for_set(set)        
  end
      
end