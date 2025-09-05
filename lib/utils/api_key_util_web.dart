import 'dart:html' as html;

String getGoogleMapsApiKey() {
  return html.window.localStorage['GOOGLE_MAPS_API_KEY'] ?? '';
} 