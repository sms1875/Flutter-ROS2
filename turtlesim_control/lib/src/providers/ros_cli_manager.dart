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

  bool get isConnected => _isConnected;
  String? get socketAddress => _socketAddress;

  void _updateState(AppState newState) {
    _state = newState;
    notifyListeners();
  }

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

  Future<void> _connectRos() async {
    try {
      _socket = await WebSocket.connect(_socketAddress!);
      _isConnected = true;
      _updateStatus("Connect", "WebSocket 연결 성공");
      _updateState(AppState.connected);

      _socket!.listen(
        (message) => _handleMessage(message),
        onError: (error) => _handleError("Connect Fail", "에러: $error"),
        onDone: () => _handleError("Disconnect", "연결 종료"),
      );
    } catch (e) {
      _handleError("Connect Fail", "연결 실패: $e");
    }
  }

  void _handleMessage(String message) {
    print("수신된 메시지: $message");
    final response = jsonDecode(message);

    if (response['op'] == 'service_response' &&
        response['service'] == "/rosapi/topics") {
      final List<dynamic> topics = response['values']['topics'];
      final List<String> topicList = List<String>.from(topics);

      List<String> newTurtleList = topicList
          .where(
              (topic) => topic.startsWith('/turtle') && topic.contains('/pose'))
          .map((topic) => topic.split('/')[1])
          .toSet()
          .toList();

      turtleList = newTurtleList;

      for (var namespace in turtleList) {
        addTurtle(namespace);
      }

      _updateState(AppState.dataLoaded);
    }
  }

  void _updateStatus(String status, String message) {
    connectionStatus = status;
    connectionMessage = message;
    notifyListeners();
    print(message);
  }

  void _handleError(String status, String message) {
    _isConnected = false;
    _updateStatus(status, message);
    _updateState(AppState.disconnected);
  }

  Future<void> getTurtleData() async {
    if (!_isConnected) return;

    final request = {"op": "call_service", "service": "/rosapi/topics"};
    _socket!.add(jsonEncode(request));
    print("토픽 정보 요청 전송됨");
  }

  void addTurtle(String namespace) {
    turtles.putIfAbsent(namespace, () => Turtlesim(namespace));
  }

  Future<void> addNewTurtle() async {
    final spawnRequest = spawnService(5.0, 5.0, 0.0);
    _socket!.add(jsonEncode(spawnRequest));
    print("새 거북이 추가 요청");

    await getTurtleData();
  }

  Future<void> removeTurtle(String namespace) async {
    final killRequest = killService(namespace);
    _socket!.add(jsonEncode(killRequest));
    print("거북이 제거 요청: $namespace");

    await getTurtleData();
  }

  void disconnect() {
    _socket?.close();
    _isConnected = false;
    _updateStatus("Disconnect", "연결 종료");
    _updateState(AppState.disconnected);
  }

  void moveTurtle(String namespace, double linearX, double angularZ) {
    if (!_isConnected || turtles[namespace] == null) return;

    final publishRequest = turtles[namespace]!.setVelocity(linearX, angularZ);
    _socket!.add(jsonEncode(publishRequest));
    print("거북이 이동: $namespace - linearX: $linearX, angularZ: $angularZ");
  }

  void stopTurtle(String namespace) {
    moveTurtle(namespace, 0.0, 0.0);
    print("거북이 멈춤: $namespace");
  }

  void setTurtlePen(
      String namespace, bool off, int r, int g, int b, int width) {
    if (!_isConnected || turtles[namespace] == null) return;

    final penRequest =
        turtles[namespace]!.callSetPen(off ? 1 : 0, r, g, b, width);

    _socket!.add(jsonEncode(penRequest));
    print(
        "펜 설정: $namespace - off: ${off ? 1 : 0}, color: ($r, $g, $b), width: $width");
  }

  void teleportTurtle(String namespace, double x, double y, double theta) {
    if (!_isConnected || turtles[namespace] == null) return;

    final teleportRequest =
        turtles[namespace]!.callTeleportAbsolute(x, y, theta);
    _socket!.add(jsonEncode(teleportRequest));
    print("거북이 앱솔루트 이동: $namespace - x: $x, y: $y, theta: $theta");
  }

  void clearScreen() {
    if (!_isConnected) return;

    final clearRequest = clearService();
    _socket!.add(jsonEncode(clearRequest));

    print("화면 클리어 요청");
  }
}
