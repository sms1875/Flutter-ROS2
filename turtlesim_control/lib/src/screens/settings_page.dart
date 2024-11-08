import 'package:flutter/material.dart';
import '../providers/ros_cli_manager.dart';

/// WebSocket 연결 설정 페이지를 나타내는 위젯
///
/// 사용자가 WebSocket 주소를 입력하고 서버에 연결하거나 연결을 해제할 수 있습니다.
/// 현재 연결 상태와 메시지를 표시하여 서버와의 통신 상태를 확인할 수 있습니다.
class SettingsPage extends StatefulWidget {
  final RosCliManager rosCliManager;

  /// [rosCliManager]는 서버와의 연결을 관리하는 객체로 필수 매개변수입니다.
  const SettingsPage({super.key, required this.rosCliManager});

  @override
  _SettingsPageState createState() => _SettingsPageState();
}

class _SettingsPageState extends State<SettingsPage> {
  final TextEditingController _addressController = TextEditingController();

  @override
  void initState() {
    super.initState();
    _addressController.text = widget.rosCliManager.socketAddress ?? '';
    widget.rosCliManager.addListener(_updateStatus);
  }

  @override
  void dispose() {
    widget.rosCliManager.removeListener(_updateStatus);
    super.dispose();
  }

  /// 상태 업데이트를 위해 setState를 호출하는 함수
  void _updateStatus() => setState(() {});

  /// 연결 상태에 따라 색상을 반환하는 함수
  ///
  /// "Connect" 상태일 경우 초록색, "Connect Fail" 상태일 경우 빨간색,
  /// 기본 상태일 경우 회색을 반환합니다.
  Color _getStatusColor(String status) {
    switch (status) {
      case "Connect":
        return Colors.green;
      case "Connect Fail":
        return Colors.red;
      default:
        return Colors.grey;
    }
  }

  @override
  Widget build(BuildContext context) {
    final status = widget.rosCliManager.connectionStatus;
    final isConnected = status == "Connect";

    return Scaffold(
      appBar: AppBar(title: const Text("Settings")),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          children: [
            _AddressInputField(controller: _addressController),
            const SizedBox(height: 16),
            _ConnectButton(
              isConnected: isConnected,
              onConnect: () async => await widget.rosCliManager.connectServer(
                _addressController.text.isEmpty
                    ? null
                    : _addressController.text,
              ),
              onDisconnect: widget.rosCliManager.disconnect,
            ),
            const SizedBox(height: 16),
            _StatusIndicator(status: status, color: _getStatusColor(status)),
            if (widget.rosCliManager.connectionMessage.isNotEmpty)
              _ConnectionMessage(
                  message: widget.rosCliManager.connectionMessage),
          ],
        ),
      ),
    );
  }
}

/// WebSocket 주소를 입력받는 텍스트 필드 위젯
///
/// 사용자가 WebSocket 주소를 입력할 수 있도록 하는 필드로, [controller]를 통해
/// 입력 값을 관리합니다.
class _AddressInputField extends StatelessWidget {
  final TextEditingController controller;

  const _AddressInputField({required this.controller});

  @override
  Widget build(BuildContext context) {
    return TextField(
      controller: controller,
      decoration: const InputDecoration(
        labelText: "WebSocket Address",
        border: OutlineInputBorder(),
      ),
    );
  }
}

/// 서버 연결 및 연결 해제를 위한 버튼 위젯
///
/// [isConnected]에 따라 버튼의 텍스트와 동작이 달라지며, 서버와의 연결을
/// 제어할 수 있습니다. [onConnect]와 [onDisconnect] 콜백을 통해 연결 작업을 수행합니다.
class _ConnectButton extends StatelessWidget {
  final bool isConnected;
  final VoidCallback onDisconnect;
  final Future<void> Function() onConnect;

  const _ConnectButton({
    required this.isConnected,
    required this.onConnect,
    required this.onDisconnect,
  });

  @override
  Widget build(BuildContext context) {
    return ElevatedButton(
      onPressed: isConnected ? onDisconnect : onConnect,
      child: Text(isConnected ? "Disconnect" : "Connect"),
    );
  }
}

/// 현재 연결 상태를 표시하는 위젯
///
/// [status]와 [color]를 사용하여 연결 상태를 텍스트로 표시하며,
/// 상태에 따라 색상이 달라집니다.
class _StatusIndicator extends StatelessWidget {
  final String status;
  final Color color;

  const _StatusIndicator({required this.status, required this.color});

  @override
  Widget build(BuildContext context) {
    return Text(
      "Status: $status",
      style: TextStyle(color: color, fontWeight: FontWeight.bold),
    );
  }
}

/// 서버와의 연결 메시지를 표시하는 위젯
///
/// [message]를 통해 현재 연결 상태에 대한 세부 메시지를 표시합니다.
class _ConnectionMessage extends StatelessWidget {
  final String message;

  const _ConnectionMessage({required this.message});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(top: 8.0),
      child: Text(
        message,
        style: const TextStyle(fontSize: 14),
      ),
    );
  }
}
