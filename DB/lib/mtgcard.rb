# encoding: utf-8

class MtgCard 

  attr_accessor \
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
    :others

  attr_reader :name, :set_name

  def initialize(text, set_name)
    @name = text.to_spell_name
    @display = text.to_display_name unless text.to_display_name == @name
    @tcg = text.to_tcg_name unless text.to_tcg_name == @name
    @set = set_name
    @others = [ ]
  end

  def display_name
    @display || @name
  end

  def tcg_name
    @tcg || @name
  end

  def key
    name + (@art && @art > 0 ? " - #{@art}" : '')
  end

  def search_name
    @name.to_searchable_name
  end

  def name_hash
    @name.to_name_hash
  end

  def is_token?
    (@cost.nil? || @cost == '') && (@name == 'Hornet' || @type == "Creature - #{@name}")
  end

  def merge!(other)
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
    text << "display: #{y(@display)}" unless (@display.nil? || @display == '')
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
    text << "art: #{y(@art)} / #{y(@max_art)}" unless (@art.nil? || @art == '')
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
          "|\n  " + obj.gsub(/\n/, "\n\  ")
        elsif (opts[:in_array] && obj.to_s.include?(',')) || obj.to_s.match(/(^'|'$|^\{|\}$|^\*)/)
          obj = "'#{obj.to_s.gsub(/'/,"''")}'"
        else
          obj.to_s
        end
      end
    end
  end

end