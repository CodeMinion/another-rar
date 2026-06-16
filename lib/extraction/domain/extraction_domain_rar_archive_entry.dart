/// Represents a file or directory entry inside a RAR archive.
///
/// This class acts as a domain entity used in the [RarFile] facade pattern
/// interface to represent individual archive entities.
class RarArchiveEntry {
  /// The name (relative path) of the entry in the archive.
  final String name;

  /// The unpacked size of the entry in bytes.
  final int size;

  /// Whether this entry represents a directory.
  final bool isDirectory;

  /// The offset in the RAR archive file where the file data begins.
  final int dataOffset;

  /// The compressed (packed) size of the entry in bytes.
  final int packedSize;

  /// The compression method/algorithm used for this entry.
  final int compressionMethod;

  /// The CRC32 checksum of the unpacked file data.
  final int? crc;

  /// Creates a new [RarArchiveEntry].
  RarArchiveEntry({
    required this.name,
    required this.size,
    required this.isDirectory,
    required this.dataOffset,
    required this.packedSize,
    required this.compressionMethod,
    this.crc,
  });

  @override
  String toString() {
    return 'RarArchiveEntry(name: $name, size: $size, isDirectory: $isDirectory)';
  }
}
