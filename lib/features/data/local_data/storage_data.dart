import 'dart:convert';
import 'dart:io';
import 'package:path_provider/path_provider.dart';
import '../../domain/entities/app_settings.dart';
import '../../domain/entities/saved_design.dart';

abstract class StorageData {
  Future<AppSettings> getSettings();
  Future<void> saveSettings(AppSettings settings);
  Future<SavedDesign> saveDesign({
    required String name,
    required Map<String, List<int>> files,
    required Map<String, dynamic> config,
  });
  Future<List<SavedDesign>> listDesigns();
  Future<void> deleteDesign(String id);
}

class StorageDataImpl extends StorageData {
  Future<String> _root() async => (await getApplicationDocumentsDirectory()).path;

  Future<File> _settingsFile() async => File('${await _root()}/settings.json');

  Map<String, dynamic> _toJson(AppSettings s) => {
        'folderName': s.folderName,
        'autoSave': s.autoSave,
        'themeMode': s.themeMode.name,
        'previewMode': s.previewMode.name,
        'splashColor': s.splashColor,
        'splashColorDark': s.splashColorDark,
        'iconBgColor': s.iconBgColor,
        'k': s.k,
        'radius': s.radius,
      };

  AppSettings _fromJson(Map<String, dynamic> j) {
    const d = AppSettings();
    return AppSettings(
      folderName: j['folderName'] as String? ?? d.folderName,
      autoSave: j['autoSave'] as bool? ?? d.autoSave,
      themeMode: AppThemeMode.values.firstWhere(
        (m) => m.name == j['themeMode'],
        orElse: () => d.themeMode,
      ),
      previewMode: PreviewMode.values.firstWhere(
        (m) => m.name == j['previewMode'],
        orElse: () => d.previewMode,
      ),
      splashColor: (j['splashColor'] as num?)?.toInt() ?? d.splashColor,
      splashColorDark: (j['splashColorDark'] as num?)?.toInt() ?? d.splashColorDark,
      iconBgColor: (j['iconBgColor'] as num?)?.toInt() ?? d.iconBgColor,
      k: (j['k'] as num?)?.toDouble() ?? d.k,
      radius: (j['radius'] as num?)?.toDouble() ?? d.radius,
    );
  }

  @override
  Future<AppSettings> getSettings() async {
    final f = await _settingsFile();
    if (!await f.exists()) return const AppSettings();
    return _fromJson(jsonDecode(await f.readAsString()) as Map<String, dynamic>);
  }

  @override
  Future<void> saveSettings(AppSettings settings) async {
    final old = (await getSettings()).folderName;
    final root = await _root();
    final oldDir = Directory('$root/$old');
    final newDir = Directory('$root/${settings.folderName}');
    // keep the existing designs when the folder is renamed
    if (old != settings.folderName &&
        await oldDir.exists() &&
        !await newDir.exists()) {
      await oldDir.rename(newDir.path);
    }
    await (await _settingsFile()).writeAsString(jsonEncode(_toJson(settings)));
  }

  Future<Directory> _folder() async {
    final name = (await getSettings()).folderName;
    final dir = Directory('${await _root()}/$name');
    if (!await dir.exists()) await dir.create(recursive: true);
    return dir;
  }

  @override
  Future<SavedDesign> saveDesign({
    required String name,
    required Map<String, List<int>> files,
    required Map<String, dynamic> config,
  }) async {
    final folder = await _folder();
    final now = DateTime.now();
    final dir = Directory('${folder.path}/${now.millisecondsSinceEpoch}');
    await dir.create(recursive: true);

    for (final e in files.entries) {
      final file = File('${dir.path}/${e.key}');
      await file.parent.create(recursive: true);
      await file.writeAsBytes(e.value);
    }
    await File('${dir.path}/design.json').writeAsString(jsonEncode({
      'name': name,
      'createdAt': now.toIso8601String(),
      'config': config,
    }));
    return _read(dir);
  }

  Future<SavedDesign> _read(Directory dir) async {
    final json = jsonDecode(await File('${dir.path}/design.json').readAsString())
        as Map<String, dynamic>;
    final files = <String>[];
    await for (final e in dir.list(recursive: true)) {
      if (e is File && !e.path.endsWith('design.json')) files.add(e.path);
    }
    return SavedDesign(
      id: dir.path.split(Platform.pathSeparator).last,
      name: json['name'] as String,
      createdAt: DateTime.parse(json['createdAt'] as String),
      path: dir.path,
      files: files,
      config: (json['config'] as Map?)?.cast<String, dynamic>() ?? {},
    );
  }

  @override
  Future<List<SavedDesign>> listDesigns() async {
    final folder = await _folder();
    final list = <SavedDesign>[];
    await for (final e in folder.list()) {
      if (e is Directory && await File('${e.path}/design.json').exists()) {
        list.add(await _read(e));
      }
    }
    list.sort((a, b) => b.createdAt.compareTo(a.createdAt));
    return list;
  }

  @override
  Future<void> deleteDesign(String id) async {
    final dir = Directory('${(await _folder()).path}/$id');
    if (await dir.exists()) await dir.delete(recursive: true);
  }
}
