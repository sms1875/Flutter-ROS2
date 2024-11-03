import 'ros_models.dart';

Map<String, dynamic> spawnService(double x, double y, double theta) {
  return Service(name: "/spawn").callService({
    "x": x,
    "y": y,
    "theta": theta,
  });
}

Map<String, dynamic> killService(String name) {
  return Service(name: "/kill").callService({"name": name});
}

class Turtlesim {
  final String name;

  final Topic poseTopic;
  final Topic velocityTopic;
  final Service teleportAbsoluteService;
  final Service teleportRelativeService;
  final Service setPenService;
  final Service clearService;
  final Service spawnService;
  final Service killService;

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

  // 거북이의 속도 설정 메시지 생성
  Map<String, dynamic> setVelocity(double linearX, double angularZ) {
    return velocityTopic.publishMessage({
      "linear": {"x": linearX, "y": 0.0, "z": 0.0},
      "angular": {"x": 0.0, "y": 0.0, "z": angularZ},
    });
  }

  // 절대 위치 이동 서비스 호출 메시지 생성
  Map<String, dynamic> callTeleportAbsolute(double x, double y, double theta) {
    return teleportAbsoluteService.callService({
      "x": x,
      "y": y,
      "theta": theta,
    });
  }

  // 상대 위치 이동 서비스 호출 메시지 생성
  Map<String, dynamic> callTeleportRelative(double linear, double angular) {
    return teleportRelativeService.callService({
      "linear": linear,
      "angular": angular,
    });
  }

  // 펜 설정 서비스 호출 메시지 생성
  Map<String, dynamic> callSetPen(int off, int r, int g, int b, int width) {
    return setPenService.callService({
      "off": off,
      "r": r,
      "g": g,
      "b": b,
      "width": width,
    });
  }

  // 화면을 지우는 서비스 호출 메시지 생성
  Map<String, dynamic> callClear() {
    return clearService.callService({});
  }
}
