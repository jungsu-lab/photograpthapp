import 'dart:typed_data';

class SelectedPhoto {
  const SelectedPhoto({
    required this.name,
    required this.bytes,
    required this.source,
  });

  final String name;
  final Uint8List bytes;
  final PhotoSource source;
}

enum PhotoSource { gallery, camera }
