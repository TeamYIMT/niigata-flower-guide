import 'package:flutter/material.dart';
import 'screens/home_screen.dart';
import 'screens/map_screen.dart';
import 'screens/login_screen.dart';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Niigata 花図鑑',
      theme: ThemeData(
        scaffoldBackgroundColor: const Color(0xFFf4efe1),
        colorScheme: ColorScheme.fromSeed(seedColor: const Color(0xFF3E5C40)),
      ),
      initialRoute: '/login',
      routes: {
        '/login': (context) => const LoginScreen(),
        '/': (context) => const HomeScreen(),
        '/map': (context) => const MapScreen(),
      },
    );
  }
}
