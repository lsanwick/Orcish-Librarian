# encoding: utf-8

Dir.chdir(File.join(File.dirname(__FILE__), '..'))
$LOAD_PATH << 'lib'

begin
  require 'rubygems'
  require 'pstore'
  require 'hpricot'
  require 'json'
rescue LoadError
  $stderr.puts 'Missing one or more of these required libraries: ' 
  $stderr.puts ' - Ruby Gems '
  $stderr.puts ' - PStore '
  $stderr.puts ' - Hpricot '
  $stderr.puts ' - JSON '
  exit
end

require 'digest/sha2'
require 'open-uri'
require 'net/http'
require 'fileutils'

require 'orcish'
require 'fetchmanager'
require 'cardbox'
require 'rules'
require 'rules_writer'

FileUtils.mkdir_p("cache")
FileUtils.mkdir_p("data")