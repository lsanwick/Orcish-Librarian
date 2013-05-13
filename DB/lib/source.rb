# encoding: utf-8

class Source

  include Orcish
  
  def fetch_file(uri)
    cache = File.join(File.dirname(__FILE__), '../cache')
    local_path = File.join(cache, Digest::SHA2.hexdigest(uri))
    if !File.exists?(local_path)
      open(uri, 'r') do |in_file|
        FileUtils.mkdir_p(cache)
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