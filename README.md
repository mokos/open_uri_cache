# OpenUriCache

キャッシュ機能を追加した open-uri。
"#{CGI.escape(uri)} {expiration time}"にリネームしたキャッシュファイルを作ります。
リネーム後のファイル名が256文字を超える場合エラーになります。


## インストール

    $ gem install specific_install
    $ gem specific_install http://github.com/mokos/open_uri_cache.git


## 使い方
```ruby
  # expiration でキャッシュの有効期限を指定
  puts OpenUriCache.open('http://google.com', expiration: Time.now + 10*60).read
  
  # after で現在時刻から何秒後を有効期限にするか指定
  # open(url, expiration: Time.now+s) == open(url, after: s)
  puts OpenUriCache.open('http://google.com', after: 10*60).read
```
