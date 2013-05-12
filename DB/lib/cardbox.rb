# encoding: utf-8

class CardBox 
  
  include Orcish

  def initialize
    @by_set = { }
  end

  def add(set_name, cards)
    @by_set[set_name] = cards
  end

  def save_as_yaml(path)
    @by_set.each do |set_name, cards|
      set = MtgSet.find_by_name(set_name)
      FileUtils.mkdir_p("#{path}/#{set.key}")
      open("#{path}/#{set.key}/meta.yml", 'w') do |io|
        io.print set.to_yaml
      end
      cards.each do |card|        
        open("#{path}/#{set.key}/#{card.key}.yml", 'w') do |io| 
          io.print card.to_yaml
        end
      end
    end
  end
    
end