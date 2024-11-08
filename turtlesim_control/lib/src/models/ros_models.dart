/// 특정 인자를 사용하여 호출할 수 있는 ROS 서비스 클래스
class Service {
  /// 호출할 ROS 서비스의 이름
  final String name;

  /// [Service] 인스턴스를 생성하는 생성자, 필수 매개변수로 [name]이 필요함
  ///
  /// [name]은 호출할 ROS 서비스의 식별자 역할을 합니다.
  Service({required this.name});

  /// ROS 서비스 호출 작업과 그 인자를 포함하는 맵을 생성합니다.
  ///
  /// [args]는 서비스 호출과 함께 보낼 인자들을 포함하는 맵입니다.
  /// ROS 통신을 위한 작업, 서비스 이름, 인자를 포함하는 [Map]을 반환합니다.
  Map<String, dynamic> callService(Map<String, dynamic> args) {
    return {
      "op": "call_service",
      "service": name,
      "args": args,
    };
  }
}

/// 특정 메시지 타입으로 메시지를 발행할 수 있는 ROS 토픽 클래스
class Topic {
  /// 발행할 ROS 토픽의 이름
  final String name;

  /// ROS 토픽이 예상하는 메시지 타입
  final String messageType;

  /// [Topic] 인스턴스를 생성하는 생성자, 필수 매개변수로 [name]과 [messageType]이 필요함
  ///
  /// [name]은 발행할 ROS 토픽의 식별자 역할을 합니다.
  /// [messageType]은 이 토픽이 처리할 메시지 타입을 지정합니다.
  Topic({required this.name, required this.messageType});

  /// ROS 발행 작업과 발행할 메시지를 포함하는 맵을 생성합니다.
  ///
  /// [msg]는 발행할 메시지 데이터를 포함하는 맵입니다.
  /// ROS 통신을 위한 작업, 토픽 이름, 메시지 내용을 포함하는 [Map]을 반환합니다.
  Map<String, dynamic> publishMessage(Map<String, dynamic> msg) {
    return {
      "op": "publish",
      "topic": name,
      "msg": msg,
    };
  }
}
