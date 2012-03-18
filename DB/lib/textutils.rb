
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
  
  def clean()    
    result = self
    @@translations.each_pair do |search, replace|
      result.gsub!(search, replace)
    end
    result
  end
  
  def to_normalized_name()
    if /^(.*)\s\/\/\s(.*)\s\((.*)\)/.match(self) then
      # Dead // Gone (Gone)  
      "#{$3} (#{$1} // #{$2})"
    elsif /(.*)\s\(.*\/.*\)/.match(self) then
      # Gone (Dead/Gone)
      "#{$1} (#{$2} // #{$3})"
    else
      # everything else
      self.gsub(/^XX(.*)\s+\(.*\)$/, '\1')
    end
  end
  
  def to_searchable_name()
    result = self.upcase                    # all upper-case
    result = result.gsub(/\(.*?\)/, '')     # remove parethetical text
    result = result.gsub(/[^A-Z0-9]/, '')   # remove non-alphanumeric characters
    result = result.strip                   # trim whitespace
  end
  
end
