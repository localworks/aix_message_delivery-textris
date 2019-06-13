# AixMessageDelivery

[Textris](https://github.com/visualitypl/textris)のAIXMessage用のDeliveryです。

## インストール

Gemfileに追記

```ruby
gem 'aix_message_delivery'
```

bundle 実行

```shell
$ bundle install
```

TextrisのDeliveryをAixMessageDeliveryに設定（環境ごとの設定は各environment用の設定ファイルに追記）

```ruby
Rails.application.configure do
  config.textris_delivery_method = :aix_message
end
```

## 制限

- 70文字までの送信制限があります（短縮URL含む）。

## URL短縮機能

SMSメッセージ中のURLはAIXMessageの短縮URL機能を用いて自動で短縮されます。
URL短縮を適用させたくないURLには `no_short=true` パラメーターを付与してください。

例）

```
http://example.com/long/path # https://ans.la/UxNyC2 (21文字)のようなURLに短縮されます
http://example.com/?no_short=true # 短縮されません
http://example.com/?foo=bar&no_short=true # 短縮されません
```

## [注意] 非同期実行について

Textrisのdeliver_laterメソッドが使うのは `textris` キューになります。ワーカーを適切に設定してください。
