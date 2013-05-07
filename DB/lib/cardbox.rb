# encoding: utf-8

require 'yaml'

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
          YAML.dump(card.to_hash, io) 
        end
      end
    end
  end
    
end


class Array
  def to_yaml_style
    :inline
  end
end