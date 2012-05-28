# encoding: utf-8

require 'yaml'
require 'tempfile'
require 'sqlmaker'

class CardBox 
  
  include Orcish
  include SQLMaker
  
  def initialize()
    @data = { :sets => [ ], :meta => { }, :cards => { }, :names => { } }
  end
  
  def save(path, format = :json)
    self.send("save_as_#{format}", path)
  end
  
  def add(cards, set, meta)
    @data[:sets] << set
    @data[:meta][set] = meta
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
            io.write('|' + card[:search_name])
            io.write('|' + card[:name_hash])
            names[card[:search_name]] = true
            if !numbers[card[:name_hash]].nil?
              debug("WARNING: repeated search name hash: \"#{card[:search_name]}\" and \"#{numbers[card[:name_hash]]}\"")
            end  
            numbers[card[:name_hash]] = card[:search_name]
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
      :idx => :integer,
      :name => :varchar_255,
      :type => :integer,
      :format => :integer,
      :tcg => :varchar_255 },
      :pk => :pk))    
    # CREATE TABLE cards
    io.puts
    io.puts(sql_create_table(:cards, {
      :pk => :integer,
      :idx => :integer,
      :gatherer_id => :integer,
      :name_hash => :integer,
      :collector_number => :integer,
      :name => :varchar_255,
      :search_name => :varchar_255,
      :display_name => :varchar_255,
      :tcg => :varchar_255,
      :set_pk => :integer,
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
      
    ## CREATE INDEXES    
    # bookmarks
    io.puts(sql_create_index(:table => :cards, :column => :gatherer_id))    
    # random lookup
    io.puts(sql_create_index(:table => :cards, :column => :idx))    
    # other editions
    io.puts(sql_create_index(:table => :cards, :column => :name_hash))    
    # art variants
    io.puts(sql_create_index(:table => :cards, :column => [ :set_pk, :name_hash ]))        
    # other parts
    io.puts(sql_create_index(:table => :cards, :column => [ :set_pk, :collector_number ]))
    
    # INSERTs
    io.puts
    current_card_index = 0
    current_set_index = 0
    @data[:sets].each do |set_name|
      current_set_index = current_set_index + 1
      current_set_pk = set_name.to_name_hash.to_s
      meta = (@data[:meta][set_name] || { })
      io.puts(sql_insert_row(:sets, 
        :pk => current_set_pk, 
        :idx => current_set_index, 
        :name => set_name, 
        :tcg => (meta[:tcg] || ''), 
        :type => (meta[:type] || Orcish::Special),
        :format => (meta[:format] || Orcish::Legacy)
      ))
      io.puts
      @data[:cards][set_name].each do |card|
        current_card_index = current_card_index + 1
        io.puts(sql_insert_row(:cards, card.merge({
          :version_count => @data[:names][card[:name]],
          :idx => current_card_index,
          :pk => "#{set_name} #{card[:name]} #{card[:art_index]}".to_name_hash.to_s,
          :set_pk => current_set_pk
        })))
      end
      io.puts "VACUUM;"
      io.puts
    end
  end
    
end