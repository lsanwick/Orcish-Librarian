# encoding: utf-8

require 'gatherer'

class FetchManager
  
  include Orcish
  
  def initialize
    @gatherer = Gatherer.new
    @sets = @gatherer.sets
  end
    
  def sets
    @sets
  end
      
  def cards_for_set(set)
    cards = @gatherer.cards_for_set(set)        
  end
      
end