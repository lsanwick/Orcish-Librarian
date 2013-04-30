# encoding: utf-8

require 'zlib'
require 'digest'

class String
  
  @@translations = {
    'Š' => 'S', 'š' => 's', 'Ð' => 'Dj','Ž' => 'Z', 'ž' => 'z', 'À' => 'A', 'Á' => 'A', 'Â' => 'A', 'Ã' => 'A', 'Ä' => 'A', 
    'Å' => 'A', 'Æ' => 'Ae', 'Ç' => 'C', 'È' => 'E', 'É' => 'E', 'Ê' => 'E', 'Ë' => 'E', 'Ì' => 'I', 'Í' => 'I', 'Î' => 'I', 
    'Ï' => 'I', 'Ñ' => 'N', 'Ò' => 'O', 'Ó' => 'O', 'Ô' => 'O', 'Õ' => 'O', 'Ö' => 'O', 'Ø' => 'O', 'Ù' => 'U', 'Ú' => 'U', 
    'Û' => 'U', 'Ü' => 'U', 'Ý' => 'Y', 'Þ' => 'B', 'ß' => 'Ss','à' => 'a', 'á' => 'a', 'â' => 'a', 'ã' => 'a', 'ä' => 'a', 
    'å' => 'a', 'æ' => 'ae', 'ç' => 'c', 'è' => 'e', 'é' => 'e', 'ê' => 'e', 'ë' => 'e', 'ì' => 'i', 'í' => 'i', 'î' => 'i', 
    'ï' => 'i', 'ð' => 'o', 'ñ' => 'n', 'ò' => 'o', 'ó' => 'o', 'ô' => 'o', 'õ' => 'o', 'ö' => 'o', 'ø' => 'o', 'ù' => 'u', 
    'ú' => 'u', 'û' => 'u', 'ý' => 'y', 'ý' => 'y', 'þ' => 'b', 'ÿ' => 'y', 'ƒ' => 'f',
    '<br />' => "\n",
    /\s+—\s+/ => ' - ' 
  }
  
  @@tcg_translations = {
    '"' => '',
    'ö' => 'o', 'Ö' => 'O',
    'Æ' => 'AE', 'æ' => 'ae'
  }
  
  def clean()   
    result = self.dup
    @@translations.each_pair do |search, replace|
      result.gsub!(search, replace)
    end    
    result
  end
  
  def to_display_name()
    # Gatherer lists "Kill! Destroy!" as "Kill Destroy"
    if self == 'Kill Destroy'
      return 'Kill! Destroy!'
    end
    # "Erase" from Unhinged is the only card that contains 
    # literal parentheses in its card name
    if self == "Erase (Not the Urza's Legacy One)"
      return self
    end
    # XXValor (Valor)
    if /^XX(.*)\s\((.*)\)/.match(self) && $1 == $2
      return $1
    end
    # Dead // Gone (Gone)  
    if /^(.*)\s\/\/\s(.*)\s\((.*)\)$/.match(self) then
      return "#{$3} (#{$1} // #{$2})"
    end
    # Nezumi Graverobber (Nighteyes the Desecrator)
    if /^(.*)\s\((.*)\)$/.match(self) then
      return $2
    end    
    # everything else
    self.gsub(/^XX(.*)\s+\(.*\)$/, '\1')
  end
  
  def to_tcg_name()
    result = self.dup.to_display_name
    # expects "Bösium Strip" but not "Jötun Grunt"
    if result == 'Bösium Strip'
      return result
    end    
    # expects "(Assault // Battery)"
    result.gsub!(/^.*\((.*)\s\/\/\s(.*)\)$/, '\1 // \2');
    @@tcg_translations.each_pair do |search, replace|
      result.gsub!(search, replace)
    end    
    result
  end
  
  def to_spell_name()     
    # "Erase" from Unhinged is the only card that contains 
    # literal parentheses in its card name
    if self == "Erase (Not the Urza's Legacy One)"
      return self
    end
    # XXValor (Valor)
    if /^XX(.*)\s\((.*)\)/.match(self) && $1 == $2
      return $1
    end
    # Dead // Gone (Gone)  
    if /^(.*)\s\/\/\s(.*)\s\((.*)\)$/.match(self) then
      return $3
    end
    # Nezumi Graverobber (Nighteyes the Desecrator)
    if /^(.*)\s\((.*)\)$/.match(self) then
      return $2
    end    
    # everything else
    self.gsub(/^XX(.*)\s+\(.*\)$/, '\1')
  end
  
  def to_searchable_name()
    result = self.to_display_name.clean.upcase
    # "Erase" from Unhinged is the only card that contains 
    # literal parentheses in its card name
    if result != "ERASE (NOT THE URZA'S LEGACY ONE)"
      result = result.gsub(/\(.*?\)/, '')   # remove parethetical text
    end
    result = result.gsub(/[^A-Z0-9_]/, '')   # remove non-alphanumeric characters
    result
  end
  
  def to_name_hash()
    result = self.clean.to_searchable_name
    return result.to_ol_hash
  end

  def to_ol_hash()    
    result = (Digest::SHA256.new << self).to_s
    return Zlib::crc32(result).to_s
  end
  
end
