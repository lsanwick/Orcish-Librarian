# encoding: utf-8

require 'source'
require 'textutils'

class Gatherer < Source

  def sets
    sets = [ ]
    doc = fetch_document("http://gatherer.wizards.com/")
    doc.search("select[@id$=setAddText] option").each do |option|
      name = option.inner_text.strip
      sets << name if name.length > 0
    end    
    debug("Found #{sets.length} sets on Gatherer.")
    sets
  end
  
  def cards_for_set(set)
    cards = [ ]
    cards_by_name = { }
    checklist = checklist_for_set(set)
    spoiler = spoiler_for_set(set)
    checklist.each_pair do |name, cards_with_name|
      spoiler_entry = spoiler[name]
      if spoiler_entry.nil?
        debug("ERROR: No spoiler entry for #{name}")
      else
        cards_with_name.each do |card|
          card = card.clone
          card.merge!(spoiler_entry)
          cards << card
        end
      end
    end
    debug("Found #{cards.length} cards for '#{set}'.")
    cards
  end
  
  def checklist_for_set(set)
    cards = { }
    doc = fetch_document("http://gatherer.wizards.com/Pages/Search/Default.aspx?output=checklist&set=%5b%22#{URI.escape(set)}%22%5d&special=true")
    doc.search("tr[@class=cardItem]").each do |tr|
      cells = tr.search('td')
      name = cells[1].at('a').inner_text.strip.clean.to_normalized_name
      others = cards[name] = cards[name] || [ ]
      entry = {
        :gatherer_id =>  cells[1].at('a')['href'].gsub(/^.*multiverseid=(\d+)$/, '\1'),
        :name => name,
        :artist => cells[2].inner_text,
        :collector_number => cells[0].inner_text,
        :rarity => cells[4].inner_text
      }
      others << entry
    end
    cards.each_pair do |name, card|
      if card.length > 1
        for i in 0 ... card.length
          card[i][:art_index] = (i + 1)
        end
      else
        card[0][:art_index] = ''
      end
    end
    cards
  end
  
  def spoiler_for_set(set)
    cards = { }
    current_card = { }
    doc = fetch_document("http://gatherer.wizards.com/Pages/Search/Default.aspx?output=spoiler&set=%5b%22#{URI.escape(set)}%22%5d&special=true")
    doc.search("div[@class=textspoiler] table tr").each do |tr|
      cells = tr.search('td')
      if cells.length == 2
        label = cells[0].inner_text.strip.gsub(/:$/, '')
        value = cells[1]
        if label == 'Name'
          current_card[:name] = value.inner_text.strip.clean.to_normalized_name
          current_card[:gatherer_id] = value.at('a')['href'].gsub(/^.*?(\d+)$/, '\1')
        elsif label == 'Pow/Tgh'
          current_card[:power] = value.inner_text.strip.gsub(/^\((.*)\/(.*)\)$/, '\1')
          current_card[:toughness] = value.inner_text.strip.gsub(/^\((.*)\/(.*)\)$/, '\2')
        elsif label == 'Loyalty'
          current_card[:loyalty] = value.inner_text.strip.gsub(/^\((.*)\)$/, '\1')
        elsif label == 'Type'
          current_card[:type_line] = value.inner_text.strip.clean
        elsif label == 'Rules Text'
          current_card[:oracle_text] = value.inner_text.strip.clean
        elsif label == 'Cost'
          current_card[:mana_cost] = value.inner_text.strip
        end
      else
        cards[current_card[:name]] = current_card
        current_card = { }
      end
    end
    cards
  end
      
end
