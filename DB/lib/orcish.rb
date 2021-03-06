# encoding: utf-8

require 'logger'

module Orcish
  
  CoreSet = 1
  ExpansionSet = 2
  SpecialSet = 3
  
  Standard = 1
  Modern = 2
  Legacy = 3
  
  def self.env=(env)
    @env = env.to_s.downcase
  end
  
  def self.env
    @env
  end
      
  def self.log=(stream)
    @log = stream
  end
  
  def self.log()
    @log
  end
  
  def self.debug(message, name = 'ORCISH')
    @log.puts("#{name}: #{message}")
  end
      
  def debug(message, name = 'ORCISH')
    Orcish.debug(message, name)
  end
    
  def conf
    { }
  end

end