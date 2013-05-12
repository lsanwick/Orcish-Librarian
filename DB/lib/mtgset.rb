# encoding: utf-8

class MtgSet 

  include Orcish

  attr_reader :name, :tcg, :display

  def initialize(name, tcg, display)    
    @name = name
    @tcg = tcg
    @display = display    
  end

  def key
    @name.to_file_name
  end

  def to_yaml
    text = [ ]
    text << "name: #{y(@name)}"
    text << "tcg: #{y(@tcg)}" unless @tcg.nil?
    text << "display: #{y(@display)}" unless @display.nil?
    text.join("\n")
  end

  def self.find_by_name(name)
    meta = (@@sets.select { |s| s[:name] == name })[0]
    if meta.nil?
      nil
    else      
      MtgSet.new(meta[:name], meta[:tcg], meta[:display])
    end
  end

  def self.all_sets
    @@sets
  end

  def self.all_set_names
    @@sets.map { |set| set[:name] }
  end

  @@sets = [
    
    # misc. sets          
    { name: "Chronicles" },
    { name: "Portal" },
    { name: "Portal Second Age" },
    { name: "Portal Three Kingdoms" },
    { name: "Starter 1999" },
    { name: "Battle Royale Box Set" },
    { name: "Beatdown Box Set" },    
    { name: "Duel Decks: Elves vs. Goblins" },
    { name: "Duel Decks: Jace vs. Chandra" },
    { name: "Duel Decks: Divine vs. Demonic" },
    { name: "Duel Decks: Garruk vs. Liliana" },
    { name: "Duel Decks: Phyrexia vs. the Coalition" },
    { name: "Duel Decks: Elspeth vs. Tezzeret" },
    { name: "Duel Decks: Knights vs. Dragons", tcg: "Duel Decks: Knights vs Dragons" },
    { name: "Duel Decks: Ajani vs. Nicol Bolas" },
    { name: "Duel Decks: Venser vs. Koth" },
    { name: "Duel Decks: Izzet vs. Golgari" },
    { name: "Duel Decks: Sorin vs. Tibalt" },
    { name: "From the Vault: Dragons" },
    { name: "From the Vault: Exiled" },
    { name: "From the Vault: Relics" },
    { name: "From the Vault: Legends" },
    { name: "From the Vault: Realms" },
    { name: "Premium Deck Series: Slivers" },
    { name: "Premium Deck Series: Fire and Lightning" },
    { name: "Premium Deck Series: Graveborn" },
    { name: "Planechase", display: "Planechase 2010" },
    { name: "Archenemy" },
    { name: "Magic: The Gathering-Commander", tcg: "Commander", display: "Commander" },
    { name: "Planechase 2012 Edition", tcg: "Planechase 2012", display: "Planechase 2012" },
    
    # core and expansion sets
    { name: "Limited Edition Alpha", tcg: "Alpha Edition", display: "Alpha Edition" },
    { name: "Limited Edition Beta", tcg: "Beta Edition", display: "Beta Edition"  },
    { name: "Unlimited Edition" },
    { name: "Arabian Nights" },
    { name: "Antiquities" },
    { name: "Revised Edition" },
    { name: "Legends" },
    { name: "The Dark" },
    { name: "Fallen Empires" },
    { name: "Fourth Edition" },
    { name: "Ice Age" },
    { name: "Homelands" },
    { name: "Alliances" },
    { name: "Mirage" },
    { name: "Visions" },
    { name: "Fifth Edition" },
    { name: "Weatherlight" },
    { name: "Tempest" },
    { name: "Stronghold" },
    { name: "Exodus" },
    { name: "Unglued" },
    { name: "Urza's Saga" },
    { name: "Urza's Legacy" },
    { name: "Classic Sixth Edition", display: "Sixth Edition" },
    { name: "Urza's Destiny" },
    { name: "Mercadian Masques" },
    { name: "Nemesis" },
    { name: "Prophecy" },
    { name: "Invasion" },
    { name: "Planeshift" },
    { name: "Seventh Edition", tcg: "7th Edition" },
    { name: "Apocalypse" },
    { name: "Odyssey" },
    { name: "Torment" },
    { name: "Judgment" },
    { name: "Onslaught" },
    { name: "Legions" },
    { name: "Scourge" },
    { name: "Eighth Edition", tcg: "8th Edition" },
    { name: "Mirrodin" },
    { name: "Darksteel" },
    { name: "Fifth Dawn" },
    { name: "Champions of Kamigawa" },
    { name: "Unhinged" },
    { name: "Betrayers of Kamigawa" },
    { name: "Saviors of Kamigawa" },
    { name: "Ninth Edition", tcg: "9th Edition" },
    { name: "Ravnica: City of Guilds", tcg: "Ravnica" },
    { name: "Guildpact" },
    { name: "Dissension" },
    { name: "Coldsnap", tcg: "Coldsnap" },
    { name: "Time Spiral", tcg: "Time Spiral" },
    { name: "Time Spiral \"Timeshifted\"", tcg: "Timeshifted", display: "Time Spiral (Timeshifted)" },
    { name: "Planar Chaos" },
    { name: "Future Sight" },
    { name: "Tenth Edition", tcg: "10th Edition" },
    { name: "Lorwyn" },
    { name: "Morningtide" },
    { name: "Shadowmoor" },
    { name: "Eventide" },
    { name: "Shards of Alara" },
    { name: "Conflux" },
    { name: "Alara Reborn" },
    { name: "Magic 2010", tcg: "Magic 2010 (M10)" },
    { name: "Zendikar" },
    { name: "Worldwake" },
    { name: "Rise of the Eldrazi" },
    { name: "Magic 2011", tcg: "Magic 2011 (M11)" },
    { name: "Scars of Mirrodin" },
    { name: "Mirrodin Besieged" },
    { name: "New Phyrexia" },
    { name: "Magic 2012", tcg: "Magic 2012 (M12)" },


    { name: "Innistrad" },
    { name: "Dark Ascension" },
    { name: "Avacyn Restored" },
    { name: "Magic 2013", tcg: "Magic 2013 (M13)" },
    { name: "Return to Ravnica" },
    { name: "Gatecrash" },
    { name: "Dragon's Maze" }

  ]

end