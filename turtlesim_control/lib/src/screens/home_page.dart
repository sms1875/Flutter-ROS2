import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/ros_cli_manager.dart';
import 'turtle_control_page.dart';
import 'settings_page.dart';

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
