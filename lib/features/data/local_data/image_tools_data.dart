import 'dart:async';
import 'dart:io';
import 'dart:math' as math;
import 'dart:typed_data';
import 'dart:ui' as ui;
import 'package:file_picker/file_picker.dart';

abstract class ImageToolsData {
  Future<Uint8List> removeBackground(
    Uint8List bytes, {
    required double pickDx, // 0..1, where the user tapped
    required double pickDy,
    required double tolerance, // 0..1
    required bool contiguous,
  });

  Future<Uint8List> resize(
    Uint8List bytes, {
    required int width,
    required int height,
    required bool keepRatio,
  });

  Future<bool> savePng(Uint8List bytes, String fileName);
}

class ImageToolsDataImpl extends ImageToolsData {
  static const _maxSide = 2048; // big images are scaled down before processing

  Future<ui.Image> _decode(Uint8List bytes) async =>
      (await (await ui.instantiateImageCodec(bytes)).getNextFrame()).image;

  Future<Uint8List> _toPng(ui.Image img) async {
    final data = await img.toByteData(format: ui.ImageByteFormat.png);
    return data!.buffer.asUint8List();
  }

  @override
  Future<Uint8List> removeBackground(
    Uint8List bytes, {
    required double pickDx,
    required double pickDy,
    required double tolerance,
    required bool contiguous,
  }) async {
    var img = await _decode(bytes);
    if (img.width > _maxSide || img.height > _maxSide) {
      final s = _maxSide / math.max(img.width, img.height);
      final codec = await ui.instantiateImageCodec(
        bytes,
        targetWidth: (img.width * s).round(),
        targetHeight: (img.height * s).round(),
      );
      img = (await codec.getNextFrame()).image;
    }
    final w = img.width, h = img.height;
    final data = await img.toByteData(format: ui.ImageByteFormat.rawRgba);
    final px = Uint8List.fromList(data!.buffer.asUint8List());

    final x0 = (pickDx * (w - 1)).round().clamp(0, w - 1);
    final y0 = (pickDy * (h - 1)).round().clamp(0, h - 1);
    final ref = (y0 * w + x0) * 4;
    final r0 = px[ref], g0 = px[ref + 1], b0 = px[ref + 2];
    final maxDist = tolerance * 441.67; // sqrt(3 * 255^2)
    final limit = maxDist * maxDist;

    bool match(int p) {
      final i = p * 4;
      if (px[i + 3] == 0) return true;
      final dr = px[i] - r0, dg = px[i + 1] - g0, db = px[i + 2] - b0;
      return dr * dr + dg * dg + db * db <= limit;
    }

    void clear(int p) {
      final i = p * 4;
      px[i] = 0;
      px[i + 1] = 0;
      px[i + 2] = 0;
      px[i + 3] = 0;
    }

    final total = w * h;
    if (contiguous) {
      final seen = Uint8List(total);
      final stack = Int32List(total);
      var sp = 0;
      final seed = y0 * w + x0;
      if (match(seed)) {
        stack[sp++] = seed;
        seen[seed] = 1;
      }
      while (sp > 0) {
        final p = stack[--sp];
        final x = p % w, y = p ~/ w;
        clear(p);
        if (x > 0 && seen[p - 1] == 0 && match(p - 1)) {
          seen[p - 1] = 1;
          stack[sp++] = p - 1;
        }
        if (x < w - 1 && seen[p + 1] == 0 && match(p + 1)) {
          seen[p + 1] = 1;
          stack[sp++] = p + 1;
        }
        if (y > 0 && seen[p - w] == 0 && match(p - w)) {
          seen[p - w] = 1;
          stack[sp++] = p - w;
        }
        if (y < h - 1 && seen[p + w] == 0 && match(p + w)) {
          seen[p + w] = 1;
          stack[sp++] = p + w;
        }
      }
    } else {
      for (var p = 0; p < total; p++) {
        if (match(p)) clear(p);
      }
    }

    final done = Completer<ui.Image>();
    ui.decodeImageFromPixels(px, w, h, ui.PixelFormat.rgba8888, done.complete);
    return _toPng(await done.future);
  }

  @override
  Future<Uint8List> resize(
    Uint8List bytes, {
    required int width,
    required int height,
    required bool keepRatio,
  }) async {
    final img = await _decode(bytes);
    final recorder = ui.PictureRecorder();
    final canvas = ui.Canvas(
        recorder, ui.Rect.fromLTWH(0, 0, width.toDouble(), height.toDouble()));

    ui.Rect dst;
    if (keepRatio) {
      final s = math.min(width / img.width, height / img.height);
      dst = ui.Rect.fromCenter(
        center: ui.Offset(width / 2, height / 2),
        width: img.width * s,
        height: img.height * s,
      );
    } else {
      dst = ui.Rect.fromLTWH(0, 0, width.toDouble(), height.toDouble());
    }
    canvas.drawImageRect(
      img,
      ui.Rect.fromLTWH(0, 0, img.width.toDouble(), img.height.toDouble()),
      dst,
      ui.Paint()
        ..filterQuality = ui.FilterQuality.high
        ..isAntiAlias = true,
    );
    return _toPng(await recorder.endRecording().toImage(width, height));
  }

  @override
  Future<bool> savePng(Uint8List bytes, String fileName) async {
    final path = await FilePicker.platform.saveFile(
      dialogTitle: 'Save image',
      fileName: fileName,
      type: FileType.custom,
      allowedExtensions: ['png'],
      bytes: bytes,
    );
    if (path == null) return false;
    if (!Platform.isAndroid && !Platform.isIOS) {
      await File(path).writeAsBytes(bytes);
    }
    return true;
  }
}
