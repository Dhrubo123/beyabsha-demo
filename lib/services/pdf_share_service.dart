import 'dart:io';
import 'dart:typed_data';

import 'package:path_provider/path_provider.dart';
import 'package:share_plus/share_plus.dart';

class PdfShareService {
  const PdfShareService._();

  static Future<void> share({
    required Uint8List bytes,
    required String filename,
    required String title,
  }) async {
    final directory = await getTemporaryDirectory();
    final file = File('${directory.path}/$filename');
    await file.writeAsBytes(bytes, flush: true);
    await SharePlus.instance.share(
      ShareParams(
        title: title,
        text: title,
        files: [XFile(file.path)],
      ),
    );
  }
}
