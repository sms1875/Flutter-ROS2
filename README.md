## 소개

ROS와 WebSocket을 통해 `turtlesim`을 원격 제어할 수 있는 Flutter 애플리케이션 개발 프로젝트입니다.

**깃허브 링크:** https://github.com/sms1875/Flutter-ROS2

**Youtube 시연 영상**: https://www.youtube.com/watch?v=IgKFjTNAdM4

<img src="https://github.com/user-attachments/assets/74af9277-5f39-47e5-959e-9d062d752e95" width="200"/>

<br/>

## 개발 환경

- Tools: VS Code, Docker
- Front: Flutter
- ROS: ROS TurtleSim 패키지, rosbridge server
- 데이터 관리: Provider (상태 관리), WebSocket (통신)

<br/>

## 기능 설명

### 서버 연결 및 상태 관리

- WebSocket을 통해 ROS 서버에 연결 및 연결 해제 기능 제공
- 서버 연결 상태를 UI를 통해 실시간으로 확인하고 관리

### 터틀봇 제어

- 터틀봇 생성, 삭제
- 버튼을 통한 터틀봇 움직임 및 정지
- 펜 색상과 굵기 설정
- 절대 및 상대 좌표로 터틀봇 위치 이동
- 터틀봇의 namespace를 이용하여 개별 제어 가능

<br/>

## 스크린 구성

### 홈 화면

- 터틀봇 연결 상태 및 목록을 표시합니다.
- 서버에 연결되어 있지 않으면 연결이 필요하다는 텍스트를 출력합니다.
- 서버에 연결되어 있으면 존재하는 터틀봇의 목록을 표시합니다.
- 클릭 시 각 터틀봇 제어 페이지로 이동할 수 있습니다.


| 홈 화면 |
|----------|
| <img src="https://github.com/user-attachments/assets/df048915-34b0-4d81-bcea-207576eb6b6c" width="300"/> <img src="https://github.com/user-attachments/assets/528e2785-1b42-42e6-a254-196902ad5ee7" width="300"/> |


### 설정 화면

- ROS 서버의 WebSocket 주소를 입력하고 연결 상태를 설정할 수 있습니다.
- 연결 성공, 실패 상태를 UI로 나타냅니다.


| 설정 화면 |
|----------|
| <img src="https://github.com/user-attachments/assets/d415c253-6d2a-45cf-b1b4-cdcdf2c21f90" width="300"/> <img src="https://github.com/user-attachments/assets/f632c634-d0e4-4170-a7a4-dc627a8f666e" width="300"/> |


### 터틀 제어 화면

- 특정 터틀봇의 이동, 펜 설정, 텔레포트 기능을 제공합니다.

**터틀봇 이동 제어**

- 방향 버튼을 눌러 터틀봇을 상하좌우로 움직이거나 정지할 수 있습니다.

**펜 설정 및 비활성화**

- 사용자는 터틀봇 펜의 색상과 두께를 설정할 수 있으며, 필요시 펜을 비활성화할 수 있습니다.

**위치 조정 (텔레포트)**

- 터틀봇을 특정 좌표와 각도로 순간 이동시킬 수 있습니다.


| 터틀 제어 화면 |
|----------|
| <img src="https://github.com/user-attachments/assets/b3fd5570-8ed5-4db7-9a77-973a44ccb415" width="400"/> |
