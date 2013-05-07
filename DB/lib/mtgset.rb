# encoding: utf-8

class MtgSet 

  include Orcish

  attr_reader :name, :tcg_name, :display_name, :type, :format
  attr_reader :cards

  def initialize(name)
    @cards = [ ]
    @name = name
    meta = (@@sets.select { |s| s[:name] == name })[0]
    if !meta.nil?
      @tcg_name = meta[:tcg_name] || @name
      @display_name = meta[:display_name] || @name
      @type = meta[:type] || SpecialSet
      @format = meta[:format] || Legacy
    end
  end

  def add(addition)
    if addition.class == Array
      @cards = @cards.concat(addition)
    else
      @cards << addition
    end
  end

  def self.all_sets
    @@sets
  end

  def self.all_set_names
    @@sets.map { |set| set[:name] }
  end

  def to_s
    "[#{@name} — #{@cards.length}]"
  end

  @@sets = [
    
    # misc. sets          
    { name: "Chronicles",                                  tcg_name: "Chronicles", type: SpecialSet },
    { name: "Portal",                                      tcg_name: "Portal", type: SpecialSet },
    { name: "Portal Second Age",                           tcg_name: "Portal Second Age", type: SpecialSet },
    { name: "Portal Three Kingdoms",                       tcg_name: "Portal Three Kingdoms", type: SpecialSet },
    { name: "Starter 1999",                                tcg_name: "Starter 1999", type: SpecialSet },
    { name: "Battle Royale Box Set",                       tcg_name: "Battle Royale Box Set", type: SpecialSet },
    { name: "Beatdown Box Set",                            tcg_name: "Beatdown Box Set", type: SpecialSet },    
    { name: "Duel Decks: Elves vs. Goblins",               tcg_name: "Duel Decks: Elves vs. Goblins", type: SpecialSet },
    { name: "Duel Decks: Jace vs. Chandra",                tcg_name: "Duel Decks: Jace vs. Chandra", type: SpecialSet },
    { name: "Duel Decks: Divine vs. Demonic",              tcg_name: "Duel Decks: Divine vs. Demonic", type: SpecialSet },
    { name: "Duel Decks: Garruk vs. Liliana",              tcg_name: "Duel Decks: Garruk vs. Liliana", type: SpecialSet },
    { name: "Duel Decks: Phyrexia vs. the Coalition",      tcg_name: "Duel Decks: Phyrexia vs. the Coalition", type: SpecialSet },
    { name: "Duel Decks: Elspeth vs. Tezzeret",            tcg_name: "Duel Decks: Elspeth vs. Tezzeret", type: SpecialSet },
    { name: "Duel Decks: Knights vs. Dragons",             tcg_name: "Duel Decks: Knights vs Dragons", type: SpecialSet },
    { name: "Duel Decks: Ajani vs. Nicol Bolas",           tcg_name: "Duel Decks: Ajani vs. Nicol Bolas", type: SpecialSet },
    { name: "Duel Decks: Venser vs. Koth",                 tcg_name: "Duel Decks: Venser vs. Koth", type: SpecialSet },
    { name: "Duel Decks: Izzet vs. Golgari",               tcg_name: "Duel Decks: Izzet vs. Golgari", type: SpecialSet },
    { name: "Duel Decks: Sorin vs. Tibalt",                tcg_name: "Duel Decks: Sorin vs. Tibalt", type: SpecialSet },
    { name: "From the Vault: Dragons",                     tcg_name: "From the Vault: Dragons", type: SpecialSet },
    { name: "From the Vault: Exiled",                      tcg_name: "From the Vault: Exiled", type: SpecialSet },
    { name: "From the Vault: Relics",                      tcg_name: "From the Vault: Relics", type: SpecialSet },
    { name: "From the Vault: Legends",                     tcg_name: "From the Vault: Legends", type: SpecialSet },
    { name: "From the Vault: Realms",                      tcg_name: "From the Vault: Realms", type: SpecialSet },
    { name: "Premium Deck Series: Slivers",                tcg_name: "Premium Deck Series: Slivers", type: SpecialSet },
    { name: "Premium Deck Series: Fire and Lightning",     tcg_name: "Premium Deck Series: Fire and Lightning", type: SpecialSet },
    { name: "Premium Deck Series: Graveborn",              tcg_name: "Premium Deck Series: Graveborn", type: SpecialSet },
    { name: "Planechase",                                  tcg_name: "Planechase", type: SpecialSet, display_name: "Planechase 2010" },
    { name: "Archenemy",                                   tcg_name: "Archenemy", type: SpecialSet },
    { name: "Magic: The Gathering-Commander",              tcg_name: "Commander", type: SpecialSet, display_name: "Commander" },
    { name: "Planechase 2012 Edition",                     tcg_name: "Planechase 2012", type: SpecialSet, display_name: "Planechase 2012" },
    
    # core and expansion sets
    { name: "Limited Edition Alpha",       tcg_name: "Alpha Edition", type: CoreSet, format: Legacy, display_name: "Alpha Edition" },
    { name: "Limited Edition Beta",        tcg_name: "Beta Edition", type: CoreSet, format: Legacy, display_name: "Beta Edition"  },
    { name: "Unlimited Edition",           tcg_name: "Unlimited Edition", type: CoreSet, format: Legacy },
    { name: "Arabian Nights",              tcg_name: "Arabian Nights", type: ExpansionSet, format: Legacy },
    { name: "Antiquities",                 tcg_name: "Antiquities", type: ExpansionSet, format: Legacy },
    { name: "Revised Edition",             tcg_name: "Revised Edition", type: CoreSet, format: Legacy },
    { name: "Legends",                     tcg_name: "Legends", type: ExpansionSet, format: Legacy },
    { name: "The Dark",                    tcg_name: "The Dark", type: ExpansionSet, format: Legacy },
    { name: "Fallen Empires",              tcg_name: "Fallen Empires", type: ExpansionSet, format: Legacy },
    { name: "Fourth Edition",              tcg_name: "Fourth Edition", type: CoreSet, format: Legacy },
    { name: "Ice Age",                     tcg_name: "Ice Age", type: ExpansionSet, format: Legacy },
    { name: "Homelands",                   tcg_name: "Homelands", type: ExpansionSet, format: Legacy },
    { name: "Alliances",                   tcg_name: "Alliances", type: ExpansionSet, format: Legacy },
    { name: "Mirage",                      tcg_name: "Mirage", type: ExpansionSet, format: Legacy },
    { name: "Visions",                     tcg_name: "Visions", type: ExpansionSet, format: Legacy },
    { name: "Fifth Edition",               tcg_name: "Fifth Edition", type: CoreSet, format: Legacy },
    { name: "Weatherlight",                tcg_name: "Weatherlight", type: ExpansionSet, format: Legacy },
    { name: "Tempest",                     tcg_name: "Tempest", type: ExpansionSet, format: Legacy },
    { name: "Stronghold",                  tcg_name: "Stronghold", type: ExpansionSet, format: Legacy },
    { name: "Exodus",                      tcg_name: "Exodus", type: ExpansionSet, format: Legacy },    
    { name: "Unglued",                     tcg_name: "Unglued", type: ExpansionSet, format: Legacy },
    { name: "Urza's Saga",                 tcg_name: "Urza's Saga", type: ExpansionSet, format: Legacy },
    { name: "Urza's Legacy",               tcg_name: "Urza's Legacy", type: ExpansionSet, format: Legacy },
    { name: "Classic Sixth Edition",       tcg_name: "Classic Sixth Edition", type: CoreSet, format: Legacy, display_name: "Sixth Edition" },
    { name: "Urza's Destiny",              tcg_name: "Urza's Destiny", type: ExpansionSet, format: Legacy },
    { name: "Mercadian Masques",           tcg_name: "Mercadian Masques", type: ExpansionSet, format: Legacy },
    { name: "Nemesis",                     tcg_name: "Nemesis", type: ExpansionSet, format: Legacy },
    { name: "Prophecy",                    tcg_name: "Prophecy", type: ExpansionSet, format: Legacy },
    { name: "Invasion",                    tcg_name: "Invasion", type: ExpansionSet, format: Legacy },
    { name: "Planeshift",                  tcg_name: "Planeshift", type: ExpansionSet, format: Legacy },
    { name: "Seventh Edition",             tcg_name: "7th Edition", type: CoreSet, format: Legacy },
    { name: "Apocalypse",                  tcg_name: "Apocalypse", type: ExpansionSet, format: Legacy },
    { name: "Odyssey",                     tcg_name: "Odyssey", type: ExpansionSet, format: Legacy },
    { name: "Torment",                     tcg_name: "Torment", type: ExpansionSet, format: Legacy },
    { name: "Judgment",                    tcg_name: "Judgment", type: ExpansionSet, format: Legacy },
    { name: "Onslaught",                   tcg_name: "Onslaught", type: ExpansionSet, format: Legacy },
    { name: "Legions",                     tcg_name: "Legions", type: ExpansionSet, format: Legacy },
    { name: "Scourge",                     tcg_name: "Scourge", type: ExpansionSet, format: Legacy },
    { name: "Eighth Edition",              tcg_name: "8th Edition", type: CoreSet, format: Modern },
    { name: "Mirrodin",                    tcg_name: "Mirrodin", type: ExpansionSet, format: Modern },
    { name: "Darksteel",                   tcg_name: "Darksteel", type: ExpansionSet, format: Modern },
    { name: "Fifth Dawn",                  tcg_name: "Fifth Dawn", type: ExpansionSet, format: Modern },
    { name: "Champions of Kamigawa",       tcg_name: "Champions of Kamigawa", type: ExpansionSet, format: Modern },
    { name: "Unhinged",                    tcg_name: "Unhinged", type: ExpansionSet, format: Modern },
    { name: "Betrayers of Kamigawa",       tcg_name: "Betrayers of Kamigawa", type: ExpansionSet, format: Modern },
    { name: "Saviors of Kamigawa",         tcg_name: "Saviors of Kamigawa", type: ExpansionSet, format: Modern },
    { name: "Ninth Edition",               tcg_name: "9th Edition", type: CoreSet, format: Modern },
    { name: "Ravnica: City of Guilds",     tcg_name: "Ravnica", type: ExpansionSet, format: Modern },
    { name: "Guildpact",                   tcg_name: "Guildpact", type: ExpansionSet, format: Modern },
    { name: "Dissension",                  tcg_name: "Dissension", type: ExpansionSet, format: Modern },
    { name: "Coldsnap",                    tcg_name: "Coldsnap", type: ExpansionSet, format: Modern },
    { name: "Time Spiral",                 tcg_name: "Time Spiral", type: ExpansionSet, format: Modern },
    { name: "Time Spiral \"Timeshifted\"", tcg_name: "Timeshifted", type: ExpansionSet, format: Modern, display_name: "Time Spiral (Timeshifted)" },
    { name: "Planar Chaos",                tcg_name: "Planar Chaos", type: ExpansionSet, format: Modern },
    { name: "Future Sight",                tcg_name: "Future Sight", type: ExpansionSet, format: Modern },
    { name: "Tenth Edition",               tcg_name: "10th Edition", type: CoreSet, format: Modern },
    { name: "Lorwyn",                      tcg_name: "Lorwyn", type: ExpansionSet, format: Modern },
    { name: "Morningtide",                 tcg_name: "Morningtide", type: ExpansionSet, format: Modern },
    { name: "Shadowmoor",                  tcg_name: "Shadowmoor", type: ExpansionSet, format: Modern },
    { name: "Eventide",                    tcg_name: "Eventide", type: ExpansionSet, format: Modern },
    { name: "Shards of Alara",             tcg_name: "Shards of Alara", type: ExpansionSet, format: Modern },
    { name: "Conflux",                     tcg_name: "Conflux", type: ExpansionSet, format: Modern },
    { name: "Alara Reborn",                tcg_name: "Alara Reborn", type: ExpansionSet, format: Modern },
    { name: "Magic 2010",                  tcg_name: "Magic 2010 (M10)", type: CoreSet, format: Modern },
    { name: "Zendikar",                    tcg_name: "Zendikar", type: ExpansionSet, format: Modern },
    { name: "Worldwake",                   tcg_name: "Worldwake", type: ExpansionSet, format: Modern },
    { name: "Rise of the Eldrazi",         tcg_name: "Rise of the Eldrazi", type: ExpansionSet, format: Modern },
    { name: "Magic 2011",                  tcg_name: "Magic 2011 (M11)", type: CoreSet, format: Modern },
    { name: "Scars of Mirrodin",           tcg_name: "Scars of Mirrodin", type: ExpansionSet, format: Modern },
    { name: "Mirrodin Besieged",           tcg_name: "Mirrodin Besieged", type: ExpansionSet, format: Modern },
    { name: "New Phyrexia",                tcg_name: "New Phyrexia", type: ExpansionSet, format: Modern },
    { name: "Magic 2012",                  tcg_name: "Magic 2012 (M12)", type: CoreSet, format: Modern },
    { name: "Innistrad",                   tcg_name: "Innistrad", type: ExpansionSet, format: Standard },
    { name: "Dark Ascension",              tcg_name: "Dark Ascension", type: ExpansionSet, format: Standard },
    { name: "Avacyn Restored",             tcg_name: "Avacyn Restored", type: ExpansionSet, format: Standard },
    { name: "Magic 2013",                  tcg_name: "Magic 2013 (M13)", type: CoreSet, format: Standard },
    { name: "Return to Ravnica",           tcg_name: "Return to Ravnica", type: ExpansionSet, format: Standard },
    { name: "Gatecrash",                   tcg_name: "Gatecrash", type: ExpansionSet, format: Standard },
    { name: "Dragon's Maze",               tcg_name: "Dragon's Maze", type: ExpansionSet, format: Standard }

  ]

end