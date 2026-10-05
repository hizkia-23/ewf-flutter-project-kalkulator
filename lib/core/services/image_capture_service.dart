import 'dart:ui' as ui;
import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';
import 'package:flutter/services.dart';
import 'package:gal/gal.dart';

class ImageCaptureService {
  static Future<bool> captureAndSave(GlobalKey key, String fileNamePrefix) async {
    try {
      // Tunggu frame render selesai sebelum mengambil gambar
      await Future.delayed(const Duration(milliseconds: 100));
      
      RenderRepaintBoundary? boundary = key.currentContext?.findRenderObject() as RenderRepaintBoundary?;
      if (boundary == null) return false;
      
      ui.Image image = await boundary.toImage(pixelRatio: 3.0);
      ByteData? byteData = await image.toByteData(format: ui.ImageByteFormat.png);
      Uint8List? pngBytes = byteData?.buffer.asUint8List();
      
      if (pngBytes != null) {
        await Gal.putImageBytes(
          pngBytes,
          name: "${fileNamePrefix}_${DateTime.now().millisecondsSinceEpoch}",
        );
        return true;
      }
      return false;
    } catch (e) {
      debugPrint("Error capturing image: $e");
      return false;
    }
  }
}
