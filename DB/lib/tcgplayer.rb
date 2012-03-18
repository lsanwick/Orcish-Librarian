
require 'source'

class TCGPlayer < Source

  def fetch_sets
    sets = [ ]
    doc = fetch_document('http://magic.tcgplayer.com/all_magic_sets.asp')
    doc.search("td[@width=645] a[@href*='Set_Name']").each do |link|
      name = link['href'].gsub(/^.*Set_Name=/, '').strip
      sets << name if name.length > 0
    end
    if sets.length < 100
      log("Error: Found less sets on TCGPlayer (#{sets.length}) than expected.")
    else
      log("Found #{sets.length} sets on TCGPlayer.")
    end
    sets
  end
  
  def normalize_set_name(name)
    name = name.gsub(/\bMagic\b/i, ' ')
    name = name.gsub(/\bEdition\b/i, ' ')
    name = name.gsub(/\bLimited\b/i, ' ')
    name = name.gsub(/\s/, '')
    name
  end
  
  def translations
    if @translations.nil?
      @translations = {
        'Fifth Dawn' => 'Eighth Edition',
        'Fifth Dawn' => 'Fifth Dawn',
        'Fifth Dawn' => 'Fifth Edition',
        'Shards of Alara' => 'Limited Edition Alpha',
        'Beatdown Box Set' => 'Limited Edition Beta',
        'Magic 2010' => 'Magic 2010',
        'Magic 2010' => 'Magic 2011',
        'Magic 2010' => 'Magic 2012',
        'Magic Player Rewards' => 'Magic: The Gathering-Commander',
        'Antiquities' => 'Ninth Edition',
        'Saviors of Kamigawa' => 'Promo set for Gatherer',
        'Launch Party Cards' => 'Ravnica: City of Guilds',
        'Antiquities' => 'Seventh Edition',
        'Antiquities' => 'Tenth Edition',
        'Time Spiral' => 'Time Spiral',
        'Time Spiral' => 'Time Spiral "Timeshifted"'
      }      
    end
    @translations
  end
  
end
