import 'dart:io';
import 'dart:ui' as ui;
import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';
import 'package:path_provider/path_provider.dart';
import 'package:share_plus/share_plus.dart';
import '../models/bill_model.dart';

class BillImageGenerator {
  /// Captures the widget attached to the given GlobalKey as PNG bytes
  static Future<List<int>?> capturePng(GlobalKey repaintBoundaryKey, {double pixelRatio = 3.0}) async {
    try {
      final boundary = repaintBoundaryKey.currentContext?.findRenderObject() as RenderRepaintBoundary?;
      if (boundary == null) return null;

      final ui.Image image = await boundary.toImage(pixelRatio: pixelRatio);
      final byteData = await image.toByteData(format: ui.ImageByteFormat.png);
      if (byteData == null) return null;

      return byteData.buffer.asUint8List();
    } catch (e) {
      debugPrint('Error capturing PNG: $e');
      return null;
    }
  }

  /// Saves the PNG bytes to a temporary file and returns the File object
  static Future<File> savePngToTemp(List<int> bytes, BillModel bill) async {
    final tempDir = await getTemporaryDirectory();
    final sanitizedBillNo = bill.billNo.replaceAll(RegExp(r'[^\w\-]'), '_');
    final filename = 'Bill_${sanitizedBillNo}_${DateTime.now().millisecondsSinceEpoch}.png';
    final file = File('${tempDir.path}/$filename');
    await file.writeAsBytes(bytes);
    return file;
  }

  /// Shares the PNG image using system share sheet
  static Future<ShareResult> shareBillPng(File file, BillModel bill) async {
    final result = await SharePlus.instance.share(
      ShareParams(
        files: [XFile(file.path)],
        text: '${bill.companyName} - Bill #${bill.billNo} (${bill.billMonth})',
        subject: 'Bill #${bill.billNo} - ${bill.clientName}',
      ),
    );
    return result;
  }
}
