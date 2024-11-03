import 'dart:convert';
import 'dart:io';
import 'package:flutter/material.dart';
import '../models/turtle.dart';

enum AppState { disconnected, connecting, connected, loadingData, dataLoaded }

class RosCliManager extends ChangeNotifier {
  WebSocket? _socket;
  bool _isConnected = false;
  String? _socketAddress;
  String connectionStatus = "Disconnect";
  String connectionMessage = "";
  final Map<String, Turtlesim> turtles = {}; // 네임스페이스별 Turtlesim 인스턴스 저장
  List<String> turtleList = []; // 터틀 네임스페이스 리스트

  AppState _state = AppState.disconnected; // 앱 상태 초기화
  AppState get state => _state; // 상태 getter

  // 서버 연결 여부를 확인하는 getter
  bool get isConnected => _isConnected;

  // WebSocket 주소의 getter
  String? get socketAddress => _socketAddress;

  // 상태 업데이트 메서드
  void _updateState(AppState newState) {
    _state = newState;
    notifyListeners();
  }

  // WebSocket 주소 설정 및 연결 시도
  Future<void> connectServer(String? address) async {
    _socketAddress = address;
    if (_socketAddress == null) {
      _updateStatus("Connect Fail", "No Address Provided");
      _updateState(AppState.disconnected);
      return;
    }
    _updateState(AppState.connecting);
    await _connectRos();
    if (_isConnected) {
      _updateState(AppState.loadingData);
      await getTurtleData(); // 연결 성공 후 터틀 데이터 가져오기
    }
  }

  // WebSocket 연결 및 초기 설정
  Future<void> _connectRos() async {
    try {
      _socket = await WebSocket.connect(_socketAddress!);
      _isConnected = true;
      _updateStatus("Connect", "WebSocket 연결 성공");
      _updateState(AppState.connected);

      // WebSocket의 listen은 한 번만 설정
      _socket!.listen(
        (message) => _handleMessage(message),
        onError: (error) => _handleError("Connect Fail", "에러: $error"),
        onDone: () => _handleError("Disconnect", "연결 종료"),
      );
    } catch (e) {
      _handleError("Connect Fail", "연결 실패: $e");
    }
  }

  // ROS Bridge에서 수신된 메시지를 처리하는 메서드
  void _handleMessage(String message) {
    print("수신된 메시지: $message");
    final response = jsonDecode(message);

    if (response['op'] == 'service_response' &&
        response['service'] == "/rosapi/topics") {
      final List<dynamic> topics = response['values']['topics'];
      // List<dynamic>을 List<String>으로 변환
      final List<String> topicList = List<String>.from(topics);

      // 'turtlesim' 토픽을 가진 실제 존재하는 터틀 네임스페이스 필터링
      List<String> newTurtleList = topicList
          .where(
              (topic) => topic.startsWith('/turtle') && topic.contains('/pose'))
          .map((topic) => topic.split('/')[1])
          .toSet()
          .toList();

      // 새로운 리스트를 turtleList에 할당
      turtleList = newTurtleList;

      // 새로운 거북이 네임스페이스에 대한 인스턴스 추가
      for (var namespace in turtleList) {
        addTurtle(namespace);
      }

      _updateState(AppState.dataLoaded); // 데이터 로드 완료 상태 업데이트
    }
  }

  // 연결 상태 및 메시지 업데이트 함수
  void _updateStatus(String status, String message) {
    connectionStatus = status;
    connectionMessage = message;
    notifyListeners();
    print(message);
  }

  // 연결 종료 또는 에러 발생 시 처리
  void _handleError(String status, String message) {
    _isConnected = false;
    _updateStatus(status, message);
    _updateState(AppState.disconnected);
  }

  // ROS API를 통해 실제 존재하는 Turtle 네임스페이스 가져오기
  Future<void> getTurtleData() async {
    if (!_isConnected) return; // 연결이 되어있지 않으면 데이터 요청 중단

    // ROS API의 "/rosapi/topics"를 통해 네임스페이스 확인 요청
    final request = {"op": "call_service", "service": "/rosapi/topics"};
    _socket!.add(jsonEncode(request));
    print("토픽 정보 요청 전송됨");
  }

  // 특정 네임스페이스에 Turtlesim 인스턴스 추가
  void addTurtle(String namespace) {
    turtles.putIfAbsent(namespace, () => Turtlesim(namespace));
  }

  // 새 거북이 추가 (spawn 서비스 호출)
  Future<void> addNewTurtle() async {
    // Spawn 서비스 호출을 통해 새로운 거북이 생성
    final spawnRequest = {
      "op": "call_service",
      "service": "/spawn",
      "args": {"x": 5.0, "y": 5.0, "theta": 0.0}
    };

    // WebSocket을 통해 요청을 전송하고 이름이 자동 생성되도록 함
    _socket!.add(jsonEncode(spawnRequest));
    print("새 거북이 추가 요청");

    await getTurtleData();
  }

  // 특정 네임스페이스의 거북이 제거 (kill 서비스 호출)
  Future<void> removeTurtle(String namespace) async {
    final killRequest = {
      "op": "call_service",
      "service": "/kill",
      "args": {"name": namespace}
    };

    _socket!.add(jsonEncode(killRequest));
    print("거북이 제거 요청: $namespace");

    await getTurtleData();
  }

  // WebSocket 연결 종료 및 리소스 정리
  void disconnect() {
    _socket?.close();
    _isConnected = false;
    _updateStatus("Disconnect", "연결 종료");
    _updateState(AppState.disconnected);
  }

  // 특정 네임스페이스의 Turtle 위치 이동 (속도 설정)
  void moveTurtle(String namespace, double linearX, double angularZ) {
    if (!_isConnected || turtles[namespace] == null) return;

    final twistMessage = {
      "linear": {"x": linearX, "y": 0.0, "z": 0.0},
      "angular": {"x": 0.0, "y": 0.0, "z": angularZ}
    };

    final publishRequest = {
      "op": "publish",
      "topic": "/$namespace/cmd_vel",
      "msg": twistMessage
    };

    _socket!.add(jsonEncode(publishRequest));
    print("거북이 이동: $namespace - linearX: $linearX, angularZ: $angularZ");
  }

  // 특정 네임스페이스의 Turtle 멈추기 (속도를 0으로 설정)
  void stopTurtle(String namespace) {
    moveTurtle(namespace, 0.0, 0.0);
    print("거북이 멈춤: $namespace");
  }

  // 특정 네임스페이스의 Turtle 펜 설정
  void setTurtlePen(
      String namespace, bool off, int r, int g, int b, int width) {
    if (!_isConnected || turtles[namespace] == null) return;

    final penSettings = PenSettings(
      off: off ? 1 : 0, // bool을 int로 변환 (true -> 1, false -> 0)
      r: r,
      g: g,
      b: b,
      width: width,
    );

    _socket!.add(jsonEncode(turtles[namespace]!.callSetPen(penSettings)));
    print(
        "펜 설정: $namespace - off: ${penSettings.off}, color: ($r, $g, $b), width: $width");
  }
}
