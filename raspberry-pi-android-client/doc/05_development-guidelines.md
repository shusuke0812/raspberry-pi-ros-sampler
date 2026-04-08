# 開発ガイドライン

## コーディング規約

- Kotlin公式コーディング規約に従う
- クラス・関数・プロパティにはKDocコメントを日本語で記述する
- コメントは日本語で記述する

## 命名規則

| 対象 | 規則 | 例 |
|---|---|---|
| クラス・インターフェース | UpperCamelCase | `FoxgloveBridgeClient` |
| 関数・変数 | lowerCamelCase | `callService`, `ipAddress` |
| 定数・enum値 | UPPER_SNAKE_CASE | `ROS_BRIDGE`, `FOXGLOVE_BRIDGE` |
| パッケージ | 小文字スネークケース | `foxglove_bridge`, `ros` |
| ROSトピック名 | スラッシュ始まりのスネークケース | `/turtle2/cmd_vel` |
| ROSサービス名 | スラッシュ始まりのスネークケース | `/spawn`, `/reset` |

## レイヤー間の依存ルール

- Presentation → Repository → Infrastructure の単方向依存を守る
- Presentation は Infrastructure を直接参照しない
- Infrastructure 内の ROS共通定義（`ros/`）はプロトコル実装（`rosbridge/`・`foxglove_bridge/`）から参照してよい

## UIステート管理

- ViewModelのUIステートは `StateFlow` で公開する
- 内部の `MutableStateFlow` はプライベートにし、公開側は `asStateFlow()` でラップする
- 複数Flowの組み合わせには `combine` + `stateIn` を使用する

## 非同期処理

- ViewModelからのRepository呼び出しは `viewModelScope.launch` を使用する
- WebSocket接続・切断は `Dispatchers.IO` で実行する（`NetworkOnMainThreadException` 回避）
- Infrastructure内の非同期処理は `CoroutineScope(SupervisorJob() + Dispatchers.Default)` を使用する
- コールバック形式のAPIを `suspend fun` に変換する場合は `suspendCancellableCoroutine` を使用する

## DIルール

- DI登録はレイヤー単位でモジュールを分割する（`InfrastructureModule` / `RepositoryModule` / `ViewModelModule`）
- シングルトンは `single { }` または `singleOf(::ClassName)` で登録する
- コンストラクタにデフォルト引数がある場合は `singleOf` を使わず `single { ClassName() }` で登録する

## Git規約

### ブランチ命名

| 種別 | パターン | 例 |
|---|---|---|
| 機能追加 | `feature/[概要]` | `feature/support-cdr-for-call-service` |
| リファクタリング | `refactor/[概要]` | `refactor/foxglove-bridge-client` |
| バグ修正 | `fix/[概要]` | `fix/websocket-reconnect` |

### コミットメッセージ

- 日本語で記述する
- 何をしたかを端的に記述する（例: `FoxgloveBridgeClient のサービスコールで CDR エンコードをサポート`）

### PRルール

- PRタイトルは日本語で記述する
- マージ先は `main` ブランチ
