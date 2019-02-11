require "open_uri_cache/version"

require 'fileutils'
require 'pathname'
require 'open-uri'
require 'cgi'
require 'json'

module OpenUriCache
  class Cache
    def initialize(uri, dir)
      @uri = uri
      @dir = Pathname.new(dir).join(uri.gsub(/^https?:\/\//, ''))
      @content_path = "#{@dir}/content"
      @info_path = "#{@dir}/info.json"

      delete_expired_cache
    end

    def delete_expired_cache
      return unless exist?
      
      info = JSON.parse File.open(@info_path, 'r') {|f| f.read }
      if Time.now > Time.parse(info['expiration'])
        delete
      end
    end

    def delete
      File.delete @content_path 
      File.delete @info_path
      Dir.rmdir @dir rescue nil
    end

    def exist?
      File.exist? @content_path and File.exist? @info_path
    end

    def save(content, info)
      FileUtils.mkdir_p(@dir)
      File.open(@content_path, 'wb+') {|f|
        f.write content
      }
      File.open(@info_path, 'w+') {|f|
        f.puts info.to_json
      }
    end

    def open(*args)
      File.open(@content_path, *args)
    end
  end

  DEFAULT_CACHE_DIRECTORY = "#{ENV['HOME']}/.open_uri_cache"

  def self.open(uri, *rest, cache_dir: DEFAULT_CACHE_DIRECTORY, expiration: nil, after: nil)
    if after
      expiration = Time.now + after
    end

    unless expiration
      expiration = Time.new(9999, 1, 1)
    end

    cache = Cache.new(uri, cache_dir)
    if cache.exist?
      return cache.open(*rest)
    else
      s = Kernel.open(uri, 'rb')
      begin
        cache.save(s.read, { expiration: expiration, meta: s.meta })
      rescue
        cache.delete
      end

      s.rewind
      return s
    end
  end
end

if $0==__FILE__
  puts OpenUriCache.open2('http://google.com', cache_dir: '.open_uri_cache', after: 1).class
  puts OpenUriCache.open2('http://google.com/', cache_dir: '.open_uri_cache', after: 1).class
  exit
end
