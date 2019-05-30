# sinatra環境構築メモ

## まずGemfileを生成する

```bash
bundle init
```

## gemを追加する

gem 'sinatra'
gem 'sinatra-contrib'
gem 'slim'
gem 'activerecord'
gem 'sinatra-activerecord'
gem 'mysql2'

gemをインストールする

```bash
sudo bundle install --path vendor/bundle
```

optionでpathを指定している理由は、システムにインストールし過ぎるとgemがカオスになるらしく、bundlerの推奨環境としてvender/bundle以下に個別に管理するようにしたほうが良いらしい。(要参考)

bundle installでエラーが出た場合

```bash
sudo bundle install --path vendor/bundle
require: cannot load such file -- test/unit (LoadError)
```

path指定をしているため、vendor/bundleに入っているgemしか使えないので、あるgemで別のgemを使う場合などにそれも別途インストールしなければいけない

今回はrack-testでtest-unitも必要になる


## MySQL2を入れる場合

An error occurred while installing mysql2 (0.5.2), and Bundler cannot continue.
Make sure that `gem install mysql2 -v '0.5.2' --source 'https://rubygems.org/'` succeeds before bundling.

というエラーが出るのでとりあえず言われた通りに

```Bash
gem install mysql2 -v '0.5.2' --source 'https://rubygems.org/'
```

を実行する。

今度は
Don't know how to set rpath on your system, if MySQL libraries are not in path mysql2 may not load

ld: library not found for -lssl
clang: error: linker command failed with exit code 1
(エラーログっぽい場所を抜粋)
と出る

解決の参考サイト
https://qiita.com/akito19/items/e1dc54f907987e688cc0

このコードを実行

```Bash
bundle config --local build.mysql2 "--with-ldflags=-L/usr/local/opt/openssl/lib --with-cppflags=-I/usr/local/opt/openssl/include"
```

その後もう一度(今度はsudoで)bundle install

```Bash
sudo bundle install --path vendor/bundle
```

完了

## database構築

import.sqlにSQLを記述

```Bash
mysql.server start # MySQL起動
mysql -u root # ログイン
```

退出は\q

データベース関連
```SQL
-> SHOW DATABASES; // DB一覧確認
-> CREATE DATABASE articles; // articlesというDBを作る
-> USE articles; // 使うDBを選択
-> SELECT DATABASE(); // 現在使っているDBを確認
-> SHOW columns FROM table_name; //テーブル構造を確認
-> show tables; // テーブル一覧
-> ALTER TABLE tbl_name RENAME TO new_tbl_name　// テーブル名変更
-> ALTER TABLE posts AUTO_INCREMENT = 1; // オートインクリメントのリセット

```

起動後、import.sqlをmysqlで実行

```SQL
source /フルパス/import.sql;
```

## database.ymlを作る

```yml
development:
  adapter: mysql2
  database: articles
  host: localhost
  username: root
  password:
  encoding: utf8
```

app.rbにdatabase.ymlを読み込ませる

```ruby
# database.ymlを読み込んでくれえ
ActiveRecord::Base.configurations = YAML.load_file('database.yml')
# development設定でお願い
ActiveRecord::Base.establish_connection(:development)

# table名を単数形大文字にする
class Article < ActiveRecord::Base
end
```

app.rbやirbでrequireを実行する場合はbundle execが必要になる。

```bash
bundle exec ruby app.rb -p 8080
bundle exec irb
```

## 公式の参考リンク
gem redcarpet https://github.com/vmg/redcarpet
sinatra       http://sinatrarb.com/intro-ja.html
