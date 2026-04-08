# プロダクト要求定義書

## プロダクトビジョンと目的

Raspberry Pi（ROS2）をiOS/Androidスマートフォンから遠隔操作するためのクライアントアプリ。
ROS Bridge / Foxglove Bridge を介してWebSocketで接続し、ROSトピックの購読・パブリッシュおよびROSサービスの呼び出しを行う。

## ターゲットユーザーと課題・ニーズ

省略

## 主要な機能一覧

1. **接続管理** - IPアドレスを指定してROS Bridge / Foxglove Bridgeに接続・切断
2. **サービスコール** - turtlesimサービス（Spawn / Move / Reset）を呼び出し
3. **トピックモニタ** - ROSトピック（/hello, /hello_signal）をリアルタイム購読・表示
4. **ジョイスティック操作** - タッチUIでTwistメッセージを周期送信してロボットを移動

## 成功の定義

省略

## ビジネス要件

- minSdk 28（Android 9.0以上）をサポートする
- prod / staging の2フレーバーをサポートする（staging は applicationId に `.stg` サフィックス）

## ユーザーストーリー

省略

## 受け入れ条件

- 接続画面でIPアドレスと接続モード（ROS Bridge / Foxglove Bridge）を選択し接続できる
- 接続状態（接続中 / 切断中）がUIに反映される
- サービス画面でSpawn後にジョイスティックが有効化される
- ジョイスティックのドラッグ量に応じた速度でTwistメッセージが送信される
- トピックモニタ画面でメッセージ受信時に表示が更新される

## 機能要件

### 接続機能
- IPアドレス入力欄を持つ
- 接続モード選択（ROS Bridge / Foxglove Bridge）
- 接続 / 切断ボタン
- WebSocket接続状態のリアルタイム表示

### サービスコール機能
- Spawnボタン（turtlesim/srv/Spawn）
- Resetボタン（turtlesim/srv/Empty）
- ジョイスティックUI（タッチ操作で knob 位置を取得し Twist メッセージ送信）
- 操作中のUIステート管理（Standby / Loading / Success / Failure）

### トピックモニタ機能
- /hello トピック（std_msgs/msg/String）購読
- /hello_signal トピック（std_msgs/msg/Int8）購読
- 受信メッセージのリアルタイム表示

## 非機能要件

- **パフォーマンス**: ジョイスティック操作は200ms周期でメッセージ送信
- **セキュリティ**: ローカルネットワーク内通信（cleartext通信を許容）
- **保守性**: MVVM + Clean Architecture でレイヤーを分離
- **拡張性**: MessageBridgeClient インターフェースで ROS Bridge / Foxglove Bridge を抽象化
