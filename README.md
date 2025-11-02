# raspberry-pi-mouse-client

## Raspberry Pi

### Environment
- OS: Ubuntu 24.04.3 LTS(noble)
- ROS: jazzy
- ROS Bridge Server: 2.3.0(rosbridge_suite)

### RosBridger Server

#### 起動

```bash
$ ros2 launch rosbridge_server rosbridge_websocket_launch.xml
```

#### Pub/Sub

Publish
```bash
$ ros2 topic pub /hello std_msgs/String "data: 'Hello world'" -r 1 # -r：Hz, 1秒間に送信する回数を指定
```