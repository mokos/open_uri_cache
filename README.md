# OpenUriCache

キャッシュ機能を追加した open-uri。

指定ディレクトリ(デフォルトは ~/.open_uri_cache)以下にキャッシュファイルを作成し、すでにキャッシュファイルがある場合はそれを読み込みます。

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

## 仕様

### キャッシュのディレクトリ
キャッシュファイルのパスは、URLのhttp://(もしくはhttps://)以下の部分をそのまま利用します。
例えば http://a.com/b.html のキャッシュファイルは、 指定ディレクトリ/a.com/b.html 以下に、
  content    (b.htmlの中身)
  info.json  (キャッシュ期限やダウンロード時のURIやメタ情報など)
の２つのファイルを作成します。

### キャッシュを削除するタイミング
キャッシュがすでに作成されているURLを再度開こうとした際に、現在時刻がキャッシュ期限を過ぎていた場合削除します。
それ以外に自動で削除するタイミングはないので、ディスク容量が気になる場合は、手動で削除、もしくは tmp ディレクトリを使う等してください。

### その他細かい仕様
・トレーリングスラッシュを区別しません。(http://google.com と http://google.com/ を同一視)
・http と https を区別しません。
・ファイル名の長さがOSの制限を(256文字)を超えるとエラーになります。

