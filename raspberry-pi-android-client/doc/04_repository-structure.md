# リポジトリ構造定義書

## ディレクトリ構成

```
raspberry-pi-android-client/
├── app/
│   └── src/
│       └── main/
│           ├── AndroidManifest.xml
│           └── java/com/shusuke/raspberry_pi_client/
│               ├── RaspberryPiApplication.kt        # Koin初期化
│               ├── MainActivity.kt                  # 単一Activity、ViewPager2ホスト
│               ├── MainPagerAdapter.kt              # ViewPager2用FragmentAdapter
│               ├── di/                              # DIモジュール
│               │   ├── DiModule.kt                  # モジュール一覧をまとめる
│               │   ├── InfrastructureModule.kt      # WebSocket/BridgeクライアントのDI
│               │   ├── RepositoryModule.kt          # RepositoryのDI
│               │   └── ViewModelModule.kt           # ViewModelのDI
│               ├── data/
│               │   ├── infrastructure/
│               │   │   ├── MessageBridgeClient.kt   # publish/subscribe/callServiceの共通インターフェース
│               │   │   ├── foxglove_bridge/         # Foxglove Bridge実装
│               │   │   │   ├── FoxgloveBridgeClient.kt
│               │   │   │   ├── FoxgloveMessageBridgeAdapter.kt
│               │   │   │   ├── binary/              # バイナリメッセージのエンコード/パース
│               │   │   │   │   ├── FoxgloveBinaryMessageEncoder.kt
│               │   │   │   │   └── FoxgloveBinaryMessageParser.kt
│               │   │   │   ├── common/              # JSON/エンコーディング共通処理
│               │   │   │   │   ├── FoxgloveJsonMessageParser.kt
│               │   │   │   │   ├── FoxgloveMessageOperation.kt
│               │   │   │   │   └── FoxgloveWireEncoding.kt
│               │   │   │   ├── server/              # サーバーからの受信メッセージ定義
│               │   │   │   │   ├── FoxgloveAdvertise.kt
│               │   │   │   │   ├── FoxgloveAdvertiseServices.kt
│               │   │   │   │   └── FoxgloveServerInfo.kt
│               │   │   │   └── topic/               # クライアント送信トピック関連
│               │   │   │       ├── FoxgloveClientAdvertise.kt
│               │   │   │       ├── FoxgloveSubscribe.kt
│               │   │   │       └── FoxgloveUnsubscribe.kt
│               │   │   ├── rosbridge/               # ROS Bridge実装
│               │   │   │   ├── RosBridgeClient.kt
│               │   │   │   ├── RosBridgeMessageBridgeAdapter.kt
│               │   │   │   ├── RosBridgeMessageOperation.kt
│               │   │   │   └── HandleRosBridgeMessageResponse.kt
│               │   │   ├── ros/
│               │   │   │   ├── cdr/                 # CDRエンコード/デコード
│               │   │   │   │   └── CdrHelpers.kt
│               │   │   │   ├── service/             # ROSサービス共通定義
│               │   │   │   │   ├── RosCallService.kt
│               │   │   │   │   ├── RosServiceError.kt
│               │   │   │   │   ├── RosServiceResponse.kt
│               │   │   │   │   ├── RosServiceResponseHeader.kt
│               │   │   │   │   └── EmptyService.kt
│               │   │   │   └── topic/               # ROSトピック共通定義
│               │   │   │       ├── RosTopicPublish.kt
│               │   │   │       ├── RosTopicPublishHeader.kt
│               │   │   │       ├── RosTopicSubscribe.kt
│               │   │   │       ├── RosTopicUnsubscribe.kt
│               │   │   │       ├── RosTopicError.kt
│               │   │   │       └── message/         # ROSメッセージ型
│               │   │   │           ├── StringMessage.kt
│               │   │   │           ├── Int8Message.kt
│               │   │   │           ├── TwistMessage.kt
│               │   │   │           └── Vector3Message.kt
│               │   │   └── websocket/               # WebSocket基盤
│               │   │       ├── WebSocketClient.kt
│               │   │       ├── WebSocketConnectionState.kt
│               │   │       └── WebSocketUrl.kt
│               │   └── repository/
│               │       ├── connection/
│               │       │   ├── RosConnectionRepository.kt
│               │       │   └── ConnectionMode.kt
│               │       ├── hello/
│               │       │   └── HelloTopicRepository.kt
│               │       └── turtlesim/
│               │           ├── TurtlesimRepository.kt
│               │           ├── TurtlesimServiceArgs.kt
│               │           └── TurtlesimServiceResponse.kt
│               ├── presentation/
│               │   ├── dialog/
│               │   │   └── ErrorDialogFragment.kt
│               │   └── screen/
│               │       ├── connection/
│               │       │   ├── ConnectionFragment.kt
│               │       │   ├── ConnectionViewModel.kt
│               │       │   └── compose/
│               │       │       └── ConnectionScreen.kt
│               │       ├── service/
│               │       │   ├── CallServiceFragment.kt
│               │       │   ├── CallServiceViewModel.kt
│               │       │   └── compose/
│               │       │       ├── CallServiceScreen.kt
│               │       │       ├── JoystickView.kt
│               │       │       └── KnobPosition.kt
│               │       └── topic/
│               │           ├── TopicMonitorFragment.kt
│               │           ├── TopicMonitorViewModel.kt
│               │           └── compose/
│               │               └── TopicMonitorScreen.kt
│               └── ui/
│                   └── theme/
│                       ├── Color.kt
│                       ├── Theme.kt
│                       └── Type.kt
└── ...
```

## ディレクトリの役割

| ディレクトリ | 役割 |
|---|---|
| `app/src/main/java/.../di/` | Koin DIモジュール定義。Infrastructure / Repository / ViewModel の3ファイルに分割 |
| `app/src/main/java/.../data/infrastructure/` | WebSocket・ROS Bridge・Foxglove Bridge の通信実装 |
| `app/src/main/java/.../data/infrastructure/ros/` | ROS共通のトピック・サービス・CDR定義（プロトコル非依存） |
| `app/src/main/java/.../data/repository/` | Infrastructureを呼び出してRepositoryパターンでドメインロジックを提供 |
| `app/src/main/java/.../presentation/` | Fragment + ViewModel + Compose UIの画面実装 |
| `app/src/main/java/.../ui/theme/` | Composeテーマ（Color / Theme / Typography） |

## ファイル配置ルール

- 新しいROSメッセージ型は `data/infrastructure/ros/topic/message/` に追加する
- 新しいROSサービス型は `data/infrastructure/ros/service/` に追加する
- 新しい画面は `presentation/screen/[画面名]/` ディレクトリを作成し、Fragment / ViewModel / compose/ の3点セットで追加する
- Composeの純粋なUIコンポーネントは `presentation/screen/[画面名]/compose/` 配下に置く
- DIモジュールはレイヤー単位で分割する（Infrastructure / Repository / ViewModel）
