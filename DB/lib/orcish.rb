# encoding: utf-8

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
    @log || $stderr
  end
  
  def self.debug(message, name = 'ORCISH')
    log.puts("#{name}: #{message}")
  end
      
  def debug(message, name = 'ORCISH')
    Orcish.debug(message, name)
  end
    
  def conf
    { }
  end

  def y(obj, opts = { })
    if obj.class == Array
      '[ ' + (obj.map { |val| y(val, in_array: true) }).join(', ') + ' ]'
    else    
      if obj.to_s.to_i == obj.to_s
        obj.to_s.to_i
      else
        if obj.to_s.include?("\n") || opts[:force_block_text]
          "|\n " + obj.gsub(/\n/, "\n ")
        elsif (opts[:in_array] && obj.to_s.include?(',')) || obj.to_s.match(/(^'|'$|^\{|\}$|^\*|:)/)
          obj = "'#{obj.to_s.gsub(/'/,"''")}'"
        else
          obj.to_s
        end
      end
    end
  end

end