# encoding: utf-8

class Rules
  
  attr_reader \
    :effective_date, 
    :introduction, 
    :table_of_contents, 
    :rules, 
    :glossary, 
    :credits,
    :footer
    
  def initialize(text)    
    process_text(text)    
  end

  def process_text(text)
    text.gsub!(/\r\n/, "\n")
    @effective_date = find_effective_date(text)
    @introduction = find_introduction(text)
    @table_of_contents = find_table_of_contents(text)
    @rules = find_rules(text)
    @glossary = find_glossary(text)
    @credits = find_credits(text)
    @footer = find_footer(text)
  end
  
  def capture(regex, text)
    result = ''
    matches = text.scan(regex)
    if !matches.nil?
      result = matches[0][0]
    end
    result.strip
  end
  
  def find_effective_date(text)
    capture(/These rules are effective as of (.*)\./, text)
  end
  
  def find_introduction(text)
    capture(/^Introduction\s*$(.*?)^Contents\s*$/m, text)
  end
  
  def find_credits(text)
    capture(/^Credits\s*$.*^Credits\s*$(.*)These rules are effective as of/m, text)
  end
  
  def find_footer(text)
    capture(/^These rules are effective.*$.*^(These rules are effective.*)/m, text)
  end
  
  def find_rules(text)
    text = capture(/^Customer Service Information\s*(1\. Game Concepts.*?)^Glossary\s*$/m, text)
    rules = text.split("\n\n")
    rules.map do |rule|
      split_point = rule.index(' ')
      { :index => rule[0...split_point].strip, :text => rule[(split_point+1)..-1].strip }
    end
  end
  
  def find_table_of_contents(text)
    text = capture(/^Contents\s*(.*?^Customer Service Information)\s*$/m, text)
    text.split(/\n+/)
  end
  
  def find_glossary(text)
    text = capture(/^Glossary\s*$.*^Glossary\s*$(.*)^Credits\s*$/m, text)
    entries = text.split(/\n\n/)
    entries.map do |e| 
      { :keyword => capture(/(^.*?)$/m, e), :description => capture(/^.*?$(.*)/m, e) } 
    end
  end
  
end
