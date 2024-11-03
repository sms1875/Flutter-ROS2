import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'src/providers/ros_cli_manager.dart';
import 'src/screens/home_page.dart';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MultiProvider(
      providers: [
        ChangeNotifierProvider(create: (_) => RosCliManager()),
      ],
      child: MaterialApp(
        debugShowCheckedModeBanner: false,
        title: 'TurtleSim Control',
        theme: ThemeData(
          primarySwatch: Colors.blue,
        ),
        home: const HomePage(),
      ),
    );
  }
}
