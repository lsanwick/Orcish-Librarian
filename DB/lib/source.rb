# encoding: utf-8

class Source

  include Orcish
  
  def fetch_file(uri)
    local_path = File.join("cache", Digest::SHA2.hexdigest(uri))
    if !File.exists?(local_path)
      open(uri, 'r') do |in_file|
        open(local_path, 'wb') do |out_file|
          out_file.write(in_file.read)
        end
      end        
    end
    local_path
  end

  def fetch_document(uri)
    Hpricot(open(fetch_file(uri)))
  end
  
end