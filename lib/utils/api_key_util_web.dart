import 'dart:js' as js;

String getGoogleMapsApiKey() {
  return js.context['GOOGLE_MAPS_API_KEY'] as String? ?? '';
} 