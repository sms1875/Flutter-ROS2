import 'ros_models.dart';

class Turtlesim {
  final String name;

  // Turtlesim 관련 토픽과 서비스 초기화
  final Topic poseTopic;
  final Topic velocityTopic;
  final Service teleportAbsoluteService;
  final Service teleportRelativeService;
  final Service setPenService;
  final Service clearService;

  Turtlesim(this.name)
      : poseTopic = Topic(name: "/$name/pose", messageType: "turtlesim/Pose"),
        velocityTopic =
            Topic(name: "/$name/cmd_vel", messageType: "geometry_msgs/Twist"),
        teleportAbsoluteService = Service(name: "/$name/teleport_absolute"),
        teleportRelativeService = Service(name: "/$name/teleport_relative"),
        setPenService = Service(name: "/$name/set_pen"),
        clearService = Service(name: "/clear");

  // 거북이의 속도를 설정하는 명령 전송
  Map<String, dynamic> setVelocity(VelocityCommand command) {
    return velocityTopic.publishMessage(command.toJson());
  }

  // 거북이의 절대 위치를 설정하는 서비스 호출
  Map<String, dynamic> callTeleportAbsolute(TeleportAbsoluteRequest request) {
    return teleportAbsoluteService.callService(request.toJson());
  }

  // 거북이의 상대 위치를 설정하는 서비스 호출
  Map<String, dynamic> callTeleportRelative(TeleportRelativeRequest request) {
    return teleportRelativeService.callService(request.toJson());
  }

  // 펜의 설정을 변경하는 서비스 호출
  Map<String, dynamic> callSetPen(PenSettings settings) {
    return setPenService.callService(settings.toJson());
  }

  // 화면을 지우는 서비스 호출
  Map<String, dynamic> callClear() {
    return clearService.callService({});
  }
}

// 거북이의 속도 명령 클래스
class VelocityCommand {
  final double linear;
  final double angular;

  VelocityCommand({required this.linear, required this.angular});

  Map<String, dynamic> toJson() {
    return {
      "linear": linear,
      "angular": angular,
    };
  }
}

// 거북이의 절대 위치 이동 요청 클래스
class TeleportAbsoluteRequest {
  final double x;
  final double y;
  final double theta;

  TeleportAbsoluteRequest(
      {required this.x, required this.y, required this.theta});

  Map<String, dynamic> toJson() {
    return {
      "x": x,
      "y": y,
      "theta": theta,
    };
  }
}

// 거북이의 상대 위치 이동 요청 클래스
class TeleportRelativeRequest {
  final double linear;
  final double angular;

  TeleportRelativeRequest({required this.linear, required this.angular});

  Map<String, dynamic> toJson() {
    return {
      "linear": linear,
      "angular": angular,
    };
  }
}

// 펜 설정 요청 클래스
class PenSettings {
  final int off; // 수정된 부분: bool 대신 int 타입을 사용
  final int r;
  final int g;
  final int b;
  final int width;

  PenSettings({
    required this.off, // 0 또는 1로 설정
    required this.r,
    required this.g,
    required this.b,
    required this.width,
  });

  Map<String, dynamic> toJson() {
    return {
      "off": off,
      "r": r,
      "g": g,
      "b": b,
      "width": width,
    };
  }
}
