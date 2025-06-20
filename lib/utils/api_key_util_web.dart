import 'dart:html' as html;

String getGoogleMapsApiKey() {
  return html.window['GOOGLE_MAPS_API_KEY'] as String? ?? '';
} 