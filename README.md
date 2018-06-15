# 3D LEDコンテンツ切替アプリケーション

## 背景

3D LEDのコンテンツは複数あり、切替機が必要だった。  
エンジニアがターミナルをいじるのではなく、子供でも簡単にできるようにしたかった。

## 環境構築

以下をインストール
* ruby 2.5.0
* bundler

bunderでまとめてgemをインストールする。

`$ bundle install`

## 実行

`bundle exec rackup`

ポート番号は4567（sinatraのデフォルト）

## コンテンツ編集

app.rbファイルを開いて、$contentsを編集してください。
