
require 'logger'

module Orcish
  
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
    
  def cache_enabled?
    true
  end
    
  def cache_path
    'data/net-cache'
  end 
  
end