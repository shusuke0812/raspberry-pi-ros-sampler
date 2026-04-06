# 要求定義: CDR形式サービスコールのサポート

## 概要
`TurtlesimRepository.spawnTurtle` が `FoxgloveBridgeClient` 経由でリクエストを送る場合、
CDR（Common Data Representation）形式のバイナリでペイロードを送信できるようにする。

## ユーザーストーリー
Foxglove Bridge が `/spawn` サービスの encoding として `cdr` を通知している場合に、
正しくCDRバイナリでリクエストを送信し、CDRバイナリのレスポンスを受信・デコードできること。

## 受け入れ条件
- Foxglove Bridge が `advertiseServices` で CDR エンコーディングを通知した場合、`/spawn` の呼び出しが CDR バイナリで送信される
- CDR レスポンスを受信した場合、`TurtlesimServiceResponse` としてデコードできる
- RosBridge 経由の場合は従来通り JSON で動作する（影響なし）

## 制約事項
- 既存の `MessageBridgeClient` インターフェースを通じて CDR 対応を実現する
- `TurtlesimRepository` は接続方式（RosBridge/Foxglove）を意識しない
