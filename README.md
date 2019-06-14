# AixMessageDelivery

[Textris](https://github.com/visualitypl/textris)のAIXMessage用のDeliveryです。

## インストール

Gemfileに追記

```ruby
gem 'aix_message_delivery', github: 'localworks/aix_message_delivery-textris'
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

### 環境変数を設定

以下の環境変数を設定

```
AIX_MESSAGE_ACCESS_TOKEN=xxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxx
AIX_MESSAGE_CLIENT_ID=xxxx
AIX_MESSAGE_SMS_CODE=xxxxx
```

#### 各変数取得用URL

##### AIX_MESSAGE_ACCESS_TOKEN（アクセストークン）
https://qpd.aossms.com/aossmsqpd/admin/account/token.do

##### AIX_MESSAGE_CLIENT_ID（クライアントID）, AIX_MESSAGE_SMS_CODE（SMSコード）
https://qpd.aossms.com/aossmsqpd/admin/client/detail.do

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

## テスト

AixMessageTest を用いることで、70文字制限を超えるテキスト送信でエラーを起こすことができます。

```ruby
Rails.application.configure do
  config.textris_delivery_method = :aix_message_test
end
```


## [注意] 非同期実行について

Textrisのdeliver_laterメソッドが使うのは `textris` キューになります。ワーカーを適切に設定してください。
