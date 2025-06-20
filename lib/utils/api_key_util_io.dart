import 'package:flutter_dotenv/flutter_dotenv.dart';

String getGoogleMapsApiKey() {
  return dotenv.env['GOOGLE_MAPS_API_KEY'] ?? '';
} 