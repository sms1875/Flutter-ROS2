import 'ros_models.dart';

/// /spawn 서비스를 호출하여 새로운 터틀을 생성하는 함수
///
/// [x], [y]는 생성 위치의 좌표이며, [theta]는 초기 회전 각도입니다.
/// 터틀 생성 서비스 호출에 필요한 매개변수를 포함한 [Map]을 반환합니다.
Map<String, dynamic> spawnService(double x, double y, double theta) {
  return Service(name: "/spawn").callService({
    "x": x,
    "y": y,
    "theta": theta,
  });
}

/// /kill 서비스를 호출하여 특정 이름의 터틀을 제거하는 함수
///
/// [name]은 제거할 터틀의 이름입니다.
/// 터틀 제거 서비스 호출에 필요한 매개변수를 포함한 [Map]을 반환합니다.
Map<String, dynamic> killService(String name) {
  return Service(name: "/kill").callService({"name": name});
}

/// /clear 서비스를 호출하여 화면을 초기화하는 함수
///
/// 추가 매개변수 없이 화면 초기화 서비스 호출에 필요한 [Map]을 반환합니다.
Map<String, dynamic> clearService() {
  return Service(name: "/clear").callService({});
}

/// TurtleSim의 개별 인스턴스를 나타내는 클래스
///
/// 각 인스턴스는 터틀의 포즈, 속도, 텔레포트, 펜 설정 등의 기능을 제공합니다.
class Turtlesim {
  /// 터틀 인스턴스의 이름
  final String name;

  /// 포즈 상태를 나타내는 토픽
  final Topic poseTopic;

  /// 속도를 제어하는 토픽
  final Topic velocityTopic;

  /// 절대 위치 이동 서비스
  final Service teleportAbsoluteService;

  /// 상대 위치 이동 서비스
  final Service teleportRelativeService;

  /// 펜 설정 서비스
  final Service setPenService;

  /// 화면 초기화 서비스
  final Service clearService;

  /// 새로운 터틀 생성 서비스
  final Service spawnService;

  /// 터틀 제거 서비스
  final Service killService;

  /// [name]으로 터틀 인스턴스를 생성하며, 서비스와 토픽을 초기화합니다.
  Turtlesim(this.name)
      : poseTopic = Topic(name: "/$name/pose", messageType: "turtlesim/Pose"),
        velocityTopic =
            Topic(name: "/$name/cmd_vel", messageType: "geometry_msgs/Twist"),
        teleportAbsoluteService = Service(name: "/$name/teleport_absolute"),
        teleportRelativeService = Service(name: "/$name/teleport_relative"),
        setPenService = Service(name: "/$name/set_pen"),
        clearService = Service(name: "/clear"),
        spawnService = Service(name: "/spawn"),
        killService = Service(name: "/kill");

  /// 터틀의 속도 설정 메시지를 생성하여 반환하는 함수
  ///
  /// [linearX]는 직진 속도, [angularZ]는 회전 속도입니다.
  /// 해당 속도를 포함한 [Map]을 반환하여 터틀을 제어합니다.
  Map<String, dynamic> setVelocity(double linearX, double angularZ) {
    return velocityTopic.publishMessage({
      "linear": {"x": linearX, "y": 0.0, "z": 0.0},
      "angular": {"x": 0.0, "y": 0.0, "z": angularZ},
    });
  }

  /// 터틀을 절대 위치로 이동시키는 서비스 호출 메시지를 생성하여 반환하는 함수
  ///
  /// [x], [y]는 이동할 좌표, [theta]는 회전 각도입니다.
  /// 절대 위치 이동을 위한 [Map]을 반환하여 터틀의 위치를 설정합니다.
  Map<String, dynamic> callTeleportAbsolute(double x, double y, double theta) {
    return teleportAbsoluteService.callService({
      "x": x,
      "y": y,
      "theta": theta,
    });
  }

  /// 터틀을 상대 위치로 이동시키는 서비스 호출 메시지를 생성하여 반환하는 함수
  ///
  /// [linear]는 전진 거리, [angular]는 회전 각도입니다.
  /// 상대 위치 이동을 위한 [Map]을 반환하여 터틀의 위치를 조정합니다.
  Map<String, dynamic> callTeleportRelative(double linear, double angular) {
    return teleportRelativeService.callService({
      "linear": linear,
      "angular": angular,
    });
  }

  /// 터틀의 펜 설정을 위한 서비스 호출 메시지를 생성하여 반환하는 함수
  ///
  /// [off]는 펜의 활성화 여부, [r], [g], [b]는 RGB 색상, [width]는 펜의 두께입니다.
  /// 펜 설정을 위한 [Map]을 반환하여 터틀의 펜을 제어합니다.
  Map<String, dynamic> callSetPen(int off, int r, int g, int b, int width) {
    return setPenService.callService({
      "off": off,
      "r": r,
      "g": g,
      "b": b,
      "width": width,
    });
  }
}
