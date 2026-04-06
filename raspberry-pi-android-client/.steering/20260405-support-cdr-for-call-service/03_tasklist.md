# タスクリスト: CDR形式サービスコールのサポート

## タスク

- [x] `CdrHelpers.kt` に CDR 書き込みヘルパーを追加
- [x] `TurtlesimServiceArgs.kt` に `encodeToCdr()` companion 関数を追加
- [x] `TurtlesimServiceResponse.kt` に `decodeFromCdr()` companion 関数を追加
- [x] `MessageBridgeClient.kt` の `callService` に `cdrEncoder` / `cdrResponseDecoder` パラメータを追加
- [x] `RosBridgeMessageBridgeAdapter.kt` のシグネチャを更新（パラメータ無視）
- [x] `FoxgloveMessageBridgeAdapter.kt` のシグネチャを更新・CDRパラメータを中継
- [x] `FoxgloveBridgeClient.kt` に CDR リクエストエンコード処理を追加
- [x] `FoxgloveBridgeClient.kt` に CDR レスポンスデコード処理を追加
- [x] `TurtlesimRepository.spawnTurtle()` に CDR エンコーダ/デコーダを渡す
