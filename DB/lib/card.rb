
class MtgCard 

  attr_writer :gatherer_id,
    :mana_cost,
    :type_line,
    :oracle_text,
    :power, :toughness, :loyalty,
    :set,
    :rarity,
    :artist, 
    :collector_number,
    :art_index

  def name=(text)
    @name = value.inner_text.strip.to_spell_name
    @display_name] = value.inner_text.strip.to_display_name
    @tcg_name = value.inner_text.strip.to_tcg_name
    @search_name = value.inner_text.strip.to_searchable_name
    @name_hash = value.inner_text.strip.to_name_hash 
  end

  def is_token?
    (@mana_cost.nil? || @mana_cost == '') && (@name == 'Hornet' || @type_line == "Creature - #{@name}")
  end

end