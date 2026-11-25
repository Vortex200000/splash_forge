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
    required String splashColorDark,
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
    required String splashColorDark,
    required bool useIconBg,
  }) =>
      '''
flutter_native_splash:
  # This package generates native code to customize Flutter's default white native splash screen
  # with background color and splash image.
  # Steps to make this work:
  # 1. Customize the parameters below.
  # 2. run the following command in the terminal:
  # dart run flutter_native_splash:create
  # or if you place this not in pubspec.yaml and not in flutter_native_splash.yaml:
  # dart run flutter_native_splash:create -p ../your-filepath.yaml
  # 3. voila, done!

  # NOTES:
  # - in case you got some trouble, cleaning up flutter project might help:
  # flutter clean ; flutter pub get
  # - To restore Flutter's default white splash screen, run the following command in the terminal:
  # dart run flutter_native_splash:remove
  # or if you place this not in pubspec.yaml and not in flutter_native_splash.yaml:
  # dart run flutter_native_splash:remove -p ../your-filepath.yaml

  # IMPORTANT NOTE: These parameter do not affect the configuration of Android 12 and later, which
  # handle splash screens differently that prior versions of Android.  Android 12 and later must be
  # configured specifically in the android_12 section below, at the very end.

  #======================================================================

  # uncomment this if you want to disable this package for specific platform:
  # android: false
  # ios: false
  # web: false

  #======================================================================

  #! FOR ALL PLATFORM, except Android 12+:

  # general color for all platform (except android 12+):
  # see there only 2 lines in all parameters that marked as [required], so others
  # remain optional. NOTE that if you specify the [required] color, then you cant
  # use the [required] background_image in the next section. the reverse is true.
  # select one, they cant work together.
  color: "$splashColor"  ##====================================[REQUIRED]==========
  color_dark: "$splashColorDark"
  # platform-specific color. will override general color if active:
  #color_android: "#42a5f5"
  #color_dark_android: "#042a49"
  #color_ios: "#42a5f5"
  #color_dark_ios: "#042a49"
  #color_web: "#42a5f5"
  #color_dark_web: "#042a49"

  # general background_image for all platform (except android 12+)
  # if you specify this [required] background_image, then you should comment the
  # [required] color in previous section. select one, they cant work together.
  #background_image:      "assets/background.png" #========[REQUIRED]============
  #background_image_dark: "assets/dark-background.png"
  # platform-specific background_image. will override general background_image if active:
  #background_image_android:      "assets/background-android.png"
  #background_image_dark_android: "assets/dark-background-android.png"
  #background_image_ios:          "assets/background-ios.png"
  #background_image_dark_ios:     "assets/dark-background-ios.png"
  #background_image_web:          "assets/background-web.png"
  #background_image_dark_web:     "assets/dark-background-web.png"

  # general image for all platform (except android 12+):
  # allows you to specify an image used in the splash screen. It must be a
  # png file and should be sized for 4x pixel density.
  image:                assets/splash/logo.png
  #image_dark:          assets/splash-invert.png
  # platform-specific image. will override general image if active:
  #image_android:       assets/splash-android.png
  #image_dark_android:  assets/splash-invert-android.png
  #image_ios:           assets/splash-ios.png
  #image_dark_ios:      assets/splash-invert-ios.png
  #image_web:           assets/splash-web.gif
  #image_dark_web:      assets/splash-invert-web.gif

  # image alignment (default center if not specified, or speccified something else):
  #android_gravity: center       # bottom, center, center_horizontal, center_vertical,
  # clip_horizontal, clip_vertical, end, fill, fill_horizontal, fill_vertical, left, right, start, top. could also be a combination like `android_gravity: fill|clip_vertical`
  # This will fill the width while maintaining the image's vertical aspect ratio.
  # visit https://developer.android.com/reference/android/view/Gravity
  #ios_content_mode: center      # scaleToFill, scaleAspectFit, scaleAspectFill,
  # center, top, bottom, left, right, topLeft, topRight, bottomLeft, or bottomRight.
  # visit https://developer.apple.com/documentation/uikit/uiview/contentmode
  #web_image_mode: center        # center, contain, stretch, cover

  # general branding for all platform (except android 12+):
  # allows you to specify an image used as branding in the splash screen. should be png.
  #branding:      assets/dart.png
  #branding_dark: assets/dart_dark.png
  # platform-specific branding. will override general branding if active:
  #branding_android:      assets/brand-android.png
  #branding_dark_android: assets/dart_dark-android.png
  #branding_ios:          assets/brand-ios.png
  #branding_dark_ios:     assets/dart_dark-ios.png
  #branding_web:          assets/brand-web.gif
  #branding_dark_web:     assets/dart_dark-web.gif

  # branding position:
  # you can use bottom, bottomRight, and bottomLeft. The default values is
  # bottom if not specified or specified something else.
  #branding_mode: bottom                # default bottom
  #branding_bottom_padding: 24          # default 0
  #branding_bottom_padding_android: 24  # default 0
  #branding_bottom_padding_ios: 24      # default 0
  # branding bottom padding web is not available yet.

  # The screen orientation can be set in Android with the android_screen_orientation parameter.
  # Valid parameters can be found here:
  # https://developer.android.com/guide/topics/manifest/activity-element#screen
  #android_screen_orientation: sensorLandscape

  # By specifying the used minimum SDK version of Android, flutter_native_splash might be able to
  # merge/remove certain styles and drawables.
  #android_min_sdk: 24  # default 16

  # hide notif bar on android. ios already hides it by default.
  # Has no effect in web since web has no notification bar.
  fullscreen: true                # default false
  # if you dont want to hide notif bar, for android just set this to false,
  # but for ios, add this to your flutter main():
  # WidgetsFlutterBinding.ensureInitialized();
  # SystemChrome.setEnabledSystemUIMode(SystemUiMode.manual, overlays: [SystemUiOverlay.bottom, SystemUiOverlay.top], );

  #! extra note for IOS:
  # If you have changed the name(s) of your info.plist file(s), you can specify the filename(s)
  # with the info_plist_files parameter.  Remove only the # characters in the three lines below,
  # do not remove any spaces:
  #info_plist_files:
  #  - 'ios/Runner/Info-Debug.plist'
  #  - 'ios/Runner/Info-Release.plist'

  #========================================================================

  # what we did above won't affect Android 12 and newer at all. they have different
  # handling concept. visit https://developer.android.com/guide/topics/ui/splash-screen

  #! ANDROID 12+ configuration:
  android_12:
    # background color
    color: "$splashColor"
    color_dark: "$splashColorDark"

    # center-logo
    # If this parameter is not specified, the app's launcher icon will be used instead.
    # Please note that the splash screen will be clipped to a circle on the center of the screen.
    # with background: 960×960 px (fit within circle 640px in diameter)
    # without background: 1152×1152 px (fit within circle 768px in diameter)
    # ensure that the most important design elements of your image are placed within a circular area
    image: assets/splash/logo_android12.png
    # image_dark: assets/images/logo/logo-splash2.png

    # center-logo background color
    ${useIconBg ? 'icon_background_color: "$iconBgColor"' : '# icon_background_color: "#111111"'}
    # icon_background_color_dark: "#eeeeee"

    # branding:
    # The branding image dimensions must be 800x320 px.
    #branding:      assets/dart.png
    #branding_dark: assets/dart_dark.png
''';

  @override
  Future<bool> saveZip(Map<String, List<int>> files) async {
    final zip = Archive();
    files.forEach(
        (name, data) => zip.addFile(ArchiveFile(name, data.length, data)));
    final bytes = Uint8List.fromList(ZipEncoder().encode(zip)!);

    // System dialog: the user picks the folder and file name
    final path = await FilePicker.platform.saveFile(
      dialogTitle: 'Save splash assets',
      fileName: 'splash-assets.zip',
      type: FileType.custom,
      allowedExtensions: ['zip'],
      bytes: bytes, // Android and iOS write the file themselves
    );
    if (path == null) return false; // user cancelled

    // On desktop the dialog only returns a path, so write the file here
    if (!Platform.isAndroid && !Platform.isIOS) {
      await File(path).writeAsBytes(bytes);
    }
    return true;
  }
}