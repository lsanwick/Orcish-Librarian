# encoding: utf-8

require 'source'
require 'textutils'

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
      if card.collector_number != ''
        sorted[card.collector_number] = sorted[card.collector_number] || [ ]
        sorted[card.collector_number] << card
      end
    end
    sorted.each do |number, cards|
      cards.each do |card|
        others = cards.select { |other| other != card }
        card.other_parts = others.map { |other| other.name }
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
      card.gatherer_id = cells[1].at('a')['href'].gsub(/^.*multiverseid=(\d+)$/, '\1').to_i
      card.artist = cells[2].inner_text.strip
      card.collector_number = cells[0].inner_text.strip
      card.rarity = cells[4].inner_text.strip      
      if (others.length == 0 || card.collector_number != others[0].collector_number || card.rarity == 'L' || (set_name != 'Apocalypse' && set_name != 'Invasion'))
        others << card
      else
        debug("[WARNING] #{card.name} has a duplicate collector's number (#{card.collector_number})")
      end
    end
    by_name.each_pair do |name, cards|      
      if cards.length > 1
        for i in 0 ... cards.length
          cards[i].art_index = (i + 1)
        end
      else 
        cards[0].art_index = nil
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
          current.gatherer_id = value.at('a')['href'].gsub(/^.*?(\d+)$/, '\1').to_i
        elsif label == 'Pow/Tgh'
          current.power = value.inner_text.strip.gsub(/^\(([^\/]*(?:\{1\/2\})?)\/([^\/]*(?:\{1\/2\})?)\)/, '\1')
          current.toughness = value.inner_text.strip.gsub(/^\(([^\/]*(?:\{1\/2\})?)\/([^\/]*(?:\{1\/2\})?)\)/, '\2')
        elsif label == 'Loyalty'
          current.loyalty = value.inner_text.strip.gsub(/^\((.*)\)$/, '\1')
        elsif label == 'Type'
          current.type_line = value.inner_text.strip.gsub(/\s+/, ' ')
        elsif label == 'Rules Text'
          current.oracle_text = value.inner_text.strip
        elsif label == 'Cost'
          current.mana_cost = value.inner_text.strip
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
      
end
