# 技術仕様書

## テクノロジースタック

### アプリケーション

| カテゴリ | 技術 | バージョン |
|---|---|---|
| 言語 | Kotlin | - |
| UI フレームワーク | Jetpack Compose + Fragment | BOM管理 |
| アーキテクチャ | MVVM + Clean Architecture | - |
| DI | Koin | BOM管理 |
| 非同期処理 | Kotlin Coroutines / Flow | - |
| WebSocket | OkHttp | - |
| シリアライズ | Kotlinx Serialization (JSON) | - |
| ナビゲーション | ViewPager2 + Fragment | - |

### Android ビルド設定

| 項目 | 値 |
|---|---|
| compileSdk | 36 |
| minSdk | 28（Android 9.0） |
| targetSdk | 36 |
| 言語互換性 | Java 11 |

### プロダクトフレーバー

| フレーバー | applicationId | 用途 |
|---|---|---|
| prod | `com.shusuke.raspberry_pi_client` | 本番 |
| staging | `com.shusuke.raspberry_pi_client.stg` | 開発・検証 |

## ROS Bridge プロトコル（rosbridge_suite）

- **接続先ポート**: 9090
- **通信方式**: JSON over WebSocket（テキストフレーム）
- **メッセージ形式**: `{"op": "publish" | "subscribe" | "call_service", ...}`
- **サービスコール**: `op: "call_service"` → レスポンス `op: "service_response"`

## Foxglove Bridge プロトコル（foxglove.sdk.v1）

- **接続先ポート**: 8765
- **WebSocketサブプロトコル**: `foxglove.sdk.v1`
- **エンコーディング**: JSON（テキストフレーム） または CDR（バイナリフレーム）を動的ネゴシエーション
- **制御メッセージ（JSON）**: `serverInfo` / `advertise` / `advertiseServices` / `unadvertise` / `unadvertiseServices` / `serviceCallFailure`
- **データメッセージ（バイナリ）**: `MessageData`（トピック受信）/ `ServiceCallResponse`（サービスレスポンス）
- **クライアント送信（JSON）**: `clientAdvertise` / `subscribe` / `unsubscribe`
- **クライアント送信（バイナリ）**: `ClientMessageData`（トピックpublish）/ `ServiceCallRequest`（サービスコール）
- **参照仕様**: https://docs.foxglove.dev/sdk

## CDR（Common Data Representation）

Foxglove BridgeがCDRエンコーディングを要求した場合に使用する。

- **実装クラス**: `CdrHelpers`
- **対応型**: `std_msgs/msg/String`、`std_msgs/msg/Int8`
- **バイトオーダー**: Little Endian
- **ヘッダー**: 4バイト（`\x00\x01\x00\x00`）

## 依存ライブラリ

```
androidx.appcompat
google.material
androidx.viewpager2
androidx.core.ktx
androidx.lifecycle.runtime.ktx
androidx.activity.compose
androidx.compose.bom
androidx.compose.ui
androidx.compose.material3
koin.bom
koin.android
koin.compose
koin.compose.viewmodel
okhttp
kotlinx.serialization.json
androidx.navigation.fragment.ktx
androidx.navigation.ui.ktx
androidx.fragment.ktx
androidx.lifecycle.viewmodel.compose
androidx.lifecycle.runtime.compose
kotlinx.coroutines.android
```

## パフォーマンス要件

- ジョイスティック操作: 200ms周期でTwistメッセージを送信（`Dispatchers.Default` 上でループ）
- WebSocket受信: `Dispatchers.Default` 上の `CoroutineScope` で並行処理
- 排他制御: `Mutex` を使用してchannelId / subscriptionId / callId のマップを保護

## 技術的制約

- cleartext通信を許可（`android:usesCleartextTraffic="true"`）。ローカルネットワーク内利用を前提とする
- Foxglove BridgeとROS Bridgeは同一の `WebSocketClient` を共有するため、同時接続は一方のみ
- CDRデコードは `StringMessage` / `Int8Message` のみ対応。新規メッセージ型追加時は `CdrHelpers` の拡張が必要
