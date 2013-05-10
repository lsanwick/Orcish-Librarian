# encoding: utf-8

Dir.chdir(File.join(File.dirname(__FILE__), '..'))
$LOAD_PATH << 'lib'

require 'rubygems'

begin
  require 'hpricot'  
rescue LoadError
  $stderr.puts 'Missing one or more of these required libraries: '
  $stderr.puts ' - Hpricot '
  exit
end

require 'digest/sha2'
require 'open-uri'
require 'net/http'
require 'fileutils'
require 'yaml'

require 'orcish'
require 'mtgset'
require 'mtgcard'
require 'fetchmanager'
require 'cardbox'

FileUtils.mkdir_p("cache")
FileUtils.mkdir_p("data")