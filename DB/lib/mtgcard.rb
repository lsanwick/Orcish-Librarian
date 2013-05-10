# encoding: utf-8

class MtgCard 

  attr_accessor \
    :name,
    :set_name,
    :gatherer,
    :cost,
    :type,
    :oracle,
    :power, 
    :toughness, 
    :loyalty,
    :rarity,
    :artist, 
    :collector,
    :art,
    :max_art,
    :others

  def initialize(name, set_name = nil)
    @name = clean_name(name)
    @set = set_name
    @others = [ ]
  end

  def key
    result = @name.to_basic_ascii
    result.gsub!(/[:\/\\\*\?"<>\|]/, ' ') 
    result.gsub!(/\s+/, ' ')
    result + (@art && @art > 0 ? " - #{@art}" : '')
  end

  def is_token?
    (@cost.nil? || @cost == '') && (@name == 'Hornet' || @type == "Creature - #{@name}")
  end

  def merge!(other)
    self.name = other.name || self.name
    self.gatherer = other.gatherer || self.gatherer
    self.cost = other.cost || self.cost
    self.type = other.type || self.type
    self.oracle = other.oracle || self.oracle
    self.power = other.power || self.power 
    self.toughness = other.toughness || self.toughness 
    self.loyalty = other.loyalty || self.loyalty
    self.rarity = other.rarity || self.rarity
    self.artist = other.artist || self.artist
    self.collector = other.collector || self.collector
    self.art = other.art || self.art
  end

  def to_s
    "[#{self.name}]"
  end

  def to_yaml
    text = [ ]
    text << "name: #{y(@name)}"
    text << "display: #{y(@display)}" unless @display.nil?
    text << "tcg: #{y(@tcg)}" unless @tcg.nil?
    text << "set: #{y(@set)}"
    text << "gatherer: #{y(@gatherer)}"
    text << "cost: #{y(@cost)}" unless (@cost.nil? || @cost == '')
    text << "type: #{y(@type)}" unless (@type.nil? || @type == '')
    text << "power: #{y(@power)}" unless (@power.nil? || @power == '') 
    text << "toughness: #{y(@toughness)}" unless (@toughness.nil? || @toughness == '') 
    text << "loyalty: #{y(@loyalty)}" unless (@loyalty.nil? || @loyalty == '') 
    text << "rarity: #{y(@rarity)}" unless (@rarity.nil? || @rarity == '')    
    text << "artist: #{y(@artist)}" unless (@artist.nil? || @artist == '')
    text << "collector: #{y(@collector)}" unless (@collector.nil? || @collector == '')
    text << "art: #{y(@art)}/#{y(@max_art)}" unless (@art.nil? || @art == '')
    text << "others: #{y(@others)}" unless @others.length == 0
    text << "oracle: #{y(@oracle, force_block_text: true)}" unless (@oracle.nil? || @oracle == '')
    text.join("\n")
  end

  def y(obj, opts = { })
    if obj.class == Array
      '[ ' + (obj.map { |val| y(val, in_array: true) }).join(', ') + ' ]'
    else    
      if obj.to_s.to_i == obj.to_s
        obj.to_s.to_i
      else
        if obj.to_s.include?("\n") || opts[:force_block_text]
          "|\n " + obj.gsub(/\n/, "\n ")
        elsif (opts[:in_array] && obj.to_s.include?(',')) || obj.to_s.match(/(^'|'$|^\{|\}$|^\*|:)/)
          obj = "'#{obj.to_s.gsub(/'/,"''")}'"
        else
          obj.to_s
        end
      end
    end
  end

  # removes formatting codes from name (e.g. "XX" flashback icon)
  # removes references to other parts (e.g. flip cards & DFCs)
  # normalizes split cards to "SPELL (SPELL // OTHER)"
  # fixes one-off Gatherer bugs
  def clean_name(name)
    # Gatherer lists "Kill! Destroy!" as "Kill Destroy"
    if name == 'Kill Destroy'
      return 'Kill! Destroy!'
    end
    # "Erase" from Unhinged is the only card that contains parentheses in its name
    if name == "Erase (Not the Urza's Legacy One)"
      return name
    end
    # XXValor (Valor)
    if /^XX(.*)\s\((.*)\)/.match(name) && $1 == $2
      return $1
    end
    # Dead // Gone (Gone)  
    if /^(.*)\s\/\/\s(.*)\s\((.*)\)$/.match(name) then
      return "#{$3} (#{$1} // #{$2})"
    end
    # Nezumi Graverobber (Nighteyes the Desecrator)
    if /^(.*)\s\((.*)\)$/.match(name) then
      return $2
    end    
    # everything else
    name.gsub(/^XX(.*)\s+\(.*\)$/, '\1')
  end

  # e.g. "SPELL (SPELL // OTHER)" => "SPELL"
  def single_spell_name
    # "Erase" from Unhinged is the only card that contains 
    # literal parentheses in its card name
    if @name == "Erase (Not the Urza's Legacy One)"
      return @name
    end
    # XXValor (Valor)
    if /^XX(.*)\s\((.*)\)/.match(@name) && $1 == $2
      return $1
    end
    # Dead // Gone (Gone)  
    if /^(.*)\s\/ \/\s(.*)\s\((.*)\)$/.match(@name) then
      return $3
    end
    # Nezumi Graverobber (Nighteyes the Desecrator)
    if /^(.*)\s\((.*)\)$/.match(@name) then
      return $2
    end    
    # everything else
    @name.gsub(/^XX(.*)\s+\(.*\)$/, '\1')
  end

  def search_name
    result = single_spell_name.to_basic_ascii.upcase
    # "Erase" from Unhinged is the only card that contains parentheses in its name
    if result != "ERASE (NOT THE URZA'S LEGACY ONE)"
      result.gsub!(/\(.*?\)/, '') # remove parethetical text
    end
    result.gsub!(/[^A-Z0-9_]/, '') # remove special characters
    result
  end
  
end