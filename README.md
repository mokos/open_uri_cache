# OpenUriCache

キャッシュ機能を追加した open-uri。
指定ディレクトリ(デフォルトは ~/.open_uri_cache)以下にキャッシュファイルを作成し、すでにキャッシュファイルがある場合はそれを読み込みます。
キャッシュファイルのパスは、URLのhttp://(もしくはhttps://)以下の部分をそのまま利用します。

仕様
・トレーリングスラッシュを区別しません。(http://google.com と http://google.com/ を同一視)
・http と https を区別しません。
・ファイル名の長さがOSの制限を(256文字)を超えるとエラーになります。

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

  # cache_dir でキャッシュファイル保存ディレクトリを指定(デフォルトは~/.open_uri_cache)
  puts OpenUriCache.open('http://google.com', cache_dir: './', after: 10*60).read
```
