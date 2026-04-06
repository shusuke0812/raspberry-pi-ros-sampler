# 設計: CDR形式サービスコールのサポート

## 実装アプローチ

### CDR エンコード方式

`/spawn` サービスリクエストの CDR バイナリ構造:

```
[0x00, 0x01, 0x00, 0x00]  // CDR-LE カプセル化ヘッダー (4 bytes)
[x: float32 LE]            // 4 bytes, offset=4
[y: float32 LE]            // 4 bytes, offset=8
[theta: float32 LE]        // 4 bytes, offset=12
[name_length: uint32 LE]   // 4 bytes, offset=16 (null 終端含む長さ)
[name_bytes]               // n bytes
[0x00]                     // null 終端
```

`/spawn` サービスレスポンスの CDR バイナリ構造:

```
[0x00, 0x01, 0x00, 0x00]  // CDR-LE カプセル化ヘッダー (4 bytes)
[name_length: uint32 LE]   // 4 bytes, offset=4
[name_bytes]               // n bytes
[0x00]                     // null 終端
```

### インターフェース変更

`MessageBridgeClient.callService()` に以下のオプションパラメータを追加:

- `cdrEncoder: ((A) -> ByteArray)? = null`: CDR エンコード関数（FoxgloveBridgeClient が CDR を要求した場合に使用）
- `cdrResponseDecoder: ((ByteArray) -> R)? = null`: CDR レスポンスデコード関数

`RosBridgeMessageBridgeAdapter` は両パラメータを無視する。
`FoxgloveMessageBridgeAdapter` は `FoxgloveBridgeClient.callService()` に中継する。

### 変更するコンポーネント

| ファイル | 変更内容 |
|---|---|
| `CdrHelpers.kt` | CDR 書き込みヘルパー追加 |
| `TurtlesimServiceArgs.kt` | `encodeToCdr()` companion 関数追加 |
| `TurtlesimServiceResponse.kt` | `decodeFromCdr()` companion 関数追加 |
| `MessageBridgeClient.kt` | `callService` にCDRパラメータ追加 |
| `RosBridgeMessageBridgeAdapter.kt` | シグネチャ更新（パラメータ無視） |
| `FoxgloveMessageBridgeAdapter.kt` | シグネチャ更新・CDRパラメータを中継 |
| `FoxgloveBridgeClient.kt` | CDRエンコード送信・CDRレスポンスデコード対応 |
| `TurtlesimRepository.kt` | `spawnTurtle` にCDRエンコーダ/デコーダを渡す |

### 影響範囲
- `RosBridgeClient` は変更不要
- `TurtlesimRepository.reset()` / `moveTurtle()` は変更不要
- CDR エンコーダ/デコーダを渡さなければ既存動作と同一
