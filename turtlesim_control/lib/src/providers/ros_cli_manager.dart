import 'dart:convert';
import 'dart:io';
import 'package:flutter/material.dart';
import '../models/turtle.dart';

/// 앱의 현재 상태를 나타내는 열거형
enum AppState { disconnected, connecting, connected, loadingData, dataLoaded }

/// ROS 클라이언트를 관리하는 클래스
///
/// WebSocket을 통해 ROS 서버와 통신하고 터틀봇 데이터를 관리합니다.
/// 연결 상태, 터틀 목록, ROS 명령을 관리하며, 앱 상태 변화를 알리기 위해 [ChangeNotifier]를 상속합니다.
class RosCliManager extends ChangeNotifier {
  WebSocket? _socket;
  bool _isConnected = false;
  String? _socketAddress;
  String connectionStatus = "Disconnect";
  String connectionMessage = "";
  final Map<String, Turtlesim> turtles = {}; // 네임스페이스별 Turtlesim 인스턴스 저장
  List<String> turtleList = []; // 터틀 네임스페이스 리스트

  AppState _state = AppState.disconnected; // 앱 상태 초기화
  AppState get state => _state; // 현재 앱 상태 반환

  bool get isConnected => _isConnected;
  String? get socketAddress => _socketAddress;

  /// 앱 상태를 업데이트하고 리스너에 알림
  void _updateState(AppState newState) {
    _state = newState;
    notifyListeners();
  }

  /// 서버와의 WebSocket 연결을 설정하는 함수
  ///
  /// [address]가 null이면 연결 실패 상태로 설정하고 종료합니다.
  /// 연결에 성공하면 터틀 데이터를 요청합니다.
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

  /// WebSocket 연결을 시도하는 내부 함수
  ///
  /// 성공 시 연결 상태를 갱신하고, 수신된 메시지를 처리하기 위해 리스너를 설정합니다.
  /// 실패 시 에러 메시지를 출력하고 상태를 업데이트합니다.
  Future<void> _connectRos() async {
    try {
      _socket = await WebSocket.connect(_socketAddress!);
      _isConnected = true;
      _updateStatus("Connect", "WebSocket Connected Success");
      _updateState(AppState.connected);

      _socket!.listen(
        (message) => _handleMessage(message),
        onError: (error) =>
            _handleError("Connect Fail", "Connect Fail: $error"),
        onDone: () => _handleError("Disconnect", "Disconnect"),
      );
    } catch (e) {
      _handleError("Connect Fail", "Connect Fail: $e");
    }
  }

  /// 수신된 메시지를 처리하는 함수
  ///
  /// 터틀 토픽 목록을 업데이트하고 터틀 인스턴스를 생성하여 관리합니다.
  void _handleMessage(String message) {
    // print("수신된 메시지: $message");
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

  /// 연결 상태와 메시지를 업데이트하고 알림
  void _updateStatus(String status, String message) {
    connectionStatus = status;
    connectionMessage = message;
    notifyListeners();
    // print(message);
  }

  /// 에러 발생 시 연결 상태와 메시지를 갱신하고 앱 상태를 업데이트
  void _handleError(String status, String message) {
    _isConnected = false;
    _updateStatus(status, message);
    _updateState(AppState.disconnected);
  }

  /// 터틀 데이터를 요청하는 함수
  ///
  /// ROS 서버에 현재 터틀 토픽 정보를 요청합니다.
  Future<void> getTurtleData() async {
    if (!_isConnected) return;

    final request = {"op": "call_service", "service": "/rosapi/topics"};
    _socket!.add(jsonEncode(request));
    // print("토픽 정보 요청 전송됨");
  }

  /// 새로운 터틀 인스턴스를 추가하는 함수
  ///
  /// [namespace]를 사용하여 터틀봇을 관리할 수 있도록 합니다.
  void addTurtle(String namespace) {
    turtles.putIfAbsent(namespace, () => Turtlesim(namespace));
  }

  /// 새 터틀봇을 추가 요청하는 함수
  ///
  /// /spawn 서비스를 호출하여 새로운 터틀을 생성한 후, 터틀 데이터를 요청합니다.
  Future<void> addNewTurtle() async {
    final spawnRequest = spawnService(5.0, 5.0, 0.0);
    _socket!.add(jsonEncode(spawnRequest));
    // print("새 거북이 추가 요청");

    await getTurtleData();
  }

  /// 특정 터틀봇을 제거 요청하는 함수
  ///
  /// [namespace]에 해당하는 터틀봇을 제거한 후 터틀 데이터를 요청합니다.
  Future<void> removeTurtle(String namespace) async {
    final killRequest = killService(namespace);
    _socket!.add(jsonEncode(killRequest));
    // print("거북이 제거 요청: $namespace");

    await getTurtleData();
  }

  /// WebSocket 연결을 종료하고 상태를 갱신
  void disconnect() {
    _socket?.close();
    _isConnected = false;
    _updateStatus("Disconnect", "Disconnect");
    _updateState(AppState.disconnected);
  }

  /// 터틀봇을 이동시키는 함수
  ///
  /// [namespace]에 해당하는 터틀봇의 [linearX] 및 [angularZ] 속도를 설정합니다.
  void moveTurtle(String namespace, double linearX, double angularZ) {
    if (!_isConnected || turtles[namespace] == null) return;

    final publishRequest = turtles[namespace]!.setVelocity(linearX, angularZ);
    _socket!.add(jsonEncode(publishRequest));
    // print("거북이 이동: $namespace - linearX: $linearX, angularZ: $angularZ");
  }

  /// 터틀봇을 멈추는 함수
  ///
  /// [namespace]에 해당하는 터틀봇을 정지시킵니다.
  void stopTurtle(String namespace) {
    moveTurtle(namespace, 0.0, 0.0);
    // print("거북이 멈춤: $namespace");
  }

  /// 터틀봇의 펜을 설정하는 함수
  ///
  /// [namespace]에 해당하는 터틀봇의 펜을 설정합니다.
  /// [off]는 펜 활성화 여부, [r], [g], [b]는 색상, [width]는 두께를 설정합니다.
  void setTurtlePen(
      String namespace, bool off, int r, int g, int b, int width) {
    if (!_isConnected || turtles[namespace] == null) return;

    final penRequest =
        turtles[namespace]!.callSetPen(off ? 1 : 0, r, g, b, width);

    _socket!.add(jsonEncode(penRequest));
    // print(
    //     "펜 설정: $namespace - off: ${off ? 1 : 0}, color: ($r, $g, $b), width: $width");
  }

  /// 터틀봇을 절대 위치로 이동시키는 함수
  ///
  /// [namespace]에 해당하는 터틀봇을 [x], [y] 좌표와 [theta] 각도로 이동시킵니다.
  void teleportTurtle(String namespace, double x, double y, double theta) {
    if (!_isConnected || turtles[namespace] == null) return;

    final teleportRequest =
        turtles[namespace]!.callTeleportAbsolute(x, y, theta);
    _socket!.add(jsonEncode(teleportRequest));
    // print("거북이 앱솔루트 이동: $namespace - x: $x, y: $y, theta: $theta");
  }

  /// 화면을 초기화하는 함수
  ///
  /// WebSocket을 통해 ROS에 클리어 요청을 전송합니다.
  void clearScreen() {
    if (!_isConnected) return;

    final clearRequest = clearService();
    _socket!.add(jsonEncode(clearRequest));

    // print("화면 클리어 요청");
  }
}
