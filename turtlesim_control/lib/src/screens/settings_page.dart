import 'package:flutter/material.dart';
import '../providers/ros_cli_manager.dart';

class SettingsPage extends StatefulWidget {
  final RosCliManager rosCliManager;

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

  void _updateStatus() => setState(() {});

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

// 주소 입력 필드 위젯
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

// 연결/해제 버튼 위젯
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

// 연결 상태 표시 위젯
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

// 연결 메시지 표시 위젯
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
