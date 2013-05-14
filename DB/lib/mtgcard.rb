# encoding: utf-8

class MtgCard 

  include Orcish

  attr_accessor \
    :name,
    :set,
    :cost,
    :type,
    :oracle,
    :power, 
    :toughness, 
    :loyalty,
    :rarity,
    :collector,
    :art,
    :others

  def initialize(name, set_name = nil)
    @name = clean_name(name)
    @set = set_name
    @others = [ ]
  end

  def key
    single_spell_name.to_file_name
  end

  def is_token?
    (@cost.nil? || @cost == '') && (@name == 'Hornet' || @type == "Creature - #{@name}")
  end

  def merge!(other)
    self.name = other.name || self.name
    self.cost = other.cost || self.cost
    self.type = other.type || self.type
    self.oracle = other.oracle || self.oracle
    self.power = other.power || self.power 
    self.toughness = other.toughness || self.toughness 
    self.loyalty = other.loyalty || self.loyalty
    self.rarity = other.rarity || self.rarity
    self.collector = other.collector || self.collector
    self.art = other.art || self.art
  end

  def to_s
    "[#{self.name}]"
  end

  def to_yaml
    text = [ ]
    text << "name: #{y(@name)}"
    text << "set: #{y(@set)}"
    text << "cost: #{y(@cost)}" unless (@cost.nil? || @cost == '')
    text << "type: #{y(@type)}" unless (@type.nil? || @type == '')
    text << "power: #{y(@power)}" unless (@power.nil? || @power == '') 
    text << "toughness: #{y(@toughness)}" unless (@toughness.nil? || @toughness == '') 
    text << "loyalty: #{y(@loyalty)}" unless (@loyalty.nil? || @loyalty == '') 
    text << "rarity: #{y(@rarity)}" unless (@rarity.nil? || @rarity == '')
    text << "art: #{y(@art)}" unless @art.to_i <= 1
    text << "others: #{y(@others)}" unless @others.length == 0
    text << "oracle: #{y(@oracle, force_block_text: true)}" unless (@oracle.nil? || @oracle == '')
    text.join("\n")
  end

  def to_hash
    hash = { }
    hash['name'] = @name
    hash['set'] = @set
    hash['cost'] = @cost unless (@cost.nil? || @cost == '')    
    hash['type'] = @type unless (@type.nil? || @type == '')
    hash['power'] = @power unless (@power.nil? || @power == '')
    hash['toughness'] = @toughness unless (@toughness.nil? || @toughness == '')
    hash['loyalty'] = @loyalty unless (@loyalty.nil? || @loyalty == '')
    hash['rarity'] = @rarity unless (@rarity.nil? || @rarity == '')
    hash['art'] = @art unless @art.to_i <= 1
    hash['others'] = @others unless @others.length == 0
    hash['oracle'] = @oracle unless (@oracle.nil? || @oracle == '')
    hash
  end

  def to_json
    to_hash.to_json
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
    # Dead (Dead // Gone)
    if /^(.*)\s\((.*)\s\/\/\s(.*)\)$/.match(name) then
      return "#{$1} (#{$2} // #{$3})"
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
    @name.gsub(/\s\(.*\)$/, '')
  end

  def search_name
    result = single_spell_name.to_basic_ascii.downcase
    # "Erase" from Unhinged is the only card that contains parentheses in its name
    if result != "ERASE (NOT THE URZA'S LEGACY ONE)"
      result.gsub!(/\(.*?\)/, '') # remove parethetical text
    end
    result.gsub!(/[^a-z0-9_]/, '') # remove special characters
    result
  end

  def self.load(io)
    data = YAML.load(io)
    card = MtgCard.new(data['name'])
    data.each do |key, value|
      if card.respond_to?("#{key}=")
        card.public_send("#{key}=", value)
      end
    end
    card
  end
  
end