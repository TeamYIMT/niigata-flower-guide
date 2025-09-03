import 'package:flutter/foundation.dart' show kDebugMode;
import 'package:flutter/material.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_analytics/firebase_analytics.dart';
import 'package:provider/provider.dart';
import 'package:geolocator_platform_interface/geolocator_platform_interface.dart';
import 'package:geolocator/geolocator.dart';
import 'firebase_options.dart';
import 'providers/stamp_provider.dart';
import 'providers/auth_provider.dart';
import 'screens/home_screen.dart';
import 'screens/map_screen.dart';
import 'screens/login_screen.dart';
import 'screens/signup_screen.dart';
import 'screens/profile_screen.dart';
import 'screens/profileedit_screen.dart';
import 'screens/stamps_collection_screen.dart';
import 'screens/unity_ar_screen.dart';  // Unity連携を一旦保留

// デモ設定クラス
class _DemoConfig {
  static const demoMode = bool.fromEnvironment('DEMO', defaultValue: false);
}

// 偽装位置情報クラス（テスト用）
class FakeGeolocatorPlatform extends GeolocatorPlatform {
  final Position _fakePosition;
  
  FakeGeolocatorPlatform(this._fakePosition);

  @override
  Future<Position> getCurrentPosition({
    LocationSettings? locationSettings,
  }) async {
    return _fakePosition;
  }

  @override
  Future<LocationPermission> checkPermission() async {
    return LocationPermission.always;
  }

  @override
  Future<LocationPermission> requestPermission() async {
    return LocationPermission.always;
  }

  @override
  Future<bool> isLocationServiceEnabled() async {
    return true;
  }

  @override
  double distanceBetween(
    double startLatitude,
    double startLongitude,
    double endLatitude,
    double endLongitude,
  ) {
    return Geolocator.distanceBetween(
      startLatitude,
      startLongitude,
      endLatitude,
      endLongitude,
    );
  }
}

Future<void> main() async {
  try {
    WidgetsFlutterBinding.ensureInitialized();
    
    // デモモードでのジオロケーション偽装設定
    if (kDebugMode && _DemoConfig.demoMode) {
      // 新潟県の中心付近を偽装位置として設定
      final fakePosition = Position(
        latitude: 37.9026,
        longitude: 139.0232,
        timestamp: DateTime.now(),
        accuracy: 5.0,
        altitude: 0.0,
        heading: 0.0,
        speed: 0.0,
        speedAccuracy: 0.0,
        altitudeAccuracy: 0.0,
        headingAccuracy: 0.0,
      );
      
      GeolocatorPlatform.instance = FakeGeolocatorPlatform(fakePosition);
      print('🧪 デモモード: 偽装位置情報を設定しました (${fakePosition.latitude}, ${fakePosition.longitude})');
    }
    
    // Initialize Firebase
    await Firebase.initializeApp(
      options: DefaultFirebaseOptions.currentPlatform,
    );
    
    // Initialize Firebase Analytics
    FirebaseAnalytics.instance;
    
    // .envファイルの読み込み（Web環境では無視）
    try {
      await dotenv.load(fileName: ".env");
      print('✅ .envファイルを読み込みました');
    } catch (e) {
      print('📝 .envファイルが見つかりません（Web環境では正常です）');
    }
  } catch (e) {
    print('❌ アプリ初期化エラー: $e');
  }
  runApp(const NiigataFlowerGuide());
}

class NiigataFlowerGuide extends StatelessWidget {
  const NiigataFlowerGuide({super.key});



  @override
  Widget build(BuildContext context) {
    return MultiProvider(
      providers: [
        ChangeNotifierProvider(create: (_) => AuthProvider()),
        ChangeNotifierProvider(create: (_) => StampProvider()),
      ],
      child: Consumer<AuthProvider>(
        builder: (context, authProvider, child) {
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
            // 認証状態に応じて初期ルートを決定
            initialRoute: authProvider.isAuthenticated ? '/' : '/login',
            routes: {
              '/login': (context) => const LoginScreen(),
              '/signup': (context) => const SignupScreen(),
              '/': (context) => const HomeScreen(),
              '/map': (context) => const MapScreen(),
              '/profile': (context) => const ProfileScreen(),
              '/profileedit': (context) => const ProfileEditScreen(),
              '/collection': (context) => const StampCollectionScreen(),
              '/ar': (context) => UnityARScreen(),
            },
          );
        },
      ),
    );
  }
}
