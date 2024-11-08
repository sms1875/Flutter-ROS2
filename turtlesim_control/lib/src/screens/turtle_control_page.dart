import 'package:flutter/material.dart';
import '../providers/ros_cli_manager.dart';

/// TurtleSim의 개별 터틀봇을 제어할 수 있는 페이지
///
/// 터틀봇의 이동, 펜 설정, 텔레포트 기능을 제공하며,
/// ROS 클라이언트를 통해 서버와의 상호작용을 지원합니다.
class TurtleControlPage extends StatefulWidget {
  final String namespace;
  final RosCliManager rosCliManager;

  /// [namespace]는 제어할 터틀봇의 이름이며, [rosCliManager]는 ROS 서버와의 통신을 담당합니다.
  const TurtleControlPage({
    super.key,
    required this.namespace,
    required this.rosCliManager,
  });

  @override
  State<TurtleControlPage> createState() => _TurtleControlPageState();
}

class _TurtleControlPageState extends State<TurtleControlPage> {
  Color selectedColor = Colors.black;
  double penWidth = 5.0;
  final TextEditingController xController = TextEditingController(text: '5.0');
  final TextEditingController yController = TextEditingController(text: '5.0');
  final TextEditingController thetaController =
      TextEditingController(text: '0.0');

  @override
  void dispose() {
    xController.dispose();
    yController.dispose();
    thetaController.dispose();
    super.dispose();
  }

  /// 터틀봇 펜의 색상과 두께를 설정하는 함수
  void _updatePen() {
    int r = selectedColor.red;
    int g = selectedColor.green;
    int b = selectedColor.blue;
    widget.rosCliManager.setTurtlePen(
      widget.namespace,
      false,
      r,
      g,
      b,
      penWidth.round(),
    );
  }

  /// 터틀봇의 위치를 설정된 좌표로 이동시키는 함수
  ///
  /// [x], [y], [theta] 값을 읽어들여서 해당 위치로 터틀봇을 이동시킵니다.
  void _handleTeleport() {
    try {
      double x = double.parse(xController.text);
      double y = double.parse(yController.text);
      double theta = double.parse(thetaController.text);
      widget.rosCliManager.teleportTurtle(widget.namespace, x, y, theta);
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Please enter valid numbers')),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text("${widget.namespace} Control Page"),
        actions: [
          IconButton(
            icon: const Icon(Icons.cleaning_services),
            onPressed: widget.rosCliManager.clearScreen,
            tooltip: "Clear Screen",
          ),
        ],
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            const SectionTitle("Control Functions"),
            const SizedBox(height: 20),
            MovementControls(onMove: widget.rosCliManager.moveTurtle),
            const SizedBox(height: 20),
            PenControls(
              selectedColor: selectedColor,
              onColorChange: (color) => setState(() {
                selectedColor = color;
                _updatePen();
              }),
              penWidth: penWidth,
              onWidthChange: (value) => setState(() {
                penWidth = value;
                _updatePen();
              }),
              disablePen: () => widget.rosCliManager.setTurtlePen(
                widget.namespace,
                true,
                0,
                0,
                0,
                0,
              ),
            ),
            const SizedBox(height: 20),
            TeleportControls(
              xController: xController,
              yController: yController,
              thetaController: thetaController,
              onTeleport: _handleTeleport,
              onCenter: () => widget.rosCliManager
                  .teleportTurtle(widget.namespace, 5.0, 5.0, 0.0),
            ),
          ],
        ),
      ),
    );
  }
}

/// 섹션 제목을 표시하는 위젯
///
/// [title]에 표시할 제목을 전달받습니다.
class SectionTitle extends StatelessWidget {
  final String title;

  const SectionTitle(this.title, {super.key});

  @override
  Widget build(BuildContext context) {
    return Text(
      title,
      style: const TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
      textAlign: TextAlign.center,
    );
  }
}

/// 터틀봇의 이동을 제어하는 컨트롤 위젯
///
/// 방향 버튼을 통해 터틀봇을 원하는 방향으로 이동시키거나 정지시킬 수 있습니다.
class MovementControls extends StatelessWidget {
  final Function(String, double, double) onMove;

  const MovementControls({super.key, required this.onMove});

  @override
  Widget build(BuildContext context) {
    return _buildContainer(
      title: "Movement Controls",
      child: Column(
        children: [
          _buildIconButton(
            Icons.arrow_upward,
            "Up",
            () => onMove("namespace", 2.0, 0.0),
          ),
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              _buildIconButton(
                Icons.arrow_back,
                "Left",
                () => onMove("namespace", 0.0, 2.0),
              ),
              _buildIconButton(
                Icons.stop,
                "Stop",
                () => onMove("namespace", 0.0, 0.0),
                color: Colors.red,
              ),
              _buildIconButton(
                Icons.arrow_forward,
                "Right",
                () => onMove("namespace", 0.0, -2.0),
              ),
            ],
          ),
          _buildIconButton(
            Icons.arrow_downward,
            "Down",
            () => onMove("namespace", -2.0, 0.0),
          ),
        ],
      ),
    );
  }

  Widget _buildIconButton(IconData icon, String tooltip, VoidCallback onPressed,
      {Color color = Colors.blueAccent}) {
    return IconButton(
      icon: Icon(icon),
      onPressed: onPressed,
      iconSize: 40,
      color: color,
      tooltip: tooltip,
    );
  }
}

/// 터틀봇의 펜을 설정하는 컨트롤 위젯
///
/// 펜 색상 및 두께를 설정하고, 펜을 비활성화할 수 있는 기능을 제공합니다.
class PenControls extends StatelessWidget {
  final Color selectedColor;
  final ValueChanged<Color> onColorChange;
  final double penWidth;
  final ValueChanged<double> onWidthChange;
  final VoidCallback disablePen;

  const PenControls({
    super.key,
    required this.selectedColor,
    required this.onColorChange,
    required this.penWidth,
    required this.onWidthChange,
    required this.disablePen,
  });

  @override
  Widget build(BuildContext context) {
    return _buildContainer(
      title: "Pen Controls",
      child: Column(
        children: [
          Wrap(
            spacing: 8,
            runSpacing: 8,
            children: [
              Colors.red,
              Colors.green,
              Colors.blue,
              Colors.yellow,
              Colors.purple,
              Colors.orange,
              Colors.black,
            ].map((color) {
              return InkWell(
                onTap: () => onColorChange(color),
                child: Container(
                  width: 40,
                  height: 40,
                  decoration: BoxDecoration(
                    color: color,
                    border: Border.all(
                      color:
                          selectedColor == color ? Colors.white : Colors.grey,
                      width: 2,
                    ),
                    borderRadius: BorderRadius.circular(20),
                  ),
                ),
              );
            }).toList(),
          ),
          const SizedBox(height: 16),
          Row(
            children: [
              const Text('Pen Width: '),
              Expanded(
                child: Slider(
                  value: penWidth,
                  min: 1,
                  max: 20,
                  divisions: 19,
                  label: penWidth.round().toString(),
                  onChanged: onWidthChange,
                ),
              ),
              Text(penWidth.round().toString()),
            ],
          ),
          const SizedBox(height: 16),
          ElevatedButton(
            onPressed: disablePen,
            style: ElevatedButton.styleFrom(backgroundColor: Colors.grey[600]),
            child: const Text("Disable Pen"),
          ),
        ],
      ),
    );
  }
}

/// 터틀봇의 위치를 설정하는 텔레포트 컨트롤 위젯
///
/// 사용자가 원하는 좌표와 각도로 이동할 수 있는 기능을 제공합니다.
class TeleportControls extends StatelessWidget {
  final TextEditingController xController;
  final TextEditingController yController;
  final TextEditingController thetaController;
  final VoidCallback onTeleport;
  final VoidCallback onCenter;

  const TeleportControls({
    super.key,
    required this.xController,
    required this.yController,
    required this.thetaController,
    required this.onTeleport,
    required this.onCenter,
  });

  @override
  Widget build(BuildContext context) {
    return _buildContainer(
      title: "Teleport Controls",
      child: Column(
        children: [
          Row(
            children: [
              Expanded(
                child: TextField(
                  controller: xController,
                  decoration: const InputDecoration(labelText: 'X Coordinate'),
                  keyboardType: TextInputType.number,
                ),
              ),
              const SizedBox(width: 8),
              Expanded(
                child: TextField(
                  controller: yController,
                  decoration: const InputDecoration(labelText: 'Y Coordinate'),
                  keyboardType: TextInputType.number,
                ),
              ),
              const SizedBox(width: 8),
              Expanded(
                child: TextField(
                  controller: thetaController,
                  decoration: const InputDecoration(labelText: 'Theta (rad)'),
                  keyboardType: TextInputType.number,
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
            children: [
              ElevatedButton(
                onPressed: onTeleport,
                child: const Text("Teleport to Coordinates"),
              ),
              ElevatedButton(
                onPressed: onCenter,
                child: const Text("Center (5, 5)"),
              ),
            ],
          ),
        ],
      ),
    );
  }
}

/// 스타일이 적용된 컨테이너 위젯
///
/// [title]과 [child]를 받아 제목과 함께 표시됩니다.
Widget _buildContainer({required String title, required Widget child}) {
  return Container(
    padding: const EdgeInsets.all(16.0),
    decoration: BoxDecoration(
      color: Colors.grey[200],
      borderRadius: BorderRadius.circular(10),
      border: Border.all(color: Colors.grey[400]!),
    ),
    child: Column(
      children: [
        Text(
          title,
          style: const TextStyle(fontSize: 18, fontWeight: FontWeight.w500),
        ),
        const SizedBox(height: 10),
        child,
      ],
    ),
  );
}
