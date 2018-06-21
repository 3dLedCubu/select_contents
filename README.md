# 3D LEDコンテンツ切替アプリケーション

## 背景

3D LEDのコンテンツは複数あるが、3D LEDは１台しかないため切替作業が必要である。  
従来はエンジニアがコマンドを叩いて切り替えていたため、基本的に来場者に１つのコンテンツしか見せることができなかった。  
もっとユーザーフレンドリーな切替方法を検討し、来場者にいろんなコンテンツを楽しんでもらえるようにしたいと考えた。

## コンテンツ切替機の構成

![コンテンツ切替機構成](./spec/spec.png)

## 環境構築

### Ruby2.5.0インストール

* windowsの場合  
[rubyinstaller.org](https://rubyinstaller.org/downloads/) からインストーラをダウンロードする。
* macの場合  
rbenvでruby2.5をインストールする。

### bunderインストール

`$ gem install bundler`

プロキシ設定が必要な場合は、設定してからbundlerをインストールすること。  
（環境変数 http_proxy を設定する）


https://rubygems.org/ にアクセスできないときは、ダウンロード元を http://rubygems.org/ へ変更する。

### gemインストール

bundlerを使ってgemをまとめてインストールする。

`$ bundle install`

## 実行

`bundle exec rackup`

ポート番号は4567（sinatraのデフォルト）

## コンテンツ編集

app.rbファイルを開いて、$contentsを編集してください。
