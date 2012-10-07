# encoding: utf-8

require 'sqlmaker'

class RulesWriter 

  include SQLMaker
  include Orcish

  def initialize(rules)
    @rules = rules
  end

  def to_sql(io)

    # CREATE TABLE cr_rules
    io.puts(sql_create_table(:cr_rules, {
      :pk => :integer,
      :idx => :integer,
      :parent_pk => :integer,
      :key => :varchar_32,
      :text => :text },
      :pk => :pk))
    
    # CREATE TABLE cr_key_values
    io.puts(sql_create_table(:cr_key_values, {
      :key => :varchar_255,
      :value => :text },
      :pk => :key))

    # CREATE TABLE cr_glossary
    io.puts(sql_create_table(:cr_glossary, {
      :pk => :integer,
      :keyword => :varchar_255,
      :description => :text },
      :pk => :pk))

    ## CREATE INDEXES
    io.puts(sql_create_index(:table => :cr_rules, :column => :parent_pk))
    
    # INSERT effective_date, introduction, credits, footer
    io.puts
    io.puts(sql_insert_row(:cr_key_values, :key => 'effective_date', :value => @rules.effective_date))
    io.puts(sql_insert_row(:cr_key_values, :key => 'introduction', :value => @rules.introduction))
    io.puts(sql_insert_row(:cr_key_values, :key => 'credits', :value => @rules.credits))
    io.puts(sql_insert_row(:cr_key_values, :key => 'footer', :value => @rules.footer))

    # INSERT glossary items
    io.puts
    glossary_pk = 0
    @rules.glossary.each do |entry|      
      glossary_pk = glossary_pk + 1
      entry[:pk] = glossary_pk
      io.puts(sql_insert_row(:cr_glossary, entry))
    end

    # INSERT rules
    io.puts
    rules_idx = 0
    pk_safety = { }
    @rules.rules.each do |entry|
      index = split_index(entry[:index])
      rules_idx = rules_idx + 1
      pk = index.join('.').to_hash
      if pk_safety[pk]
        debug("[ERROR] Duplicate PKs \"#{index.join('.')}\" == \"#{pk_safety[pk]}\"")
        exit -1
      end
      pk_safety[pk] = index.join('.')
      parent_pk = (index.length < 2) ? nil : index.slice(0, index.length - 1).join('.').to_hash
      io.puts(sql_insert_row(:cr_rules, :pk => pk, :idx => rules_idx, 
        :parent_pk => parent_pk, :key => entry[:index], :text => entry[:text]))
    end
    
  end

  def split_index(text)
    parts = [ ]
    # remove trailing period
    text.gsub!(/\.$/, '')
    # trailing alpha (e.g. 303.9b)
    if (m = text.match(/[a-z]+?$/)) 
      parts << m[0]
      text.gsub!(/[a-z]+$/, '')
    end
    # second-level number (303.9)
    if (m = text.match(/\.(\d+)$/))
      parts << m[1]
      text.gsub!(/\.\d+$/, '')
    end
    # extended first-level number (407)
    if text.length > 2
      parts << text.slice!(/\d\d$/)
    end
    # first-level number 4
    parts << text
    parts.reverse
  end

end