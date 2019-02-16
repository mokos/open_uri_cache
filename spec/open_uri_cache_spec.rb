#!ruby -Ku
# coding: utf-8

require 'open_uri_cache'
require 'tmpdir'
require 'kconv'

RSpec.describe OpenUriCache do
  it "has a version number" do
    expect(OpenUriCache::VERSION).not_to be nil
  end

  it 'same result with cache' do
    Dir.mktmpdir {|tmpdir|
      url = 'https://twitter.com'
      doc = OpenUriCache.open(url, cache_dir: tmpdir, after: 10)
      doc2 = OpenUriCache.open(url, cache_dir: tmpdir, after: 10)

      expect(doc.read).to eq doc2.read
    }
  end

  it 'different result without chache' do
    Dir.mktmpdir {|tmpdir|
      url = 'https://twitter.com'
      doc = OpenUriCache.open(url, cache_dir: tmpdir, after: 1)
      # キャッシュ期間が1秒間
      # 3秒間スリープするので次回openはキャッシュが効かない
      sleep(3)

      doc2 = OpenUriCache.open(url, cache_dir: tmpdir, after: 10)

      expect(doc.read).not_to eq doc2.read
    }
  end

  it 'no expiration' do
    Dir.mktmpdir {|tmpdir|
      url = 'https://twitter.com'
      OpenUriCache.open(url, cache_dir: tmpdir)
      OpenUriCache.open(url, cache_dir: tmpdir)
    }
  end

  it 'return Tmpfile object if no cache, CacheFile if cache' do
    Dir.mktmpdir {|tmpdir|
      url = 'https://twitter.com'
      doc = OpenUriCache.open(url, cache_dir: tmpdir)
      expect(doc.class).to eq Tempfile

      doc = OpenUriCache.open(url, cache_dir: tmpdir)
      expect(doc.class).to eq OpenUriCache::CacheFile
    }
  end

  it 'can access open-uri like method' do
    Dir.mktmpdir {|tmpdir|
      url = 'https://twitter.com'
      OpenUriCache.open(url, cache_dir: tmpdir)
      doc = OpenUriCache.open(url, cache_dir: tmpdir)
      puts doc.class
      puts doc.base_uri
      puts doc.expiration
      puts doc.charset
      puts doc.content_encoding
      puts doc.content_type
      puts doc.last_modified
      puts doc.status
    }
  end

end
