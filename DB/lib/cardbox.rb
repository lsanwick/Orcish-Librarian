# encoding: utf-8

class CardBox 
  
  include Orcish

  def initialize
    @sets = [ ]
  end

  def add(set)
    @sets << set
  end

  def save_as_yaml(path)
    @sets.each do |set|
      FileUtils.mkdir_p(path + '/' + set.name)
      set.cards.each do |card|
        open("#{path}/#{set.name}/#{card.key}.yml", 'w') do |io| 
          io.print card.to_yaml
        end
      end
    end
  end
    
end