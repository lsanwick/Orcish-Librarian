# encoding: utf-8

class Source

  include Orcish
  
  def fetch_document(uri)
    if cache_enabled?
      local_path = File.join("cache", Digest::SHA2.hexdigest(uri))
      if !File.exists?(local_path)
        open(uri, 'r') do |in_file|
          open(local_path, 'wb') do |out_file|
            out_file.write(in_file.read)
          end
        end        
      end
      Hpricot(open(local_path))
    else
      Hpricot(open(uri))
    end
  end
  
end