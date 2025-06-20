import 'package:flutter/material.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'screens/home_screen.dart';
import 'screens/map_screen.dart';
import 'screens/login_screen.dart';
import 'screens/signup_screen.dart';
import 'screens/profile_screen.dart';
import 'screens/profileedit_screen.dart';
import 'screens/stamps_collection_screen.dart';

Future<void> main() async {
  try {
    WidgetsFlutterBinding.ensureInitialized();
    await dotenv.load(fileName: ".env");
  } catch (e) {
    print('Error loading .env file: $e');
  }
  runApp(const NiigataFlowerGuide());
}

class NiigataFlowerGuide extends StatelessWidget {
  const NiigataFlowerGuide({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'Niigata 花図鑑',
      theme: ThemeData(
        scaffoldBackgroundColor: const Color(0xFFf4efe1),
        colorScheme: ColorScheme.fromSeed(seedColor: const Color(0xFF3E5C40)),
        useMaterial3: true,
      ),
      builder: (context, child) {
        return MediaQuery(
          data: MediaQuery.of(context).copyWith(textScaleFactor: 1.0),
          child: child!,
        );
      },
      initialRoute: '/login',
      routes: {
        '/login': (context) => const LoginScreen(),
        '/signup': (context) => const SignupScreen(),
        '/': (context) => const HomeScreen(),
        '/map': (context) => const MapScreen(),
        '/profile': (context) => const ProfileScreen(),
        '/profileedit': (context) => const ProfileEditScreen(),
        '/collection': (context) => const StampCollectionScreen(),
      },
    );
  }
}
