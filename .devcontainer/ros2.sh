#!/bin/bash

# ROS2 환경 설정
echo 'source /opt/ros/humble/setup.bash' >> ~/.bashrc
echo 'export ROS_DOMAIN_ID=13' >> ~/.bashrc
echo 'alias sb="source ~/.bashrc && echo \"bashrc is reloaded\""' >> ~/.bashrc

# 환경설정 적용
source ~/.bashrc

# ROS2 워크스페이스 생성 및 빌드
mkdir -p ~/flutter-ros_ws/ros/src
cd ~/flutter-ros_ws/ros
colcon build

echo "ROS2 Humble 환경 설정 및 빌드 완료"
