# Dockerfile
FROM osrf/ros:humble-desktop-full

# apt 업데이트
RUN apt update && apt upgrade -y

# 필수 패키지 설치
RUN apt install -y git curl unzip

# ROS2 환경 설정
RUN echo 'source /opt/ros/humble/setup.bash' >> /etc/bash.bashrc && \
    echo 'alias sb="source ~/.bashrc && echo \"bashrc is reloaded\""' >> /etc/bash.bashrc

# ROS2 Bridge 설치
RUN apt install -y ros-humble-rosbridge-server

# Flutter 설치 및 환경 변수 설정
RUN git clone https://github.com/flutter/flutter.git -b stable /opt/flutter && \
    echo 'export PATH=$PATH:/opt/flutter/bin' >> /etc/bash.bashrc && \
    /opt/flutter/bin/flutter precache && \
    /opt/flutter/bin/flutter --version

# 설치 확인
RUN /opt/flutter/bin/flutter --version

# Flutter Linux 데스크톱 빌드 필수 패키지 설치 및 설정
RUN apt install -y clang cmake ninja-build pkg-config libgtk-3-dev liblzma-dev && \
    /opt/flutter/bin/flutter config --enable-linux-desktop


CMD ["bash"]
