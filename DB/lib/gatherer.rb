# encoding: utf-8

require 'source'

class Gatherer < Source
  
  def cards_for_set(set_name)
    debug("Downloading checklist & spoiler for \"#{set_name}\"")
    checklist = checklist_for_set(set_name)
    spoiler = spoiler_for_set(set_name)
    cards = merge_checklist_and_spoiler(checklist, spoiler)
    set_other_parts(cards)
    cards
  end
  
  def set_other_parts(cards)
    sorted = { }
    cards.each do |card|
      if card.collector != ''
        sorted[card.collector] = sorted[card.collector] || [ ]
        sorted[card.collector] << card
      end
    end
    sorted.each do |number, cards|
      cards.each do |card|
        others = cards.select { |other| other != card }
        card.others = others.map { |other| other.key }
      end
    end
  end

  def merge_checklist_and_spoiler(checklist, spoiler)
    merged_cards = [ ]
    checklist.each_pair do |name, card|
      if spoiler[name].nil?
        debug("[WARNING] No spoiler entry for #{name}")
      else
        card.merge!(spoiler[name])
        merged_cards << card
      end
    end
    merged_cards
  end

  def checklist_for_set(set_name)
    by_name = { }
    doc = fetch_document("http://gatherer.wizards.com/Pages/Search/Default.aspx?output=checklist&set=%5b%22#{URI.escape(set_name)}%22%5d")
    doc.search("tr[@class=cardItem]").each do |tr|
      cells = tr.search('td')
      card = MtgCard.new(cells[1].at('a').inner_text.strip, set_name)
      by_name[card.single_spell_name] = by_name[card.single_spell_name] || [ ]
      card.collector = cells[0].inner_text.strip
      card.rarity = cells[4].inner_text.strip      
      if (by_name[card.single_spell_name].length == 0 || card.collector != by_name[card.single_spell_name][0].collector || card.rarity == 'L' || (set_name != 'Apocalypse' && set_name != 'Invasion'))
        by_name[card.single_spell_name] << card
      else
        debug("[WARNING] #{card.single_spell_name} has a duplicate collector's number (#{card.collector})")
      end
    end
    by_name.each_key do |name|      
      by_name[name][0].art = by_name[name].length
      #by_name[name].length unless by_name[name].length == 1
      by_name[name] = by_name[name][0]
    end
    by_name
  end
  
  def spoiler_for_set(set_name)
    by_name = { }
    current = nil
    doc = fetch_document("http://gatherer.wizards.com/Pages/Search/Default.aspx?output=spoiler&set=%5b%22#{URI.escape(set_name)}%22%5d&special=true")
    doc.search("div[@class=textspoiler] table tr").each do |tr|
      cells = tr.search('td')
      if cells.length == 2
        label = cells[0].inner_text.strip.gsub(/:$/, '')
        value = cells[1]
        if label == 'Name'         
          current = MtgCard.new(value.inner_text.strip, set_name)
        elsif label == 'Pow/Tgh'
          current.power = value.inner_text.strip.gsub(/^\(([^\/]*(?:\{1\/2\})?)\/([^\/]*(?:\{1\/2\})?)\)/, '\1')
          current.toughness = value.inner_text.strip.gsub(/^\(([^\/]*(?:\{1\/2\})?)\/([^\/]*(?:\{1\/2\})?)\)/, '\2')
        elsif label == 'Loyalty'
          current.loyalty = value.inner_text.strip.gsub(/^\((.*)\)$/, '\1')
        elsif label == 'Type'
          current.type = value.inner_text.strip.gsub(/\s+/, ' ')
        elsif label == 'Rules Text'
          current.oracle = fix_oracle_text(value.inner_text.strip.gsub(/\n+/, "\n"), set_name)
        elsif label == 'Cost'
          current.cost = value.inner_text.strip
        end
      else
        # disregard token cards
        if !current.is_token?
          by_name[current.single_spell_name] = current
        end
      end
    end
    by_name
  end

  def fix_oracle_text(text, set_name)

    # fix basic lands
    if text.length == 1  
      text = ""
    end  

    # Capitalize all symbols inside curly brackets
    text.gsub!(/\{.*?\}/) { |s| s.upcase; }

    # Unhinged has 1/2 mana symbols that look like nonsense
    # It also has 1/2 P/T modifiers that are represented similarly
    if set_name == 'Unhinged'
      text.gsub!(/\{([WBURG])([WBURG])\}/i, '{\1}{\2}')
      text.gsub!(/\{o(\d+)o\{1\/2\}\}/, '{\1}{o{C\/2}}')
      text.gsub!('{o{1\/2}}', '{o{C\/2}}')
      text.gsub!(/\{o\{1\/2\*([WBURG])\}\}/, '{o{\1\/2}}')
      text.gsub!(/\{o\{([WBURGC])\/2\}\}/i, '{\1/2}')
      text.gsub!(/\{1\/2\}/, '½')
      text.gsub!(/o([0-9WBURGX])o([0-9WBURGX])/, '{\1}{\2}')
    end

    # Unglued was never updated with modern markup
    if set_name == 'Unglued'
      text.gsub!(/o([\d]+|[WBURGS])/, '{\1}') # fixes old-style mana symbol
      text.gsub!(/ocT/, '{T}') # fixes old-style tap symbol
    end 

    # miscellaneous text bugs
    text.gsub!(/\n+/, "\n") # no more than one newline in a row
    text.gsub!(/\{(\d+)([WBURGS]+)\}/, '{\1}{\2}') # fix compressed mana cost in Blast from the Past
    text.gsub!(/\{1\}0\}/, '{10}') # fixes a bug in Draco's {10} symbol
    text.gsub!(/\{2\}0\}/, '{20}') # fixes a bug in Spawnsire of Ulamog's text
    text.gsub!(/\{([^}]+)\{/, '{\1}{') # fixes a symbol bug in Rhys the Redeemed's text
    text.gsub!(/\{S\}i\}/i, '{S}') # fixes a bug with Snow Mana symbol            

    # convert hyphen into em-dash
    text.gsub(/(\s)-(\s)/, '\1—\2');

    text
  end
      
end
