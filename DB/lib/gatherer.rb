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
    
    # core and expansion sets
    "Limited Edition Alpha" => "Alpha Edition",
    "Limited Edition Beta" => "Beta Edition",
    "Unlimited Edition" => "Unlimited Edition",
    "Arabian Nights" => "Arabian Nights",
    "Antiquities" => "Antiquities",    
    "Revised Edition" => "Revised Edition",
    "Legends" => "Legends",
    "The Dark" => "The Dark",
    "Fallen Empires" => "Fallen Empires",    
    "Fourth Edition" => "Fourth Edition",
    "Ice Age" => "Ice Age",
    "Chronicles" => "Chronicles",    
    "Homelands" => "Homelands",    
    "Alliances" => "Alliances",
    "Mirage" => "Mirage",
    "Visions" => "Visions",
    "Fifth Edition" => "Fifth Edition",
    "Portal" => "Portal",
    "Weatherlight" => "Weatherlight",
    "Tempest" => "Tempest",
    "Stronghold" => "Stronghold",
    "Exodus" => "Exodus",
    "Portal Second Age" => "Portal Second Age",
    "Unglued" => "Unglued",
    "Urza's Saga" => "Urza's Saga",
    # "Anthologies" => "Anthologies",
    "Urza's Legacy" => "Urza's Legacy",    
    "Classic Sixth Edition" => "Classic Sixth Edition",
    "Urza's Destiny" => "Urza's Destiny",
    "Portal Three Kingdoms" => "Portal Three Kingdoms",
    "Starter 1999" => "Starter 1999",
    "Mercadian Masques" => "Mercadian Masques",
    "Battle Royale Box Set" => "Battle Royale Box Set",
    "Nemesis" => "Nemesis",
    "Starter 2000" => "Starter 2000",
    "Prophecy" => "Prophecy",
    "Invasion" => "Invasion",
    "Beatdown Box Set" => "Beatdown Box Set",
    "Planeshift" => "Planeshift",    
    "Seventh Edition" => "7th Edition", 
    "Apocalypse" => "Apocalypse",
    "Odyssey" => "Odyssey",
    # "Deckmasters" => "Deckmasters",
    "Torment" => "Torment",
    "Judgment" => "Judgment",
    "Onslaught" => "Onslaught",
    "Legions" => "Legions",
    "Scourge" => "Scourge",    
    "Eighth Edition" => "8th Edition",
    "Mirrodin" => "Mirrodin",
    "Darksteel" => "Darksteel",
    "Fifth Dawn" => "Fifth Dawn",
    "Champions of Kamigawa" => "Champions of Kamigawa",
    "Unhinged" => "Unhinged",
    "Betrayers of Kamigawa" => "Betrayers of Kamigawa",
    "Saviors of Kamigawa" => "Saviors of Kamigawa",    
    "Ninth Edition" => "9th Edition",
    "Ravnica: City of Guilds" => "Ravnica",
    "Guildpact" => "Guildpact",
    "Dissension" => "Dissension",
    "Coldsnap" => "Coldsnap",
    "Time Spiral" => "Time Spiral",    
    "Time Spiral \"Timeshifted\"" => "Timeshifted",
    "Planar Chaos" => "Planar Chaos",
    "Future Sight" => "Future Sight",    
    "Tenth Edition" => "10th Edition",
    "Lorwyn" => "Lorwyn",
    "Morningtide" => "Morningtide",
    "Shadowmoor" => "Shadowmoor",
    "Eventide" => "Eventide",
    "Shards of Alara" => "Shards of Alara",           
    "Conflux" => "Conflux",
    "Alara Reborn" => "Alara Reborn",
    "Magic 2010" => "Magic 2010 (M10)",
    "Zendikar" => "Zendikar",
    "Worldwake" => "Worldwake", 
    "Rise of the Eldrazi" => "Rise of the Eldrazi",    
    "Magic 2011" => "Magic 2011 (M11)",
    "Scars of Mirrodin" => "Scars of Mirrodin",
    "Mirrodin Besieged" => "Mirrodin Besieged",
    "New Phyrexia" => "New Phyrexia",    
    "Magic 2012" => "Magic 2012 (M12)",
    "Innistrad" => "Innistrad",
    "Dark Ascension" => "Dark Ascension"    
  }
      
end
