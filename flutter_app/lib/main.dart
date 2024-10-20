import 'package:flutter/material.dart';
import 'package:web_socket_channel/web_socket_channel.dart';
import 'dart:convert';
import 'dart:async';

void main() => runApp(TurtleControllerApp());

class TurtleControllerApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      home: TurtleController(),
    );
  }
}

class TurtleController extends StatefulWidget {
  @override
  _TurtleControllerState createState() => _TurtleControllerState();
}

class _TurtleControllerState extends State<TurtleController> {
  final WebSocketChannel channel = WebSocketChannel.connect(
    Uri.parse('ws://localhost:9090'), // rosbridge 서버와 연결 (웹소켓)
  );

  String connectionStatus = "Disconnected";
  String movementLog = "";
  Timer? _timer;

  @override
  void initState() {
    super.initState();
    _setupWebSocket();
    _advertiseCmdVel(); // 토픽 광고 추가
  }

  @override
  void dispose() {
    _timer?.cancel();
    channel.sink.close();
    super.dispose();
  }

  void _setupWebSocket() {
    setState(() {
      connectionStatus = "Connecting...";
    });

    channel.stream.listen((data) {
      setState(() {
        connectionStatus = "Connected";
      });
      print("Connected to ROS WebSocket");
    }, onError: (error) {
      setState(() {
        connectionStatus = "Connection Error";
      });
      print("WebSocket Error: $error");
    }, onDone: () {
      setState(() {
        connectionStatus = "Disconnected";
      });
      print("WebSocket Disconnected");
    });

    _timer = Timer.periodic(Duration(seconds: 1), (timer) {
      sendKeepAliveMessage();
    });
  }

  // 토픽을 광고하는 함수 (웹소켓을 통해 토픽 타입을 미리 알려줌)
  void _advertiseCmdVel() {
    Map<String, dynamic> advertiseMsg = {
      "op": "advertise",
      "topic": "/turtle1/cmd_vel",
      "type": "geometry_msgs/Twist"
    };

    channel.sink.add(jsonEncode(advertiseMsg));
    print("Advertising /turtle1/cmd_vel");
  }

  void sendKeepAliveMessage() {
    Map<String, dynamic> message = {
      "op": "publish",
      "topic": "/turtle1/cmd_vel",
      "msg": {
        "linear": {"x": 0.0, "y": 0.0, "z": 0.0},
        "angular": {"x": 0.0, "y": 0.0, "z": 0.0}
      }
    };
    channel.sink.add(jsonEncode(message));
  }

  void moveTurtle(String direction) {
    Map<String, dynamic> message = {
      "op": "publish",
      "topic": "/turtle1/cmd_vel",
      "msg": {
        "linear": {"x": 0.0, "y": 0.0, "z": 0.0},
        "angular": {"x": 0.0, "y": 0.0, "z": 0.0}
      }
    };

    String action = "";

    switch (direction) {
      case 'up':
        message['msg']['linear']['x'] = 2.0;
        action = "Moving Forward";
        break;
      case 'down':
        message['msg']['linear']['x'] = -2.0;
        action = "Moving Backward";
        break;
      case 'left':
        message['msg']['angular']['z'] = 2.0;
        action = "Turning Left";
        break;
      case 'right':
        message['msg']['angular']['z'] = -2.0;
        action = "Turning Right";
        break;
    }

    channel.sink.add(jsonEncode(message));
    _logMovement(action);
  }

  void _logMovement(String action) {
    setState(() {
      movementLog = "Action: $action\n$movementLog";
    });
    print("Turtle Action: $action");
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Turtle Controller'),
      ),
      body: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: <Widget>[
          Text(
            "Connection Status: $connectionStatus",
            style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
          ),
          SizedBox(height: 20),
          ElevatedButton(
            onPressed: () => moveTurtle('up'),
            child: Text('Up'),
          ),
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: <Widget>[
              ElevatedButton(
                onPressed: () => moveTurtle('left'),
                child: Text('Left'),
              ),
              ElevatedButton(
                onPressed: () => moveTurtle('right'),
                child: Text('Right'),
              ),
            ],
          ),
          ElevatedButton(
            onPressed: () => moveTurtle('down'),
            child: Text('Down'),
          ),
          SizedBox(height: 20),
          Text(
            "Movement Log:",
            style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
          ),
          Expanded(
            child: SingleChildScrollView(
              child: Text(movementLog),
            ),
          ),
        ],
      ),
    );
  }
}
