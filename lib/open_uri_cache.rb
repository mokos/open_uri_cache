require "open_uri_cache/version"

require 'fileutils'
require 'open-uri'
require 'cgi'

module OpenUriCache
  DEFAULT_CACHE_DIRECTORY = "#{ENV['HOME']}/.open-uri-cache"

  def self.make_file_name(uri, expiration)
    "#{CGI.escape uri} #{expiration}"
  end

  def self.search_files(uri)
    Dir.glob("#{CGI.escape uri} *").sort
  end

  def self.get_expiration(filename)
    time_str = filename.split(' ')[1..-1].join(' ')
    Time.parse(time_str)
  end

  def self.open(uri, cache_dir: DEFAULT_CACHE_DIRECTORY, expiration: )
    FileUtils.mkdir_p(cache_dir)
    Dir.chdir(cache_dir) {

      search_files(uri).each do |f|
        if get_expiration(f)>Time.now
          return Kernel.open(f)
        else
          File.delete f
        end
      end

      s = Kernel.open(uri)
      cache_filename = make_file_name(uri, expiration)
      File.open(cache_filename, 'wb+') {|f|
        f.write s.read
      }
      s.rewind
      return s
    }
  end
end

if $0==__FILE__
  puts OpenUriCache.open('http://google.com', expiration: Time.now + 10*60).read
  puts OpenUriCache.open('http://google.com', expiration: Time.now + 10*60).read
end
