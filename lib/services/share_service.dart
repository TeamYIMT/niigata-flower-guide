import 'dart:io';
import 'dart:typed_data';

import 'package:path_provider/path_provider.dart';
import 'package:share_plus/share_plus.dart';

/// 共有機能をまとめたサービスクラス。
/// 端末の一時ディレクトリにファイルを書き込み、share_plus で共有シートを開く。
class ShareService {
  /// 画像（PNG / JPEG など）のバイト列を共有する。
  /// [filename] には拡張子を含めたファイル名を指定する。
  /// [text] にはキャプション（スポット名やハッシュタグなど）を指定できる。
  static Future<void> shareImageBytes({
    required Uint8List imageBytes,
    required String filename,
    String? text,
  }) async {
    // 一時ディレクトリ取得
    final dir = await getTemporaryDirectory();
    final filePath = '${dir.path}/$filename';

    // ファイル書き込み
    final file = File(filePath);
    await file.writeAsBytes(imageBytes);

    // XFile にラップして共有
    final xFile = XFile(file.path, mimeType: _guessMime(filename));
    await Share.shareXFiles([xFile], text: text);
  }

  /// 拡張子から簡易的に MIME タイプを推測する。
  static String _guessMime(String name) {
    final lower = name.toLowerCase();
    if (lower.endsWith('.jpg') || lower.endsWith('.jpeg')) return 'image/jpeg';
    if (lower.endsWith('.png')) return 'image/png';
    if (lower.endsWith('.mp4')) return 'video/mp4';
    return 'application/octet-stream';
  }
}
