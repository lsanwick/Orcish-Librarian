# encoding: utf-8

require 'source'
require 'textutils'

class Gatherer < Source
  
  def cards_for_set(set_name)
    debug("Downloading checklist & spoiler for \"#{set_name}\"")
    checklist = checklist_for_set(set_name)
    spoiler = spoiler_for_set(set_name)
    cards = merge_checklist_and_spoiler(checklist, spoiler)
    set_other_parts_and_variants(cards)
    cards
  end
  
  def set_other_parts_and_variants(cards)
    # other parts (sorted by collector #)
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
    # art variants (sorted by name)
    sorted = { }
    cards.each do |card|
      sorted[card.name] = sorted[card.name] || [ ]
      sorted[card.name] << card      
    end
    sorted.each do |name, cards|
      cards.each do |card|
        if card.art != nil && card.art != ''
          card.max_art = (cards.map { |c| c.art.to_i }).max
        end
      end
    end
  end

  def merge_checklist_and_spoiler(checklist, spoiler)
    merged_cards = [ ]
    checklist.each_pair do |name, cards|
      if spoiler[name].nil?
        debug("[WARNING] No spoiler entry for #{name}")
      else
        cards.each do |card|
          card.merge!(spoiler[name])
          merged_cards << card
        end
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
      others = by_name[card.name] = by_name[card.name] || [ ]
      card.gatherer = cells[1].at('a')['href'].gsub(/^.*multiverseid=(\d+)$/, '\1').to_i
      card.artist = cells[2].inner_text.strip
      card.collector = cells[0].inner_text.strip
      card.rarity = cells[4].inner_text.strip      
      if (others.length == 0 || card.collector != others[0].collector || card.rarity == 'L' || (set_name != 'Apocalypse' && set_name != 'Invasion'))
        others << card
      else
        debug("[WARNING] #{card.name} has a duplicate collector's number (#{card.collector})")
      end
    end
    by_name.each_pair do |name, cards|      
      if cards.length > 1
        for i in 0 ... cards.length
          cards[i].art = (i + 1)
        end
      else 
        cards[0].art = nil
      end
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
          current.gatherer = value.at('a')['href'].gsub(/^.*?(\d+)$/, '\1').to_i
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
          by_name[current.name] = current
        end
      end
    end
    by_name
  end

  def fix_oracle_text(text, set_name)

    # fix basic lands
    if text.length == 1  
      text = "{T}: Add {#{text}} to your mana pool." 
    end  

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
