# AGENTS.md

This file provides guidance to Claude Code (claude.ai/code) when working with code in this repository.

## Build Commands

```bash
# Debug build
./gradlew assembleProdDebug

# Release build
./gradlew assembleRelease

# Run unit tests
./gradlew testProdDebugUnitTest

# Run a specific test class
./gradlew testProdDebugUnitTest --tests com.shusuke.raspberry_pi_client.<TestClassName>

# Run a specific test method
./gradlew testProdDebugUnitTest --tests com.shusuke.raspberry_pi_client.<TestClassName>.<methodName>

# Lint check
./gradlew lintProdDebug

# Install on device
./gradlew installProdDebug
```

## Architecture Overview

**Product flavors:** `prod` / `staging` (switched via build variant)

### Layer Structure (Clean Architecture)

```
UI Layer          : Compose screens (presentation/ui/)
ViewModel Layer   : UI state management with StateFlow (presentation/viewmodel/)
Repository Layer  : Business logic abstraction (data/repository/)
Infrastructure    : Protocol implementations (data/infrastructure/)
```

### Screen Structure

`MainActivity` → 3 screens via `ViewPager2` tab switching:
1. **ConnectionScreen** — Manages connection to ROS Bridge / Foxglove Bridge
2. **TopicMonitorScreen** — ROS topic Pub/Sub
3. **CallServiceScreen** — ROS service calls (joystick UI)

### Dual Protocol Support in Infrastructure Layer

Two protocols abstracted via the `MessageBridgeClient` interface:

| Protocol | Class | Port | Format |
|---|---|---|---|
| ROS Bridge | `RosBridgeClient` | 9090 | JSON over WebSocket |
| Foxglove Bridge | `FoxgloveBridgeClient` | 8765 | Binary (CDR) / JSON |

The user selects the target connection in the UI, and `RosConnectionRepository` controls which client to use.

### DI (Koin)

Initialized via `RaspberryPiApplication.onCreate()` → `DiModule.init()`. Module structure:
- `InfrastructureModule`: `WebSocketClient`, `RosBridgeClient`, `FoxgloveBridgeClient`
- `RepositoryModule`: Each Repository
- `ViewModelModule`: Each ViewModel

### Communication Flow

WebSocket ping interval is 20 seconds. Messages flow asynchronously via `Flow`, and ViewModels update the UI using `collectAsState`.

### Package Structure

```
com.shusuke.raspberry_pi_client
├── RaspberryPiApplication.kt    # Koin initialization
├── MainActivity.kt              # ViewPager2 + BottomNavigation
├── data/
│   ├── infrastructure/
│   │   ├── websocket/           # WebSocketClient (OkHttp)
│   │   ├── ros/                 # ROS Bridge protocol implementation
│   │   └── foxglove/            # Foxglove Bridge protocol implementation
│   └── repository/              # RosConnectionRepository etc.
├── presentation/
│   ├── ui/                      # Compose screens & Fragments
│   └── viewmodel/               # ViewModel (StateFlow)
└── di/                          # Koin modules
```

## Key Technologies

- **Kotlin 2.0.21**, Target SDK 36, Min SDK 28
- **Jetpack Compose** (Material Design 3) — UI framework
- **Koin 4.1.0** — DI
- **OkHttp 4.12.0** — WebSocket
- **Kotlinx Serialization 1.7.3** — JSON serialization
- **Coroutines + Flow** — Async processing & state management
- **CDR (Common Data Representation)** — Binary message serialization for Foxglove
