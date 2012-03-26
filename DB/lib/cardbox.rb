# encoding: utf-8

require 'yaml'
require 'tempfile'
require 'sqlmaker'

class CardBox 
  
  include Orcish
  include SQLMaker
  
  def initialize()
    @data = { :sets => [ ], :cards => { }, :names => { } }
  end
  
  def save(path, format = :json)
    self.send("save_as_#{format}", path)
  end
  
  def add(cards, set)    
    @data[:sets] << set
    @data[:cards][set] = (@data[:cards][set] || [ ]) + cards
    cards.each do |card|
      if @data[:names][card[:name]].nil?
        @data[:names][card[:name]] = 1
      else
        @data[:names][card[:name]] += 1
      end
    end
  end
  
  private
  
  def save_as_json(path)
    open(path, 'w') {|io| io.write(JSON.pretty_generate(@data)) }
  end
  
  def save_as_yaml(path)
    open(path, 'w') {|io| YAML.dump(@data, io) }
  end
  
  def save_as_sqlite(path)
    debug("Generating SQL script")
    temp_file = Tempfile.new("orcish")    
    create_sql(temp_file, @data)
    temp_file.close
    FileUtils.rm(path) if File.exists?(path)
    debug("Executing SQL script")
    val = %x[sqlite3 #{path} < #{temp_file.path}]
    temp_file.unlink
  end
  
  def save_as_names(path)
    names = { }
    numbers = { }
    open(path, 'w') do |io| 
      @data[:sets].each do |set|
        @data[:cards][set].each do |card|
          name = card[:name].to_searchable_name
          if names[name].nil?
            searchable_name = card[:name].to_searchable_name
            searchable_hash = card[:name].to_name_hash.to_s
            io.write('|' + searchable_name)
            io.write('|' + searchable_hash)
            names[searchable_name] = true
            if !numbers[searchable_hash].nil?
              debug("WARNING: repeated search name hash: \"#{searchable_name}\" and \"#{numbers[searchable_hash]}\"")
            end  
            numbers[searchable_hash] = searchable_name
          end
        end
      end
      io.write('|')
    end
  end
  
  alias :save_as_sqlite3 :save_as_sqlite
    
  def save_as_sql(path)
    open(path, 'w') do |io|      
      create_sql(io, @data)        
    end
  end
  
  def create_sql(io, data)
    # CREATE TABLE sets
    io.puts(sql_create_table(:sets, {
      :pk => :integer,
      :name => :varchar_255 },
      :pk => :pk))    
    # CREATE TABLE cards
    io.puts
    io.puts(sql_create_table(:cards, {
      :pk => :integer,
      :name => :varchar_255,
      :search_name => :varchar_255,
      :name_hash => :integer,
      :gatherer_id => :integer,
      :set_pk => :integer,
      :collector_number => :integer,
      :artist => :varchar_255,
      :rarity => :varchar_32,
      :mana_cost => :varchar_255,
      :type_line => :varchar_255,
      :oracle_text => :text,
      :power => :varchar_8,
      :toughness => :varchar_8,
      :loyalty => :varchar_8,
      :art_index => :integer,
      :version_count => :integer },
      :pk => :pk));
    # CREATE INDEXES
    io.puts(sql_create_index(:table => :cards, :column => :search_name))
    io.puts(sql_create_index(:table => :cards, :column => :name_hash))
    # INSERTs
    io.puts
    current_set_pk = 0
    current_card_pk = 0
    @data[:sets].each do |set|
      current_set_pk = current_set_pk + 1
      io.puts(sql_insert_row(:sets, :pk => current_set_pk, :name => set))
      io.puts
      @data[:cards][set].each do |card|
        current_card_pk = current_card_pk + 1
        io.puts(sql_insert_row(:cards, card.merge({
          :search_name => card[:name].to_searchable_name,
          :name_hash => card[:name].to_name_hash.to_s,
          :version_count => @data[:names][card[:name]],
          :pk => current_card_pk,
          :set_pk => current_set_pk
        })))
      end
      io.puts "VACUUM;"
      io.puts
    end
  end
    
end