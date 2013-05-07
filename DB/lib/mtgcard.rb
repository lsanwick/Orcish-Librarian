
class MtgCard 

  attr_accessor \
    :gatherer_id,
    :mana_cost,
    :type_line,
    :oracle_text,
    :power, 
    :toughness, 
    :loyalty,
    :rarity,
    :artist, 
    :collector_number,
    :art_index,
    :other_parts

  attr_reader :name, :set_name

  def initialize(text, set_name)
    @name = text.to_spell_name
    @display_name = text.to_display_name unless text.to_display_name == @name
    @tcg_name = text.to_tcg_name unless text.to_tcg_name == @name
    @set_name = set_name
  end

  def display_name
    @display_name || @name
  end

  def tcg_name
    @tcg_name || @name
  end

  def key
    name #name + (art_index && art_index > 1 ? " - #{art_index}" : '')
  end

  def search_name
    @name.to_searchable_name
  end

  def name_hash
    @name.to_name_hash
  end

  def is_token?
    (@mana_cost.nil? || @mana_cost == '') && (@name == 'Hornet' || @type_line == "Creature - #{@name}")
  end

  def merge!(other)
    self.gatherer_id = other.gatherer_id || self.gatherer_id
    self.mana_cost = other.mana_cost || self.mana_cost
    self.type_line = other.type_line || self.type_line
    self.oracle_text = other.oracle_text || self.oracle_text
    self.power = other.power || self.power 
    self.toughness = other.toughness || self.toughness 
    self.loyalty = other.loyalty || self.loyalty
    self.rarity = other.rarity || self.rarity
    self.artist = other.artist || self.artist
    self.collector_number = other.collector_number || self.collector_number
    self.art_index = other.art_index || self.art_index
  end

  def to_s
    "[#{self.name}]"
  end

  def to_hash
    hash = { }
    hash['name'] = @name
    hash['set_name'] = @set_name
    hash['display_name'] = @display_name unless (@display_name.nil? || @display_name == '')
    hash['tcg_name'] = @tcg_name unless (@tcg_name.nil? || @tcg_name == '')
    hash['gatherer_id'] = @gatherer_id unless (@gatherer_id.nil? || @gatherer_id == '')
    hash['mana_cost'] = @mana_cost unless (@mana_cost.nil? || @mana_cost == '')
    hash['type_line'] = @type_line unless (@type_line.nil? || @type_line == '')    
    hash['power'] = (@power.to_i.to_s == @power ? @power.to_i : @power) unless (@power.nil? || @power == '') 
    hash['toughness'] = (@toughness.to_i.to_s == @toughness ? @toughness.to_i : @toughness) unless (@toughness.nil? || @toughness == '')
    hash['loyalty'] = (@loyalty.to_i.to_s == @loyalty ? @loyalty.to_i : @loyalty) unless (@loyalty.nil? || @loyalty == '')
    hash['rarity'] = @rarity unless (@rarity.nil? || @rarity == '')
    hash['artist'] = @artist unless (@artist.nil? || @artist == '') 
    hash['collector_number'] = (@collector_number.to_i.to_s == @collector_number ? @collector_number.to_i : @collector_number) unless (@collector_number.nil? || @collector_number == '')
    hash['art_index'] = @art_index unless (@art_index.nil? || @art_index == '')
    hash['others'] = @other_parts unless @other_parts.length == 0
    hash['oracle_text'] = @oracle_text unless (@oracle_text.nil? || @oracle_text == '')
    hash
  end

end