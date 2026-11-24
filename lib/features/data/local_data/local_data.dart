import 'dart:io';
import 'dart:typed_data';
import 'dart:ui' as ui;
import 'package:archive/archive.dart';
import 'package:file_picker/file_picker.dart';
import '../../../core/constants/app_sizes.dart';

abstract class LocalData {
  Future<Uint8List> createDesign(
    Uint8List logoBytes, {
    double k = 0.22, // roundness of the original logo
    double radius = 0, // new corner radius applied to the logo
    bool useIconBg = true, // true -> 960 / 640, false -> 1152 / 768
    bool legacy = false, // Android 11 and below image
    bool includeCircle = false, // preview only
    ui.Color? background, // null = transparent
    ui.Color circleColor = const ui.Color(0xFF1A3F46),
  });

  String buildYaml({
    required String splashColor,
    required String iconBgColor,
    required bool useIconBg,
  });

  Future<bool> saveZip(Map<String, List<int>> files);
}

class LocalDataImpl extends LocalData {
  @override
  Future<Uint8List> createDesign(
    Uint8List logoBytes, {
    double k = 0.22,
    double radius = 0,
    bool useIconBg = true,
    bool legacy = false,
    bool includeCircle = false,
    ui.Color? background,
    ui.Color circleColor = const ui.Color(0xFF1A3F46),
  }) async {
    final size = (legacy || !useIconBg)
        ? AppSizes.canvasNoBg
        : AppSizes.canvasWithBg;
    final circleD = size * AppSizes.circleRatio;
    final center = ui.Offset(size / 2, size / 2);

    final recorder = ui.PictureRecorder();
    final canvas = ui.Canvas(recorder, ui.Rect.fromLTWH(0, 0, size, size));

    // Step 1: the design (transparent unless a color is given)
    if (background != null) {
      canvas.drawRect(
          ui.Rect.fromLTWH(0, 0, size, size), ui.Paint()..color = background);
    }

    // Step 2: the circle (guide only)
    if (includeCircle && !legacy) {
      canvas.drawCircle(
          center,
          circleD / 2,
          ui.Paint()
            ..color = circleColor
            ..isAntiAlias = true);
    }

    // Step 3: logo centered inside the circle
    final codec = await ui.instantiateImageCodec(logoBytes);
    final logo = (await codec.getNextFrame()).image;
    final kEff = k > radius ? k : radius;
    final box = legacy
        ? AppSizes.legacyLogo
        : circleD / (1.4142 - 0.8284 * kEff) * AppSizes.safeMargin;
    final r = box / (logo.width > logo.height ? logo.width : logo.height);
    final dst = ui.Rect.fromCenter(
        center: center, width: logo.width * r, height: logo.height * r);

    if (radius > 0) {
      final side = dst.width < dst.height ? dst.width : dst.height;
      canvas.save();
      canvas.clipRRect(
        ui.RRect.fromRectAndRadius(dst, ui.Radius.circular(radius * side)),
        doAntiAlias: true,
      );
    }
    canvas.drawImageRect(
      logo,
      ui.Rect.fromLTWH(0, 0, logo.width.toDouble(), logo.height.toDouble()),
      dst,
      ui.Paint()
        ..filterQuality = ui.FilterQuality.high
        ..isAntiAlias = true,
    );
    if (radius > 0) canvas.restore();

    final img =
        await recorder.endRecording().toImage(size.toInt(), size.toInt());
    final data = await img.toByteData(format: ui.ImageByteFormat.png);
    return data!.buffer.asUint8List();
  }

  @override
  String buildYaml({
    required String splashColor,
    required String iconBgColor,
    required bool useIconBg,
  }) =>
      '''
flutter_native_splash:
  color: "$splashColor"
  image: assets/splash/logo.png
  android_12:
    image: assets/splash/logo_android12.png
    color: "$splashColor"${useIconBg ? '\n    icon_background_color: "$iconBgColor"' : ''}
''';

  @override
  Future<bool> saveZip(Map<String, List<int>> files) async {
    final zip = Archive();
    files.forEach(
        (name, data) => zip.addFile(ArchiveFile(name, data.length, data)));
<<<<<<< HEAD
    final bytes = Uint8List.fromList(ZipEncoder().encode(zip)!);

    // System dialog: the user picks the folder and file name
    final path = await FilePicker.platform.saveFile(
      dialogTitle: 'Save splash assets',
      fileName: 'splash-assets.zip',
      type: FileType.custom,
      allowedExtensions: ['zip'],
      bytes: bytes, // Android and iOS write the file themselves
=======
    await FileSaver.instance.saveFile(
      name: 'splash-assets',
      bytes: Uint8List.fromList(ZipEncoder().encode(zip)!),
      ext: 'zip',
      mimeType: MimeType.zip,
>>>>>>> 619ac6b81dff9d2dbf1bf05e0dbc727d3ea47c1c
    );
    if (path == null) return false; // user cancelled

    // On desktop the dialog only returns a path, so write the file here
    if (!Platform.isAndroid && !Platform.isIOS) {
      await File(path).writeAsBytes(bytes);
    }
    return true;
  }
}
