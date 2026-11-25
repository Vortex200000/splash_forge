import 'package:equatable/equatable.dart';

class SavedDesign extends Equatable {
  final String id; // folder name of the design
  final String name;
  final DateTime createdAt;
  final String path;
  final List<String> files; // absolute paths
  final Map<String, dynamic> config;

  const SavedDesign({
    required this.id,
    required this.name,
    required this.createdAt,
    required this.path,
    required this.files,
    required this.config,
  });

  /// Image shown in the list
  String? get thumbnail {
    for (final f in files) {
      if (f.contains('android12') && f.endsWith('.png') && !f.contains('dark')) {
        return f;
      }
    }
    for (final f in files) {
      if (f.endsWith('.png')) return f;
    }
    return null;
  }

  @override
  List<Object?> get props => [id, name, createdAt, path, files];
}
