# encoding: utf-8

require 'gatherer'

class FetchManager
  
  include Orcish
  
  def initialize
    @gatherer = Gatherer.new
  end

  def fetch(name)
    set = MtgSet.new(name)
    set.add(@gatherer.cards_for_set(name))
    set
  end

end