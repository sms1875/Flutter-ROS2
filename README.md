# Ros2 Turtlesim Flutter Controller

## 🚀 프로젝트 진행

### 🔗 **프로젝트 링크**

- **GitHub**: https://github.com/sms1875/Flutter-ROS2
- **YouTube**: https://www.youtube.com/watch?v=IgKFjTNAdM4
- **YouTube QR Link**: <img src="https://github.com/user-attachments/assets/74af9277-5f39-47e5-959e-9d062d752e95" width="200"/>

### 📅 프로젝트 진행 기간

2024.10.04 ~ 2025.01.08

### ✅ 구현 기능

- ROS2 WebSocket 서버 구축 및 통신 프로토콜 설계
- Flutter Linux Desktop UI/UX 개발
- 실시간 양방향 통신 구현 및 최적화
- Docker 컨테이너화 및 배포 환경 구성

### 🔍 **회고**

- 💡 WebSocket 통신 구현 과정
    - 초기에는 REST API를 고려했으나 실시간성 확보를 위해 WebSocket으로 전환
    - JSON-RPC를 도입하여 메시지 구조화 및 에러 처리 개선
    - 연결 안정성 확보를 위한 heartbeat 시스템 구현
- 🚀 Flutter 상태관리
    - Provider 패턴을 활용한 효율적인 상태관리 구현
    - 실시간 UI 업데이트 구현
    - 멀티 터틀 제어를 위한 상태 동기화 로직 구현
- 💡 ROS2 기본 통신 프로토콜 이해
    - ROS2 기본 통신 프로토콜 이해를 위해 roslibdart 라이브러리를 사용하지 않고 직접 구현
    - ROS2 인터페이스 사양 분석 (rosbridge_suite)
    - QoS 설정 매핑 (DDS ↔ Flutter)

---

## 📌 **프로젝트 개요**

### 🐢 **Ros2 Turtlesim Flutter Controller**

**ROS2 Web Socket**을 이용하여 **Flutter에서 ROS2 Turtlesim을 제어**하는 프로젝트입니다.

### 🎯 **프로젝트 목적**

- https://speakerdeck.com/itsmedreamwalker/flutter-linux-desktop-with-ros2 를 참고하여 프로젝트 구축
- **ROS2 기반 IoT 디바이스 제어 프레임워크 구축**
- Flutter 모바일 앱과 ROS2의 실시간 양방향 통신 구현
- IoT 환경에서의 로봇 제어 컨트롤 앱 개발

### 🛠 **기술 스택**

| 구분 | 사용 기술 |
| --- | --- |
| 통신 | WebSocket, JSON-RPC |
| 개발 환경 | Docker, Ubuntu |
| 프론트엔드 | Flutter, Provider  |
| ROS2 환경 | ROS2 Humble, turtlesim, rosbridge_suite |

## **🖥️ 주요 기능**

### **📱 터틀봇 제어 기능**

1. 다중 터틀 관리
    - 터틀 생성 및 삭제
    - 개별 터틀 상태 모니터링
    - namespace 기반 독립 제어
2. 실시간 이동 제어
    - 방향키 기반 직관적 제어
    - 속도 및 각속도 조절
    - 충돌 방지 시스템
3. 고급 제어 기능
    - 절대/상대 좌표 이동
    - 경로 계획 및 실행
    - 펜 색상/굵기 커스터마이징

## 🎮 **구현 세부 사항**

### 🕹️ 실시간 터틀봇 제어

```dart
void _spawnTurtle(String name) {
  _channel.sink.add(jsonEncode({
    'op': 'call_service',
    'service': '/spawn',
    'args': {'x': 5.5, 'y': 5.5, 'theta': 0.0, 'name': name}
  }));
}

```

### 📊 상태 관리

```
class TurtleController extends ChangeNotifier {
  List<String> _turtles = [];

  void addTurtle(String name) {
    _turtles.add(name);
    notifyListeners();
  }
}

```

### 📡 **ROS2 메시지 처리**

```json
{
  "linear": {"x": 0.5, "y": 0.0, "z": 0.0},
  "angular": {"x": 0.0, "y": 0.0, "z": 0.5}
}

```

```
class TurtleManager(Node):
    def __init__(self):
        super().__init__('turtle_manager')
        self.spawn_service = self.create_service(
            Spawn, '/spawn', self.spawn_callback)

    def spawn_callback(self, request, response):
        response.name = f"turtle{random.randint(100,999)}"
        return response

```

## 📸 **화면 구성**

### 🏠 홈 화면

| 연결 전 | 연결 후 |
| --- | --- |
| <img src="https://github.com/user-attachments/assets/df048915-34b0-4d81-bcea-207576eb6b6c" width="300"/> | <img src="https://github.com/user-attachments/assets/528e2785-1b42-42e6-a254-196902ad5ee7" width="300"/> |

**주요 기능:**

- WebSocket 연결 상태 표시
- 활성화된 터틀 목록 조회
- 터틀 선택 시 제어 화면으로 이동

### ⚙️ 설정 화면

| 연결 시도 중 | 연결 성공 |
| --- | --- |
| <img src="https://github.com/user-attachments/assets/d415c253-6d2a-45cf-b1b4-cdcdf2c21f90" width="300"/> | <img src="https://github.com/user-attachments/assets/f632c634-d0e4-4170-a7a4-dc627a8f666e" width="300"/> |

**기능 상세:**

- ROS2 서버 IP/Port 입력
- 연결 상태 실시간 표시 (성공/실패)
- 자동 재연결 기능

### 🎮 제어 화면


| 터틀 제어 화면 |
|-----------|
| <img src="https://github.com/user-attachments/assets/b3fd5570-8ed5-4db7-9a77-973a44ccb415" width="400"/> |

**제어 옵션:**

- 실시간 속도 조절 슬라이더
- 펜 색상 피커 (RGB)
- 좌표 기반 텔레포트 입력 필드

## 🚀 **향후 개선 사항**

### 📌 1. IoT 프로토콜 확장

- MQTT 통신 모듈 추가
- 저전력 BLE 메시징 지원
- LoRaWAN 장거리 통신 구현

### 📌 2. AI 기반 기능 구현

- TensorFlow Lite 모델 임베딩

### 📌 3. 하드웨어 연동 강화

- Raspberry Pi GPIO 제어 지원
- Arduino 센서 데이터 수집 모듈 개발
- 실시간 영상 스트리밍 파이프라인 구축
