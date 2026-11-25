/// Keeps letters (any language), numbers, space, - and _ so the name is safe
/// to use as a folder name.
String sanitizeName(String input) => input
    .replaceAll(RegExp(r'[^\p{L}\p{N} _\-]', unicode: true), '')
    .replaceAll(RegExp(r'\s+'), ' ')
    .trim();
