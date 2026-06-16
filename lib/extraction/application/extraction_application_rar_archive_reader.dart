import 'package:universal_io/io.dart';

import '../domain/extraction_domain_rar_file.dart';
import '../infrastructure/extraction_infrastructure_rar_file_impl.dart';

/// The entry-point class for accessing RAR archives.
///
/// This class implements the **Factory Method** design pattern, providing static
/// methods to open a RAR archive and return a [RarFile] instance.
class RarArchiveReader {
  /// Opens the RAR archive at the specified [filePath].
  ///
  /// Returns a [RarFile] instance that can be used to read and extract files.
  /// Throws a [RarException] if the file cannot be opened, has an invalid signature,
  /// or fails header parsing.
  static Future<RarFile> open(String filePath) {
    return RarFileImpl.open(filePath);
  }

  /// Opens the RAR archive from the specified universal_io [file].
  ///
  /// This method implements the **Factory Method** design pattern.
  ///
  /// Returns a [RarFile] instance that can be used to read and extract files.
  /// Throws a [RarException] if the file cannot be opened, has an invalid signature,
  /// or fails header parsing.
  static Future<RarFile> openFile({required File file}) {
    return RarFileImpl.openFile(file);
  }

  /// Opens the RAR archive from the specified universal_io [uri].
  ///
  /// This method implements the **Factory Method** design pattern.
  ///
  /// Returns a [RarFile] instance that can be used to read and extract files.
  /// Throws a [RarException] if the URI cannot be opened, has an invalid signature,
  /// or fails header parsing.
  static Future<RarFile> openUri({required Uri uri}) {
    return RarFileImpl.openUri(uri);
  }
}
