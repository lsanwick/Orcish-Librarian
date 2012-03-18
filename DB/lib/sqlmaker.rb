# encoding: utf-8

module SQLMaker
  
  def sql_insert_row(table, row)
    insert_sql = [ "INSERT INTO #{table} (" ]
    fields_sql = [ ]
    values_sql = [ ]
    row.each_pair do |k, v| 
      fields_sql << "'#{sql_escape(k)}'"
      values_sql << "'#{sql_escape(v)}'"
    end
    insert_sql << fields_sql.join(', ') << ") VALUES (" << values_sql.join(', ') << ");"    
    insert_sql.join(' ')
  end
  
  def sql_create_table(name, columns, params)
    table_sql = [ "DROP TABLE IF EXISTS #{name}; \nCREATE TABLE #{name} (" ]
    column_sql = [ ]
    columns.each_pair do |column_name, column_type|
      column_sql << sql_column(column_name, column_type, params[:pk] == column_name)
    end
    table_sql << column_sql.join(', ')
    table_sql << ");"
    table_sql.join(' ')
  end
  
  def sql_create_index(params)
    "CREATE INDEX #{params[:column]}_idx ON #{params[:table]} (#{params[:column]});"
  end
  
  def sql_column(name, type, primary_key = false)
    sql = [ name ]
    case type.to_s
      when 'integer'
        sql << "INTEGER"
      when 'text'
        sql << "TEXT"
      when /^varchar_\d+$/
        sql << "VARCHAR (#{type.to_s.gsub(/^[^0-9]+/, '')})"
    end
    sql << "PRIMARY KEY" if primary_key
    sql.join " "
  end
  
  def sql_escape(text)    
    text.to_s.gsub(/'/, "''").gsub("\n", '\n')
  end
  
end