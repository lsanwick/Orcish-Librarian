# encoding: utf-8

require 'source'
require 'textutils'

class Gatherer < Source

  def sets
    @@sets
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
    doc = fetch_document("http://gatherer.wizards.com/Pages/Search/Default.aspx?output=checklist&set=%5b%22#{URI.escape(set)}%22%5d")
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
        current_card[:is_token] = ((current_card[:mana_cost].nil? || current_card[:mana_cost] == '') && current_card[:type_line] == "Creature - #{current_card[:name]}") ? 1 : 0
        cards[current_card[:name]] = current_card
        current_card = { }
      end
    end
    cards
  end
      
  @@sets = {
    
    # misc. sets    
    "Chronicles" => "Chronicles",    
    "Battle Royale Box Set" => "Battle Royale Box Set",
    "Beatdown Box Set" => "Beatdown Box Set",
    "Portal" => "Portal",
    "Portal Second Age" => "Portal Second Age",
    "Portal Three Kingdoms" => "Portal Three Kingdoms",
    "Starter 1999" => "Starter 1999",
    "Starter 2000" => "Starter 2000",        
    
    "Unglued" => "Unglued",
    "Unhinged" => "Unhinged",
    
    "Duel Decks: Elves vs. Goblins" => "Duel Decks: Elves vs. Goblins",
    "Duel Decks: Jace vs. Chandra" => "Duel Decks: Jace vs. Chandra",
    "Duel Decks: Divine vs. Demonic" => "Duel Decks: Divine vs. Demonic",
    "Duel Decks: Garruk vs. Liliana" => "Duel Decks: Garruk vs. Liliana",
    "Duel Decks: Phyrexia vs. the Coalition" => "Duel Decks: Phyrexia vs. the Coalition",
    "Duel Decks: Elspeth vs. Tezzeret" => "Duel Decks: Elspeth vs. Tezzeret",
    "Duel Decks: Knights vs. Dragons" => "Duel Decks: Knights vs Dragons",    
    "Duel Decks: Ajani vs. Nicol Bolas" => "Duel Decks: Ajani vs. Nicol Bolas",
    "Duel Decks: Venser vs. Koth" => "Duel Decks: Venser vs. Koth",
    
    "From the Vault: Dragons" => "From the Vault: Dragons",
    "From the Vault: Exiled" => "From the Vault: Exiled",
    "From the Vault: Relics" => "From the Vault: Relics",
    "From the Vault: Legends" => "From the Vault: Legends",

    "Premium Deck Series: Slivers" => "Premium Deck Series: Slivers",
    "Premium Deck Series: Fire and Lightning" => "Premium Deck Series: Fire and Lightning",
    "Premium Deck Series: Graveborn" => "Premium Deck Series: Graveborn",

    "Planechase" => "Planechase",
    "Archenemy" => "Archenemy",
    "Magic: The Gathering-Commander" => "Commander",        
    
    # core sets
    "Limited Edition Alpha" => "Alpha Edition",
    "Limited Edition Beta" => "Beta Edition",
    "Unlimited Edition" => "Unlimited Edition",
    "Revised Edition" => "Revised Edition",
    "Fourth Edition" => "Fourth Edition",
    "Fifth Edition" => "Fifth Edition",
    "Classic Sixth Edition" => "Classic Sixth Edition",
    "Seventh Edition" => "7th Edition", 
    "Eighth Edition" => "8th Edition",
    "Ninth Edition" => "9th Edition",
    "Tenth Edition" => "Tenth Edition",
    "Magic 2010" => "Magic 2010",
    "Magic 2011" => "Magic 2011 (M11)",
    "Magic 2012" => "Magic 2012 (M12)",
    
    # expansion sets
    "Arabian Nights" => "Arabian Nights",
    "Antiquities" => "Antiquities",
    "Legends" => "Legends",
    "The Dark" => "The Dark",
    "Fallen Empires" => "Fallen Empires",        
    "Homelands" => "Homelands",
    "Ice Age" => "Ice Age",
    "Alliances" => "Alliances",
    "Mirage" => "Mirage",
    "Visions" => "Visions",
    "Weatherlight" => "Weatherlight",
    "Tempest" => "Tempest",
    "Stronghold" => "Stronghold",
    "Exodus" => "Exodus",
    "Urza's Saga" => "Urza's Saga",
    "Urza's Legacy" => "Urza's Legacy",
    "Urza's Destiny" => "Urza's Destiny",
    "Mercadian Masques" => "Mercadian Masques",
    "Nemesis" => "Nemesis",
    "Prophecy" => "Prophecy",
    "Invasion" => "Invasion",
    "Planeshift" => "Planeshift",    
    "Apocalypse" => "Apocalypse",
    "Odyssey" => "Odyssey",
    "Torment" => "Torment",
    "Judgment" => "Judgment",
    "Onslaught" => "Onslaught",
    "Legions" => "Legions",
    "Scourge" => "Scourge",
    "Mirrodin" => "Mirrodin",
    "Darksteel" => "Darksteel",
    "Fifth Dawn" => "Fifth Dawn",
    "Champions of Kamigawa" => "Champions of Kamigawa",
    "Betrayers of Kamigawa" => "Betrayers of Kamigawa",
    "Saviors of Kamigawa" => "Saviors of Kamigawa",    
    "Ravnica: City of Guilds" => "Ravnica: City of Guilds",
    "Guildpact" => "Guildpact",
    "Dissension" => "Dissension",    
    "Time Spiral" => "Time Spiral",
    "Coldsnap" => "Coldsnap",
    "Time Spiral \"Timeshifted\"" => "Timeshifted",
    "Planar Chaos" => "Planar Chaos",
    "Future Sight" => "Future Sight",
    "Lorwyn" => "Lorwyn",
    "Morningtide" => "Morningtide",
    "Shadowmoor" => "Shadowmoor",
    "Eventide" => "Eventide",
    "Shards of Alara" => "Shards of Alara",       
    "Alara Reborn" => "Alara Reborn",
    "Conflux" => "Conflux",
    "Zendikar" => "Zendikar",
    "Worldwake" => "Worldwake", 
    "Rise of the Eldrazi" => "Rise of the Eldrazi",    
    "Scars of Mirrodin" => "Scars of Mirrodin",
    "Mirrodin Besieged" => "Mirrodin Besieged",
    "New Phyrexia" => "New Phyrexia",    
    "Innistrad" => "Innistrad",
    "Dark Ascension" => "Dark Ascension"
  }
      
end
