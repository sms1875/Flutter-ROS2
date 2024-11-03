import 'package:flutter/material.dart';
import '../providers/ros_cli_manager.dart';

class TurtleControlPage extends StatelessWidget {
  final String namespace;
  final RosCliManager rosCliManager;

  const TurtleControlPage({
    super.key,
    required this.namespace,
    required this.rosCliManager,
  });

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text("Control $namespace"),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            _buildTitle("Control functions for $namespace"),
            const SizedBox(height: 20),
            _buildMovementControls(),
            const SizedBox(height: 20),
            _buildPenControls(),
          ],
        ),
      ),
    );
  }

  Widget _buildTitle(String title) {
    return Text(
      title,
      style: const TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
      textAlign: TextAlign.center,
    );
  }

  Widget _buildMovementControls() {
    return _buildContainer(
      title: "Movement Controls",
      child: Column(
        children: [
          _buildIconButton(Icons.arrow_upward, "Up",
              () => rosCliManager.moveTurtle(namespace, 2.0, 0.0)),
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              _buildIconButton(Icons.arrow_back, "Left",
                  () => rosCliManager.moveTurtle(namespace, 0.0, 2.0)),
              _buildIconButton(
                  Icons.stop, "Stop", () => rosCliManager.stopTurtle(namespace),
                  color: Colors.red),
              _buildIconButton(Icons.arrow_forward, "Right",
                  () => rosCliManager.moveTurtle(namespace, 0.0, -2.0)),
            ],
          ),
          _buildIconButton(Icons.arrow_downward, "Down",
              () => rosCliManager.moveTurtle(namespace, -2.0, 0.0)),
        ],
      ),
    );
  }

  Widget _buildPenControls() {
    return _buildContainer(
      title: "Pen Controls",
      child: Column(
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
            children: [
              _buildPenButton(
                  "Red Pen",
                  Colors.red[400]!,
                  () => rosCliManager.setTurtlePen(
                      namespace, false, 255, 0, 0, 5)),
              _buildPenButton(
                  "Green Pen",
                  Colors.green[400]!,
                  () => rosCliManager.setTurtlePen(
                      namespace, false, 0, 255, 0, 5)),
            ],
          ),
          const SizedBox(height: 10),
          ElevatedButton(
            onPressed: () =>
                rosCliManager.setTurtlePen(namespace, true, 0, 0, 0, 0),
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.grey[600],
            ),
            child: const Text("Disable Pen"),
          ),
        ],
      ),
    );
  }

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

  Widget _buildPenButton(String label, Color color, VoidCallback onPressed) {
    return ElevatedButton(
      onPressed: onPressed,
      style: ElevatedButton.styleFrom(backgroundColor: color),
      child: Text(label),
    );
  }
}
