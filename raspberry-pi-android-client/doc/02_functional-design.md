# 機能設計書

## アーキテクチャ概要

MVVM + Clean Architecture を採用し、Presentation / Data（Repository）/ Data（Infrastructure）の3層で構成する。

```
┌─────────────────────────────────────────────────┐
│  Presentation Layer                             │
│  Fragment + ViewModel + Jetpack Compose UI      │
└────────────────────┬────────────────────────────┘
                     │ 呼び出し
┌────────────────────▼────────────────────────────┐
│  Data Layer - Repository                        │
│  RosConnectionRepository                        │
│  HelloTopicRepository                           │
│  TurtlesimRepository                            │
└────────────────────┬────────────────────────────┘
                     │ 呼び出し
┌────────────────────▼────────────────────────────┐
│  Data Layer - Infrastructure                    │
│  MessageBridgeClient (interface)                │
│  ├── RosBridgeMessageBridgeAdapter              │
│  │   └── RosBridgeClient (port 9090)            │
│  └── FoxgloveMessageBridgeAdapter               │
│      └── FoxgloveBridgeClient (port 8765)       │
│                                                 │
│  WebSocketClient (OkHttp)                       │
└─────────────────────────────────────────────────┘
```

## システム構成図

```
┌──────────────────────┐        WebSocket        ┌────────────────────────┐
│   Android App        │ ──────────────────────► │  Raspberry Pi (ROS2)   │
│                      │  port 9090 (ROS Bridge) │                        │
│  FoxgloveBridgeClient│  port 8765 (Foxglove)   │  rosbridge_server      │
│  RosBridgeClient     │ ◄────────────────────── │  foxglove_bridge       │
└──────────────────────┘                         └────────────────────────┘
```

## 画面構成・画面遷移

アプリは単一 Activity（MainActivity）＋ ViewPager2 で3つの Fragment をタブ切り替えで表示する。

```
MainActivity
└── ViewPager2
    ├── Tab 0: ConnectionFragment   (接続管理)
    ├── Tab 1: CallServiceFragment  (サービスコール / ジョイスティック)
    └── Tab 2: TopicMonitorFragment (トピックモニタ)
```

画面遷移は行わず、タブ間を横スワイプまたはタップで切り替える。

## コンポーネント設計

### Presentation Layer

| クラス | 役割 |
|---|---|
| `ConnectionFragment` | 接続管理画面のFragment。ComposeViewでConnectionScreenを表示 |
| `ConnectionViewModel` | 接続・切断・接続状態の管理 |
| `ConnectionScreen` | Compose UI。IPアドレス入力・接続モード選択・接続ボタン |
| `CallServiceFragment` | サービスコール画面のFragment |
| `CallServiceViewModel` | Spawn / Move / Reset の呼び出し・UIステート管理 |
| `CallServiceScreen` | Compose UI。Spawn/Resetボタン・ジョイスティック |
| `JoystickView` | タッチ操作でKnobPosition を返すカスタムComposable |
| `TopicMonitorFragment` | トピックモニタ画面のFragment |
| `TopicMonitorViewModel` | /hello・/hello_signal トピック購読・表示 |
| `TopicMonitorScreen` | Compose UI。受信メッセージのリアルタイム表示 |
| `ErrorDialogFragment` | エラー表示用ダイアログ |

### Data Layer - Repository

| クラス | 役割 |
|---|---|
| `RosConnectionRepository` | 接続モードに応じてRosBridge/FoxgloveBridgeを切り替えて接続管理 |
| `HelloTopicRepository` | /hello・/hello_signal トピックの購読・購読解除 |
| `TurtlesimRepository` | turtlesimサービス（Spawn/Move/Reset）の呼び出し |

### Data Layer - Infrastructure

| クラス | 役割 |
|---|---|
| `MessageBridgeClient` | publish / subscribe / callService の共通インターフェース |
| `RosBridgeMessageBridgeAdapter` | RosBridgeClientをMessageBridgeClientに適合させるアダプタ |
| `FoxgloveMessageBridgeAdapter` | FoxgloveBridgeClientをMessageBridgeClientに適合させるアダプタ |
| `RosBridgeClient` | rosbridge_suite プロトコル（JSON over WebSocket、ポート9090）実装 |
| `FoxgloveBridgeClient` | Foxglove WebSocket SDK v1プロトコル（ポート8765）実装 |
| `WebSocketClient` | OkHttpベースのWebSocket接続・送受信 |

## データモデル定義

### ROSトピック

| データクラス | 対応ROSメッセージ型 |
|---|---|
| `StringMessage` | `std_msgs/msg/String` |
| `Int8Message` | `std_msgs/msg/Int8` |
| `TwistMessage` | `geometry_msgs/msg/Twist` |
| `Vector3Message` | `geometry_msgs/msg/Vector3` |

### ROSサービス

| データクラス | 対応ROSサービス型 |
|---|---|
| `TurtlesimServiceArgs` | `turtlesim/srv/Spawn` リクエスト引数 |
| `TurtlesimServiceResponse` | `turtlesim/srv/Spawn` レスポンス |
| `EmptyService` | `std_srvs/srv/Empty` |

### 接続モード

```kotlin
enum class ConnectionMode {
    ROS_BRIDGE,    // port 9090
    FOXGLOVE_BRIDGE // port 8765
}
```

### UIステート（CallServiceViewModel）

```
UiState
├── Standby  - 初期状態。ジョイスティック無効
├── Loading  - サービス呼び出し中
├── Success  - Spawn成功。ジョイスティック有効
└── Failure  - エラー発生
```

## ワイヤエンコーディング

Foxglove Bridge はトピック・サービスごとにエンコーディングを動的にネゴシエーションする。

```
FoxgloveWireEncoding
├── Json  - JSON over WebSocket（テキストフレーム）
├── Cdr   - CDR（バイナリフレーム、ROS2ネイティブシリアライズ）
└── Unsupported(raw) - 未対応エンコーディング
```

サービスコール時にサーバーが `cdr` を要求した場合は `cdrEncoder` / `cdrResponseDecoder` が必須。
