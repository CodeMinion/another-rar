import 'extraction_domain_rar_archive_entry.dart';

/// An abstract interface representing a opened RAR archive file.
///
/// This interface implements the **Facade** design pattern, providing a simplified
/// and unified interface for retrieving entries and extracting file content
/// without exposing the caller to the complex low-level RAR5 block structure and
/// binary parsing details.
abstract class RarFile {
  /// Returns a list of all entries present in the RAR archive.
  Future<List<RarArchiveEntry>> getArchiveEntries();

  /// Extracts the content of the specified [entry] from the RAR archive.
  ///
  /// Returns a list of bytes representing the unpacked content of the entry.
  /// Throws a [RarException] if the extraction fails or the entry is compressed
  /// using an unsupported compression method.
  Future<List<int>> extractEntry({required RarArchiveEntry entry});

  /// Finds an archive entry by its exact name.
  ///
  /// Returns a [RarArchiveEntry] if the entry is found.
  /// Throws a [RarException] if no entry matches the specified [name].
  Future<RarArchiveEntry> findEntry({required String name});
}
