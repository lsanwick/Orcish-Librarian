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
        debug("[WARNING] No spoiler entry for #{name}")
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
      name = cells[1].at('a').inner_text.strip.to_spell_name
      others = cards[name] = cards[name] || [ ]
      entry = {
        :gatherer_id =>  cells[1].at('a')['href'].gsub(/^.*multiverseid=(\d+)$/, '\1'),
        :name => name,
        :artist => cells[2].inner_text,
        :collector_number => cells[0].inner_text,
        :rarity => cells[4].inner_text
      }   
      if (others.length == 0 || 
          entry[:collector_number] != others[0][:collector_number] || 
          entry[:rarity] == 'L' || 
          (set != 'Apocalypse' && set != 'Invasion'))
        others << entry      
      else
        debug("[WARNING] #{entry[:name]} has a duplicate collector's number (#{entry[:collector_number]})")
      end
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
          current_card[:name] = value.inner_text.strip.to_spell_name
          current_card[:display_name] = value.inner_text.strip.to_display_name
          current_card[:tcg] = value.inner_text.strip.to_tcg_name
          current_card[:search_name] = value.inner_text.strip.to_searchable_name
          current_card[:name_hash] = value.inner_text.strip.to_name_hash 
          current_card[:gatherer_id] = value.at('a')['href'].gsub(/^.*?(\d+)$/, '\1')
        elsif label == 'Pow/Tgh'
          current_card[:power] = value.inner_text.strip.gsub(/^\(([^\/]*(?:\{1\/2\})?)\/([^\/]*(?:\{1\/2\})?)\)/, '\1')
          current_card[:toughness] = value.inner_text.strip.gsub(/^\(([^\/]*(?:\{1\/2\})?)\/([^\/]*(?:\{1\/2\})?)\)/, '\2')
        elsif label == 'Loyalty'
          current_card[:loyalty] = value.inner_text.strip.gsub(/^\((.*)\)$/, '\1')
        elsif label == 'Type'
          current_card[:type_line] = value.inner_text.strip
        elsif label == 'Rules Text'
          current_card[:oracle_text] = value.inner_text.strip
        elsif label == 'Cost'
          current_card[:mana_cost] = value.inner_text.strip
        end
      else
        # disregard token cards
        is_token = (current_card[:name] == 'Hornet' || current_card[:type_line] == "Creature - #{current_card[:name]}" || current_card[:type_line] == "Creature — #{current_card[:name]}") && (current_card[:mana_cost].nil? || current_card[:mana_cost] == '')
        cards[current_card[:name]] = current_card unless is_token
        current_card = { }
      end
    end
    cards
  end
      
  @@sets = {
    
    # misc. sets          
    "Chronicles"                                    => { :tcg => "Chronicles", :type => SpecialSet },
    "Portal"                                        => { :tcg => "Portal", :type => SpecialSet },
    "Portal Second Age"                             => { :tcg => "Portal Second Age", :type => SpecialSet },
    "Portal Three Kingdoms"                         => { :tcg => "Portal Three Kingdoms", :type => SpecialSet },
    "Starter 1999"                                  => { :tcg => "Starter 1999", :type => SpecialSet },
    "Battle Royale Box Set"                         => { :tcg => "Battle Royale Box Set", :type => SpecialSet },
    "Beatdown Box Set"                              => { :tcg => "Beatdown Box Set", :type => SpecialSet },    
    "Duel Decks: Elves vs. Goblins"                 => { :tcg => "Duel Decks: Elves vs. Goblins", :type => SpecialSet },
    "Duel Decks: Jace vs. Chandra"                  => { :tcg => "Duel Decks: Jace vs. Chandra", :type => SpecialSet },
    "Duel Decks: Divine vs. Demonic"                => { :tcg => "Duel Decks: Divine vs. Demonic", :type => SpecialSet },
    "Duel Decks: Garruk vs. Liliana"                => { :tcg => "Duel Decks: Garruk vs. Liliana", :type => SpecialSet },
    "Duel Decks: Phyrexia vs. the Coalition"        => { :tcg => "Duel Decks: Phyrexia vs. the Coalition", :type => SpecialSet },
    "Duel Decks: Elspeth vs. Tezzeret"              => { :tcg => "Duel Decks: Elspeth vs. Tezzeret", :type => SpecialSet },
    "Duel Decks: Knights vs. Dragons"               => { :tcg => "Duel Decks: Knights vs Dragons", :type => SpecialSet },
    "Duel Decks: Ajani vs. Nicol Bolas"             => { :tcg => "Duel Decks: Ajani vs. Nicol Bolas", :type => SpecialSet },
    "Duel Decks: Venser vs. Koth"                   => { :tcg => "Duel Decks: Venser vs. Koth", :type => SpecialSet },
    "Duel Decks: Izzet vs. Golgari"                 => { :tcg => "Duel Decks: Izzet vs. Golgari", :type => SpecialSet },
    "Duel Decks: Sorin vs. Tibalt"                  => { :tcg => "Duel Decks: Sorin vs. Tibalt", :type => SpecialSet },
    "From the Vault: Dragons"                       => { :tcg => "From the Vault: Dragons", :type => SpecialSet },
    "From the Vault: Exiled"                        => { :tcg => "From the Vault: Exiled", :type => SpecialSet },
    "From the Vault: Relics"                        => { :tcg => "From the Vault: Relics", :type => SpecialSet },
    "From the Vault: Legends"                       => { :tcg => "From the Vault: Legends", :type => SpecialSet },
    "From the Vault: Realms"                        => { :tcg => "From the Vault: Realms", :type => SpecialSet },
    "Premium Deck Series: Slivers"                  => { :tcg => "Premium Deck Series: Slivers", :type => SpecialSet },
    "Premium Deck Series: Fire and Lightning"       => { :tcg => "Premium Deck Series: Fire and Lightning", :type => SpecialSet },
    "Premium Deck Series: Graveborn"                => { :tcg => "Premium Deck Series: Graveborn", :type => SpecialSet },
    "Planechase"                                    => { :tcg => "Planechase", :type => SpecialSet, :display => "Planechase 2010" },
    "Archenemy"                                     => { :tcg => "Archenemy", :type => SpecialSet },
    "Magic: The Gathering-Commander"                => { :tcg => "Commander", :type => SpecialSet, :display => "Commander" },
    "Planechase 2012 Edition"                       => { :tcg => "Planechase 2012", :type => SpecialSet, :display => "Planechase 2012" },
    
    # core and expansion sets
    "Limited Edition Alpha"         => { :tcg => "Alpha Edition", :type => CoreSet, :format => Legacy, :display => "Alpha Edition" },
    "Limited Edition Beta"          => { :tcg => "Beta Edition", :type => CoreSet, :format => Legacy, :display => "Beta Edition"  },
    "Unlimited Edition"             => { :tcg => "Unlimited Edition", :type => CoreSet, :format => Legacy },
    "Arabian Nights"                => { :tcg => "Arabian Nights", :type => ExpansionSet, :format => Legacy },
    "Antiquities"                   => { :tcg => "Antiquities", :type => ExpansionSet, :format => Legacy },
    "Revised Edition"               => { :tcg => "Revised Edition", :type => CoreSet, :format => Legacy },
    "Legends"                       => { :tcg => "Legends", :type => ExpansionSet, :format => Legacy },
    "The Dark"                      => { :tcg => "The Dark", :type => ExpansionSet, :format => Legacy },
    "Fallen Empires"                => { :tcg => "Fallen Empires", :type => ExpansionSet, :format => Legacy },
    "Fourth Edition"                => { :tcg => "Fourth Edition", :type => CoreSet, :format => Legacy },
    "Ice Age"                       => { :tcg => "Ice Age", :type => ExpansionSet, :format => Legacy },
    "Homelands"                     => { :tcg => "Homelands", :type => ExpansionSet, :format => Legacy },
    "Alliances"                     => { :tcg => "Alliances", :type => ExpansionSet, :format => Legacy },
    "Mirage"                        => { :tcg => "Mirage", :type => ExpansionSet, :format => Legacy },
    "Visions"                       => { :tcg => "Visions", :type => ExpansionSet, :format => Legacy },
    "Fifth Edition"                 => { :tcg => "Fifth Edition", :type => CoreSet, :format => Legacy },
    "Weatherlight"                  => { :tcg => "Weatherlight", :type => ExpansionSet, :format => Legacy },
    "Tempest"                       => { :tcg => "Tempest", :type => ExpansionSet, :format => Legacy },
    "Stronghold"                    => { :tcg => "Stronghold", :type => ExpansionSet, :format => Legacy },
    "Exodus"                        => { :tcg => "Exodus", :type => ExpansionSet, :format => Legacy },    
    "Unglued"                       => { :tcg => "Unglued", :type => ExpansionSet, :format => Legacy },
    "Urza's Saga"                   => { :tcg => "Urza's Saga", :type => ExpansionSet, :format => Legacy },
    "Urza's Legacy"                 => { :tcg => "Urza's Legacy", :type => ExpansionSet, :format => Legacy },
    "Classic Sixth Edition"         => { :tcg => "Classic Sixth Edition", :type => CoreSet, :format => Legacy, :display => "Sixth Edition" },
    "Urza's Destiny"                => { :tcg => "Urza's Destiny", :type => ExpansionSet, :format => Legacy },
    "Mercadian Masques"             => { :tcg => "Mercadian Masques", :type => ExpansionSet, :format => Legacy },
    "Nemesis"                       => { :tcg => "Nemesis", :type => ExpansionSet, :format => Legacy },
    "Prophecy"                      => { :tcg => "Prophecy", :type => ExpansionSet, :format => Legacy },
    "Invasion"                      => { :tcg => "Invasion", :type => ExpansionSet, :format => Legacy },
    "Planeshift"                    => { :tcg => "Planeshift", :type => ExpansionSet, :format => Legacy },
    "Seventh Edition"               => { :tcg => "7th Edition", :type => CoreSet, :format => Legacy },
    "Apocalypse"                    => { :tcg => "Apocalypse", :type => ExpansionSet, :format => Legacy },
    "Odyssey"                       => { :tcg => "Odyssey", :type => ExpansionSet, :format => Legacy },
    "Torment"                       => { :tcg => "Torment", :type => ExpansionSet, :format => Legacy },
    "Judgment"                      => { :tcg => "Judgment", :type => ExpansionSet, :format => Legacy },
    "Onslaught"                     => { :tcg => "Onslaught", :type => ExpansionSet, :format => Legacy },
    "Legions"                       => { :tcg => "Legions", :type => ExpansionSet, :format => Legacy },
    "Scourge"                       => { :tcg => "Scourge", :type => ExpansionSet, :format => Legacy },
    "Eighth Edition"                => { :tcg => "8th Edition", :type => CoreSet, :format => Modern },
    "Mirrodin"                      => { :tcg => "Mirrodin", :type => ExpansionSet, :format => Modern },
    "Darksteel"                     => { :tcg => "Darksteel", :type => ExpansionSet, :format => Modern },
    "Fifth Dawn"                    => { :tcg => "Fifth Dawn", :type => ExpansionSet, :format => Modern },
    "Champions of Kamigawa"         => { :tcg => "Champions of Kamigawa", :type => ExpansionSet, :format => Modern },
    "Unhinged"                      => { :tcg => "Unhinged", :type => ExpansionSet, :format => Modern },
    "Betrayers of Kamigawa"         => { :tcg => "Betrayers of Kamigawa", :type => ExpansionSet, :format => Modern },
    "Saviors of Kamigawa"           => { :tcg => "Saviors of Kamigawa", :type => ExpansionSet, :format => Modern },
    "Ninth Edition"                 => { :tcg => "9th Edition", :type => CoreSet, :format => Modern },
    "Ravnica: City of Guilds"       => { :tcg => "Ravnica", :type => ExpansionSet, :format => Modern },
    "Guildpact"                     => { :tcg => "Guildpact", :type => ExpansionSet, :format => Modern },
    "Dissension"                    => { :tcg => "Dissension", :type => ExpansionSet, :format => Modern },
    "Coldsnap"                      => { :tcg => "Coldsnap", :type => ExpansionSet, :format => Modern },
    "Time Spiral"                   => { :tcg => "Time Spiral", :type => ExpansionSet, :format => Modern },
    "Time Spiral \"Timeshifted\""   => { :tcg => "Timeshifted", :type => ExpansionSet, :format => Modern, :display => "Time Spiral (Timeshifted)" },
    "Planar Chaos"                  => { :tcg => "Planar Chaos", :type => ExpansionSet, :format => Modern },
    "Future Sight"                  => { :tcg => "Future Sight", :type => ExpansionSet, :format => Modern },
    "Tenth Edition"                 => { :tcg => "10th Edition", :type => CoreSet, :format => Modern },
    "Lorwyn"                        => { :tcg => "Lorwyn", :type => ExpansionSet, :format => Modern },
    "Morningtide"                   => { :tcg => "Morningtide", :type => ExpansionSet, :format => Modern },
    "Shadowmoor"                    => { :tcg => "Shadowmoor", :type => ExpansionSet, :format => Modern },
    "Eventide"                      => { :tcg => "Eventide", :type => ExpansionSet, :format => Modern },
    "Shards of Alara"               => { :tcg => "Shards of Alara", :type => ExpansionSet, :format => Modern },
    "Conflux"                       => { :tcg => "Conflux", :type => ExpansionSet, :format => Modern },
    "Alara Reborn"                  => { :tcg => "Alara Reborn", :type => ExpansionSet, :format => Modern },
    "Magic 2010"                    => { :tcg => "Magic 2010 (M10)", :type => CoreSet, :format => Modern },
    "Zendikar"                      => { :tcg => "Zendikar", :type => ExpansionSet, :format => Modern },
    "Worldwake"                     => { :tcg => "Worldwake", :type => ExpansionSet, :format => Modern },
    "Rise of the Eldrazi"           => { :tcg => "Rise of the Eldrazi", :type => ExpansionSet, :format => Modern },
    "Magic 2011"                    => { :tcg => "Magic 2011 (M11)", :type => CoreSet, :format => Modern },
    "Scars of Mirrodin"             => { :tcg => "Scars of Mirrodin", :type => ExpansionSet, :format => Modern },
    "Mirrodin Besieged"             => { :tcg => "Mirrodin Besieged", :type => ExpansionSet, :format => Modern },
    "New Phyrexia"                  => { :tcg => "New Phyrexia", :type => ExpansionSet, :format => Modern },
    "Magic 2012"                    => { :tcg => "Magic 2012 (M12)", :type => CoreSet, :format => Modern },
    "Innistrad"                     => { :tcg => "Innistrad", :type => ExpansionSet, :format => Standard },
    "Dark Ascension"                => { :tcg => "Dark Ascension", :type => ExpansionSet, :format => Standard },
    "Avacyn Restored"               => { :tcg => "Avacyn Restored", :type => ExpansionSet, :format => Standard },
    "Magic 2013"                    => { :tcg => "Magic 2013 (M13)", :type => CoreSet, :format => Standard },
    "Return to Ravnica"             => { :tcg => "Return to Ravnica", :type => ExpansionSet, :format => Standard },
    "Gatecrash"                     => { :tcg => "Gatecrash", :type => ExpansionSet, :format => Standard },
    "Dragon's Maze"                 => { :tcg => "Dragon's Maze", :type => ExpansionSet, :format => Standard }
  }
      
end
