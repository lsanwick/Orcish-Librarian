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
    checklist = checklist_for_set(set)
    spoiler = spoiler_for_set(set)
    if checklist.length != spoiler.length
      debug("WARNING - Mismatched spoiler and checklist size for '#{set}'.")
      debug("  #{spoiler.length} vs. #{checklist.length}")
      (spoiler.map { |s| s[:name] } - checklist.map { |c| c[0] }).each do |name| 
        debug("  '#{name}' is mismatched.") 
      end
    else      
      debug("Found #{checklist.length} cards for '#{set}'.")
    end
    spoiler.each do |s|
      checklist_entry = checklist[s[:name]]
      s[:collector_number] = checklist_entry[:collector_number] unless checklist_entry.nil?
    end    
    spoiler
  end
  
  def checklist_for_set(set)
    cards = { }
    doc = fetch_document("http://gatherer.wizards.com/Pages/Search/Default.aspx?output=checklist&set=%5b%22#{URI.escape(set)}%22%5d&special=true")
    doc.search("tr[@class=cardItem]").each do |tr|
      cells = tr.search('td')
      number = cells[0].inner_text
      id = cells[1].at('a')['href'].gsub(/^.*multiverseid=(\d+)$/, '\1')
      name = cells[1].at('a').inner_text
      cards[name] = { :name => name, :collector_number => number }
    end
    cards
  end
  
  def spoiler_for_set(set)
    cards = [ ]
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
        elsif label == 'Set/Rarity'
          value.inner_text.split(/\s?,\s?/).each do |text|
            text.strip!
            if text.include?(set) then
              current_card[:rarity] = case text
                when /mythic rare$/i then :mythic
                when /rare$/i then :rare
                when /uncommon$/i then :uncommon
                when /common$/i then :common 
                when /land$/i then :land
                else :special
              end
            end
          end
        end
      else
        cards << current_card
        current_card = { }
      end
    end
    cards
  end
      
end
