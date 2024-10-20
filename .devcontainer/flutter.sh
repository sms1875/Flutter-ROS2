#!/bin/bash

# Flutter SDK 설치
git clone https://github.com/flutter/flutter.git -b stable ~/flutter

# 환경 변수 설정
echo 'export PATH=$PATH:$HOME/flutter/bin' >> ~/.bashrc
source ~/.bashrc

# Flutter 종속성 캐시
flutter precache

sudo apt-get install unzip
flutter --version

# Flutter 프로젝트 생성
mkdir -p ~/flutter-ros_ws/flutter_app
cd ~/flutter-ros_ws/flutter_app
flutter create .

echo "Flutter 환경 설정 및 프로젝트 생성 완료"
