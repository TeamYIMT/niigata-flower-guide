// lib/main.dart
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:firebase_core/firebase_core.dart';

import 'firebase_options.dart';
import 'providers/auth_provider.dart';
import 'providers/stamp_provider.dart';     // ★追加

import 'screens/login_screen.dart';
import 'screens/home_screen.dart';
import 'pages/unity_webview_page.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp(
    options: DefaultFirebaseOptions.currentPlatform,
  );
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MultiProvider(                            // ★ ここを MultiProvider に
      providers: [
        ChangeNotifierProvider(create: (_) => AuthProvider()),
        ChangeNotifierProvider(create: (_) => StampProvider()), // ★ 追加
      ],
      child: MaterialApp(
        debugShowCheckedModeBanner: false,
        title: 'Niigata 花図鑑',
        // “毎回”AuthGate から開始
        onGenerateInitialRoutes: (_) => [
          MaterialPageRoute(builder: (_) => const _AuthGate()),
        ],
        routes: {
          '/home': (_) => const HomeScreen(),
          '/login': (_) => const LoginScreen(),
          '/unity': (_) => const UnityWebViewPage(),
        },
      ),
    );
  }
}

class _AuthGate extends StatelessWidget {
  const _AuthGate();

  @override
  Widget build(BuildContext context) {
    final auth = context.watch<AuthProvider>();
    if (auth.isLoading) {
      return const Scaffold(body: Center(child: CircularProgressIndicator()));
    }
    if (auth.user == null || auth.isAnonymous) {
      return const LoginScreen();
    }
    return const HomeScreen();
  }
}
