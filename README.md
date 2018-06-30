# OpenUriCache

Ruby open-uri のキャッシュバージョン。
Make cache file named "#{CGI.escape(uri)} {expiration time}".


## インストール

    $ gem install specific_install
    $ gem install http://github.com/mokos/open_uri_cache.git


## 使い方

  puts OpenUriCache.open('http://google.com', expiration: Time.now + 10*60).read

