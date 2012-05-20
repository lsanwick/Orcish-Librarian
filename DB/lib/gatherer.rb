# encoding: utf-8

require 'source'
require 'textutils'

class Gatherer < Source

  CoreSet = 1
  ExpansionSet = 2
  SpecialSet = 3

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
        debug("WARNING: No spoiler entry for #{name}")
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
      name = cells[1].at('a').inner_text.strip.to_normalized_name
      others = cards[name] = cards[name] || [ ]
      entry = {
        :gatherer_id =>  cells[1].at('a')['href'].gsub(/^.*multiverseid=(\d+)$/, '\1'),
        :name => name,
        :artist => cells[2].inner_text,
        :collector_number => cells[0].inner_text,
        :rarity => cells[4].inner_text
      }
      if (others.length == 0 || others[0][:collector_number] != entry[:collector_number] || entry[:collector_number] == '')
        others << entry  
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
          current_card[:name] = value.inner_text.strip.to_normalized_name
          current_card[:display_name] = value.inner_text.strip.to_display_name
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
        is_token = (current_card[:mana_cost].nil? || current_card[:mana_cost] == '') && current_card[:type_line] == "Creature - #{current_card[:name]}"
        if !is_token
          cards[current_card[:name]] = current_card 
        end
        current_card = { }
      end
    end
    cards
  end
      
  @@sets = {
    
    # misc. sets          
    "Chronicles" => { :tcg => "Chronicles", :type => SpecialSet },
    "Portal" => { :tcg => "Portal", :type => SpecialSet },
    "Portal Second Age" => { :tcg => "Portal Second Age", :type => SpecialSet },
    "Portal Three Kingdoms" => { :tcg => "Portal Three Kingdoms", :type => SpecialSet },
    "Starter 1999" => { :tcg => "Starter 1999", :type => SpecialSet },
    "Battle Royale Box Set" => { :tcg => "Battle Royale Box Set", :type => SpecialSet },
    "Beatdown Box Set"              => { :tcg => "Beatdown Box Set", :type => SpecialSet },    
    "Duel Decks: Elves vs. Goblins" => { :tcg => "Duel Decks: Elves vs. Goblins", :type => SpecialSet },
    "Duel Decks: Jace vs. Chandra" => { :tcg => "Duel Decks: Jace vs. Chandra", :type => SpecialSet },
    "Duel Decks: Divine vs. Demonic" => { :tcg => "Duel Decks: Divine vs. Demonic", :type => SpecialSet },
    "Duel Decks: Garruk vs. Liliana" => { :tcg => "Duel Decks: Garruk vs. Liliana", :type => SpecialSet },
    "Duel Decks: Phyrexia vs. the Coalition" => { :tcg => "Duel Decks: Phyrexia vs. the Coalition", :type => SpecialSet },
    "Duel Decks: Elspeth vs. Tezzeret" => { :tcg => "Duel Decks: Elspeth vs. Tezzeret", :type => SpecialSet },
    "Duel Decks: Knights vs. Dragons" => { :tcg => "Duel Decks: Knights vs Dragons", :type => SpecialSet },
    "Duel Decks: Ajani vs. Nicol Bolas" => { :tcg => "Duel Decks: Ajani vs. Nicol Bolas", :type => SpecialSet },
    "Duel Decks: Venser vs. Koth" => { :tcg => "Duel Decks: Venser vs. Koth", :type => SpecialSet },
    "From the Vault: Dragons" => { :tcg => "From the Vault: Dragons", :type => SpecialSet },
    "From the Vault: Exiled" => { :tcg => "From the Vault: Exiled", :type => SpecialSet },
    "From the Vault: Relics" => { :tcg => "From the Vault: Relics", :type => SpecialSet },
    "From the Vault: Legends" => { :tcg => "From the Vault: Legends", :type => SpecialSet },
    "Premium Deck Series: Slivers" => { :tcg => "Premium Deck Series: Slivers", :type => SpecialSet },
    "Premium Deck Series: Fire and Lightning" => { :tcg => "Premium Deck Series: Fire and Lightning", :type => SpecialSet },
    "Premium Deck Series: Graveborn" => { :tcg => "Premium Deck Series: Graveborn", :type => SpecialSet },
    "Planechase" => { :tcg => "Planechase", :type => SpecialSet },
    "Archenemy" => { :tcg => "Archenemy", :type => SpecialSet },
    "Magic: The Gathering-Commander" => { :tcg => "Commander", :type => SpecialSet },
    
    # core and expansion sets
    "Limited Edition Alpha"         => { :tcg => "Alpha Edition", :type => CoreSet },
    "Limited Edition Beta"          => { :tcg => "Beta Edition", :type => CoreSet },
    "Unlimited Edition"             => { :tcg => "Unlimited Edition", :type => CoreSet },
    "Arabian Nights"                => { :tcg => "Arabian Nights", :type => ExpansionSet },
    "Antiquities"                   => { :tcg => "Antiquities", :type => ExpansionSet },
    "Revised Edition"               => { :tcg => "Revised Edition", :type => CoreSet },
    "Legends"                       => { :tcg => "Legends", :type => ExpansionSet },
    "The Dark"                      => { :tcg => "The Dark", :type => ExpansionSet },
    "Fallen Empires"                => { :tcg => "Fallen Empires", :type => ExpansionSet },
    "Fourth Edition"                => { :tcg => "Fourth Edition", :type => CoreSet },
    "Ice Age"                       => { :tcg => "Ice Age", :type => ExpansionSet },
    "Homelands"                     => { :tcg => "Homelands", :type => ExpansionSet },
    "Alliances"                     => { :tcg => "Alliances", :type => ExpansionSet },
    "Mirage"                        => { :tcg => "Mirage", :type => ExpansionSet },
    "Visions"                       => { :tcg => "Visions", :type => ExpansionSet },
    "Fifth Edition"                 => { :tcg => "Fifth Edition", :type => CoreSet },
    "Weatherlight"                  => { :tcg => "Weatherlight", :type => ExpansionSet },
    "Tempest"                       => { :tcg => "Tempest", :type => ExpansionSet },
    "Stronghold"                    => { :tcg => "Stronghold", :type => ExpansionSet },
    "Exodus"                        => { :tcg => "Exodus", :type => ExpansionSet },    
    "Unglued"                       => { :tcg => "Unglued", :type => ExpansionSet },
    "Urza's Saga"                   => { :tcg => "Urza's Saga", :type => ExpansionSet },
    "Urza's Legacy"                 => { :tcg => "Urza's Legacy", :type => ExpansionSet },
    "Classic Sixth Edition"         => { :tcg => "Classic Sixth Edition", :type => CoreSet },
    "Urza's Destiny"                => { :tcg => "Urza's Destiny", :type => ExpansionSet },
    "Mercadian Masques"             => { :tcg => "Mercadian Masques", :type => ExpansionSet },
    "Nemesis"                       => { :tcg => "Nemesis", :type => ExpansionSet },
    "Prophecy"                      => { :tcg => "Prophecy", :type => ExpansionSet },
    "Invasion"                      => { :tcg => "Invasion", :type => ExpansionSet },
    "Planeshift"                    => { :tcg => "Planeshift", :type => ExpansionSet },
    "Seventh Edition"               => { :tcg => "7th Edition", :type => CoreSet },
    "Apocalypse"                    => { :tcg => "Apocalypse", :type => ExpansionSet },
    "Odyssey"                       => { :tcg => "Odyssey", :type => ExpansionSet },
    "Torment"                       => { :tcg => "Torment", :type => ExpansionSet },
    "Judgment"                      => { :tcg => "Judgment", :type => ExpansionSet },
    "Onslaught"                     => { :tcg => "Onslaught", :type => ExpansionSet },
    "Legions"                       => { :tcg => "Legions", :type => ExpansionSet },
    "Scourge"                       => { :tcg => "Scourge", :type => ExpansionSet },
    "Eighth Edition"                => { :tcg => "8th Edition", :type => CoreSet },
    "Mirrodin"                      => { :tcg => "Mirrodin", :type => ExpansionSet },
    "Darksteel"                     => { :tcg => "Darksteel", :type => ExpansionSet },
    "Fifth Dawn"                    => { :tcg => "Fifth Dawn", :type => ExpansionSet },
    "Champions of Kamigawa"         => { :tcg => "Champions of Kamigawa", :type => ExpansionSet },
    "Unhinged"                      => { :tcg => "Unhinged", :type => ExpansionSet },
    "Betrayers of Kamigawa"         => { :tcg => "Betrayers of Kamigawa", :type => ExpansionSet },
    "Saviors of Kamigawa"           => { :tcg => "Saviors of Kamigawa", :type => ExpansionSet },
    "Ninth Edition"                 => { :tcg => "9th Edition", :type => CoreSet },
    "Ravnica: City of Guilds"       => { :tcg => "Ravnica", :type => ExpansionSet },
    "Guildpact"                     => { :tcg => "Guildpact", :type => ExpansionSet },
    "Dissension"                    => { :tcg => "Dissension", :type => ExpansionSet },
    "Coldsnap"                      => { :tcg => "Coldsnap", :type => ExpansionSet },
    "Time Spiral"                   => { :tcg => "Time Spiral", :type => ExpansionSet },
    "Time Spiral \"Timeshifted\""   => { :tcg => "Timeshifted", :type => ExpansionSet },
    "Planar Chaos"                  => { :tcg => "Planar Chaos", :type => ExpansionSet },
    "Future Sight"                  => { :tcg => "Future Sight", :type => ExpansionSet },
    "Tenth Edition"                 => { :tcg => "10th Edition", :type => CoreSet },
    "Lorwyn"                        => { :tcg => "Lorwyn", :type => ExpansionSet },
    "Morningtide"                   => { :tcg => "Morningtide", :type => ExpansionSet },
    "Shadowmoor"                    => { :tcg => "Shadowmoor", :type => ExpansionSet },
    "Eventide"                      => { :tcg => "Eventide", :type => ExpansionSet },
    "Shards of Alara"               => { :tcg => "Shards of Alara", :type => ExpansionSet },
    "Conflux"                       => { :tcg => "Conflux", :type => ExpansionSet },
    "Alara Reborn"                  => { :tcg => "Alara Reborn", :type => ExpansionSet },
    "Magic 2010"                    => { :tcg => "Magic 2010 (M10)", :type => CoreSet },
    "Zendikar"                      => { :tcg => "Zendikar", :type => ExpansionSet },
    "Worldwake"                     => { :tcg => "Worldwake", :type => ExpansionSet },
    "Rise of the Eldrazi"           => { :tcg => "Rise of the Eldrazi", :type => ExpansionSet },
    "Magic 2011"                    => { :tcg => "Magic 2011 (M11)", :type => CoreSet },
    "Scars of Mirrodin"             => { :tcg => "Scars of Mirrodin", :type => ExpansionSet },
    "Mirrodin Besieged"             => { :tcg => "Mirrodin Besieged", :type => ExpansionSet },
    "New Phyrexia"                  => { :tcg => "New Phyrexia", :type => ExpansionSet },
    "Magic 2012"                    => { :tcg => "Magic 2012 (M12)", :type => CoreSet },
    "Innistrad"                     => { :tcg => "Innistrad", :type => ExpansionSet },
    "Dark Ascension"                => { :tcg => "Dark Ascension", :type => ExpansionSet },
    "Avacyn Restored"               => { :tcg => "Avacyn Restored", :type => ExpansionSet }
  }
      
end
