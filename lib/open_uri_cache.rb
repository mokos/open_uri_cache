require_relative 'open_uri_cache/version'

require 'fileutils'
require 'pathname'
require 'open-uri'
require 'cgi'
require 'json'

module OpenUriCache
  class SuccessCheckError < StandardError; end

  class CacheFile < File
    private_class_method :new

    def set_info(info)
      @info = info
    end

    def method_missing(name)
      n = name.to_s
      if @info.has_key? n
        @info[n]
      else
        super
      end
    end

    def self.open(file_path, info, *args)
      f = super(file_path, *args)
      f.set_info(info)
      f
    end
  end

  class Cache
    def initialize(uri, dir)
      @uri = uri
      @dir = Pathname.new(dir).join(uri.gsub(/^(https?|ftp):\/\//, ''))
      @content_path = "#{@dir}/content"
      @info_path = "#{@dir}/info.json"

      delete_expired_cache
    end

    def delete_expired_cache
      return unless exist?
      
      if Time.now > Time.parse(info_json['expiration'])
        delete
      end
    end

    def info_json
      JSON.parse File.open(@info_path, 'r') {|f| f.read }
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
      CacheFile.open(@content_path, info_json, *args)
    end
  end

  DEFAULT_CACHE_DIRECTORY = "#{ENV['HOME']}/.open_uri_cache"

  def self.open(uri, *rest, cache_dir: DEFAULT_CACHE_DIRECTORY, expiration: nil, after: nil, sleep_sec: 0, retry_num: 0, success_check: lambda {|f| true })
    if after
      expiration = Time.now + after
    end

    expiration ||= Time.new(9999, 1, 1)

    cache = Cache.new(uri, cache_dir)

    if cache.exist?
      return cache.open(*rest)
    end

    begin
      sleep sleep_sec
      f = Kernel.open(uri, 'rb')
      raise SuccessCheckError unless success_check.call f
    rescue
      retry_num -= 1
      retry if retry_num>=0
      raise
    end

    info = {
      expiration: expiration,
      base_uri: f.base_uri,
      charset: f.charset,
      content_encoding: f.content_encoding,
      content_type: f.content_type,
      last_modified: f.last_modified,
      meta: f.meta,
      status: f.status,
    }
    cache.save(f.read, info) rescue cache.delete

    f.rewind
    return f
  end
end
