sinatra環境構築メモ

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
bundle install --path vendor/bundle
```

optionでpathを指定している理由は、システムにインストールし過ぎるとgemがカオスになるらしく、bundlerの推奨環境としてvender/bundle以下に個別に管理するようにしたほうが良いらしい。(要参考)

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

MySQL起動

```Bash
mysql.server start
mysql -u root
```

退出は\q

データベース関連
```SQL
-> SHOW DATABASES; // DB一覧確認
-> CREATE DATABASE articles; // articlesというDBを作る
-> USE articles; // 使うDBを選択
-> SELECT DATABASE(); // 現在使っているDBを確認
```

起動後、import.sqlをmysqlで実行

```SQL
source /フルパス/import.sql
```
