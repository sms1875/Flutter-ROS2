import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/ros_cli_manager.dart';
import 'turtle_control_page.dart';
import 'settings_page.dart';

/// TurtleSim 제어 애플리케이션의 홈 페이지를 표시하는 위젯
///
/// [RosCliManager]를 사용하여 현재 터틀봇 상태 및 서버 연결 상태를 관리합니다.
/// 앱의 주요 화면으로, 서버 연결 상태에 따라 UI가 동적으로 변경됩니다.
class HomePage extends StatelessWidget {
  const HomePage({super.key});

  @override
  Widget build(BuildContext context) {
    final rosCliManager = Provider.of<RosCliManager>(context);

    return Scaffold(
      appBar: AppBar(
        title: const Text("TurtleSim Control"),
        actions: [
          _SettingsButton(rosCliManager: rosCliManager),
        ],
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: _buildContent(context, rosCliManager),
      ),
    );
  }

  /// 서버 연결 상태에 따라 화면에 표시할 콘텐츠를 생성
  ///
  /// [rosCliManager]의 상태에 따라 서버 연결 전, 연결 중, 데이터 로딩, 데이터 로드 완료의
  /// 각 상태에 맞는 위젯을 반환합니다.
  Widget _buildContent(BuildContext context, RosCliManager rosCliManager) {
    switch (rosCliManager.state) {
      case AppState.disconnected:
        return const Center(
          child: Text(
            "Please Connect Server.",
            style: TextStyle(fontSize: 16),
            textAlign: TextAlign.center,
          ),
        );

      case AppState.connecting:
      case AppState.loadingData:
        return const Center(child: CircularProgressIndicator());

      case AppState.dataLoaded:
        return Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                ElevatedButton.icon(
                  icon: const Icon(Icons.refresh),
                  label: const Text("Refresh"),
                  onPressed: rosCliManager.getTurtleData,
                ),
                ElevatedButton.icon(
                  icon: const Icon(Icons.add),
                  label: const Text("Add Turtle"),
                  onPressed: rosCliManager.addNewTurtle,
                ),
              ],
            ),
            const SizedBox(height: 16),
            Expanded(child: _TurtleList(rosCliManager: rosCliManager)),
          ],
        );

      default:
        return const SizedBox.shrink();
    }
  }
}

/// 터틀봇 리스트를 표시하는 위젯
///
/// 서버에서 로드된 터틀봇 목록을 표시하고, 각 터틀봇을 터치하여 제어 페이지로 이동할 수 있습니다.
/// 삭제 버튼을 통해 개별 터틀봇을 삭제할 수 있습니다.
class _TurtleList extends StatelessWidget {
  final RosCliManager rosCliManager;

  const _TurtleList({required this.rosCliManager});

  @override
  Widget build(BuildContext context) {
    return ListView.builder(
      itemCount: rosCliManager.turtleList.length,
      itemBuilder: (context, index) {
        final namespace = rosCliManager.turtleList[index];
        return ListTile(
          title: Text("Turtle: $namespace"),
          subtitle: Text("Namespace: $namespace"),
          trailing: IconButton(
            icon: const Icon(Icons.delete),
            onPressed: () => rosCliManager.removeTurtle(namespace),
          ),
          onTap: () => Navigator.push(
            context,
            MaterialPageRoute(
              builder: (context) => TurtleControlPage(
                namespace: namespace,
                rosCliManager: rosCliManager,
              ),
            ),
          ),
        );
      },
    );
  }
}

/// 설정 버튼을 나타내는 위젯
///
/// 설정 페이지로 이동할 수 있는 아이콘 버튼을 제공합니다. 설정 페이지에서 돌아온 후
/// 서버 연결이 유지되어 있을 경우 터틀 데이터를 다시 로드합니다.
class _SettingsButton extends StatelessWidget {
  final RosCliManager rosCliManager;

  const _SettingsButton({required this.rosCliManager});

  @override
  Widget build(BuildContext context) {
    return IconButton(
      icon: const Icon(Icons.settings),
      onPressed: () {
        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (context) => SettingsPage(rosCliManager: rosCliManager),
          ),
        ).then((_) {
          if (rosCliManager.isConnected) {
            rosCliManager.getTurtleData();
          }
        });
      },
    );
  }
}
