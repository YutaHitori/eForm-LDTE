import 'dart:convert';
import 'dart:typed_data';

import 'package:web/web.dart' as web;

Future<void> savePdf(Uint8List bytes, String fileName) async {
  web.HTMLAnchorElement()
    ..href =
        "data:application/octet-stream;charset=utf-16le;base64,${base64.encode(bytes)}"
    ..setAttribute("download", fileName)
    ..click();
}
