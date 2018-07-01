#!ruby -Ku
# coding: utf-8

require 'open_uri_cache'
require 'tmpdir'

RSpec.describe OpenUriCache do
  it "has a version number" do
    expect(OpenUriCache::VERSION).not_to be nil
  end

  it 'same result with cache' do
    Dir.mktmpdir {|tmpdir|
      tmpdir = './.open_uri_cache'
      url = 'https://twitter.com'
      doc = OpenUriCache.open(url, cache_dir: tmpdir, expiration: Time.now+10)
      doc2 = OpenUriCache.open(url, cache_dir: tmpdir, expiration: Time.now+10)

      expect(doc.read.to_s).to eq doc2.read.to_s
    }
  end

  it 'different result without chache' do
    Dir.mktmpdir {|tmpdir|
      url = 'https://twitter.com'
      doc = OpenUriCache.open(url, cache_dir: tmpdir, expiration: Time.now+1)
      # キャッシュ期間が1秒間
      # 2秒間スリープするので次回openはキャッシュが効かない
      sleep(2)

      doc2 = OpenUriCache.open(url, cache_dir: tmpdir, expiration: Time.now+10)

      expect(doc.read.to_s).not_to eq doc2.read.to_s
    }
  end
end
