# ユビキタス言語定義

## ドメイン用語

| 英語 | 日本語 | 定義 |
|---|---|---|
| ROS Bridge | ROSブリッジ | rosbridge_suiteが提供するJSON over WebSocketプロトコル。ポート9090 |
| Foxglove Bridge | Foxgloveブリッジ | foxglove_bridgeが提供するバイナリ/JSONハイブリッドプロトコル。ポート8765 |
| Topic | トピック | ROSのpub/subメッセージチャネル |
| Service | サービス | ROSのrequest/responseパターンの呼び出し |
| Publish | パブリッシュ | トピックにメッセージを送信すること |
| Subscribe | サブスクライブ | トピックのメッセージを受信登録すること |
| CDR | CDR | Common Data Representation。ROS2のネイティブバイナリシリアライズ形式 |
| Wire Encoding | ワイヤエンコーディング | WebSocket上でのメッセージシリアライズ形式（JSON / CDR） |
| Channel | チャネル | Foxglove Bridgeにおけるトピックの識別子（channelId） |
| Advertise | アドバタイズ | サーバーがトピック/サービスの存在をクライアントに通知すること |
| Turtlesim | タートルシム | ROS2付属のシミュレータ。画面上のカメをROSで操作できる |

## コード上の命名規則

| コード名 | 意味 |
|---|---|
| `MessageBridgeClient` | ROS Bridge / Foxglove Bridge の差異を吸収する共通インターフェース |
| `ConnectionMode` | 接続プロトコルの選択（`ROS_BRIDGE` / `FOXGLOVE_BRIDGE`） |
| `WebSocketConnectionState` | WebSocket接続状態（`Ready` / `Connecting` / `Connected` / `Disconnected`） |
| `KnobPosition` | ジョイスティックのつまみ位置（x / y / radian） |
| `UiState` | 各ViewModelが持つ画面の状態を表すsealed class |
