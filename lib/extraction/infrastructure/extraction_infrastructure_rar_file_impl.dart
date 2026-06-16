import 'dart:convert';
import 'package:universal_io/io.dart';

import '../domain/extraction_domain_rar_archive_entry.dart';
import '../domain/extraction_domain_rar_exception.dart';
import '../domain/extraction_domain_rar_file.dart';

/// Concrete infrastructure implementation of the [RarFile] interface.
///
/// This class parses the RAR5 block structure and extracts stored files
/// in a random-access manner using [RandomAccessFile]. It implements the
/// **Facade** design pattern to simplify interactions with the binary structure.
class RarFileImpl implements RarFile {
  /// The RAR archive file.
  final File _file;

  /// The list of entries parsed from the RAR archive.
  final List<RarArchiveEntry> _entries = [];

  /// Creates a new [RarFileImpl] instance.
  RarFileImpl._(this._file);

  /// Opens and parses the RAR archive at [filePath].
  ///
  /// Returns a [RarFile] containing the archive entries.
  /// Throws a [RarException] if parsing or opening fails.
  static Future<RarFileImpl> open(String filePath) async {
    return openFile(File(filePath));
  }

  /// Opens and parses the RAR archive at the specified [file].
  ///
  /// Returns a [RarFile] containing the archive entries.
  /// Throws a [RarException] if parsing or opening fails.
  static Future<RarFileImpl> openFile(File file) async {
    try {
      final rarFile = RarFileImpl._(file);
      await rarFile._parse();
      return rarFile;
    } catch (e, stackTrace) {
      // Log exceptions to the console in accordance with exception guidelines
      stderr.writeln('Error opening RAR file "${file.path}": $e\n$stackTrace');
      if (e is RarException) {
        rethrow;
      }
      throw RarException('Failed to open RAR archive: ${file.path}', e);
    }
  }

  /// Opens and parses the RAR archive at the specified [uri].
  ///
  /// Returns a [RarFile] containing the archive entries.
  /// Throws a [RarException] if parsing or opening fails.
  static Future<RarFileImpl> openUri(Uri uri) async {
    try {
      return openFile(File.fromUri(uri));
    } catch (e, stackTrace) {
      // Log exceptions to the console in accordance with exception guidelines
      stderr.writeln('Error opening RAR URI "$uri": $e\n$stackTrace');
      if (e is RarException) {
        rethrow;
      }
      throw RarException('Failed to open RAR URI: $uri', e);
    }
  }

  /// Parses the RAR archive blocks sequentially.
  Future<void> _parse() async {
    if (!await _file.exists()) {
      throw RarException('RAR file does not exist: ${_file.path}');
    }

    final raf = await _file.open(mode: FileMode.read);
    try {
      final len = await raf.length();
      if (len < 7) {
        throw RarException('File is too short to be a valid RAR archive');
      }

      // 1. Verify Signature
      await raf.setPosition(0);
      final sig = await raf.read(8);

      bool isRar5 = false;
      bool isRar4 = false;

      // Check RAR5 signature (8 bytes)
      const rar5Sig = [0x52, 0x61, 0x72, 0x21, 0x1A, 0x07, 0x01, 0x00];
      if (sig.length == 8) {
        bool matchRar5 = true;
        for (int i = 0; i < 8; i++) {
          if (sig[i] != rar5Sig[i]) {
            matchRar5 = false;
            break;
          }
        }
        if (matchRar5) {
          isRar5 = true;
        }
      }

      // Check RAR4 signature (7 bytes)
      if (!isRar5 && sig.length >= 7) {
        const rar4Sig = [0x52, 0x61, 0x72, 0x21, 0x1A, 0x07, 0x00];
        bool matchRar4 = true;
        for (int i = 0; i < 7; i++) {
          if (sig[i] != rar4Sig[i]) {
            matchRar4 = false;
            break;
          }
        }
        if (matchRar4) {
          isRar4 = true;
        }
      }

      if (isRar5) {
        await _parseRar5(raf, len);
      } else if (isRar4) {
        await _parseRar4(raf, len);
      } else {
        throw RarException('Invalid RAR signature');
      }
    } finally {
      await raf.close();
    }
  }

  /// Parses the RAR5 archive blocks.
  Future<void> _parseRar5(RandomAccessFile raf, int len) async {
    // 2. Parse Blocks Loop
    int offset = 8;
    while (offset < len) {
      if (offset + 4 > len) {
        break; // Truncated block or padding at end of file
      }
      await raf.setPosition(offset);

      // Read Header CRC32 (4 bytes)
      final crcBytes = await raf.read(4);
      if (crcBytes.length < 4) break;
      final headerCrc = (crcBytes[3] << 24) |
          (crcBytes[2] << 16) |
          (crcBytes[1] << 8) |
          crcBytes[0];

      // Read Header Size (vint)
      final headerSize = await _readVintFromFile(raf);
      final headerContentStart = await raf.position();
      final blockHeaderEnd = headerContentStart + headerSize;

      if (blockHeaderEnd > len) {
        throw RarException('Truncated block header at offset $offset');
      }

      // Read Header Content into memory
      final headerData = await raf.read(headerSize);
      if (headerData.length < headerSize) {
        throw RarException(
            'Failed to read block header content at offset $headerContentStart');
      }

      final reader = _BytesReader(headerData);
      final headerType = reader.readVint();
      final headerFlags = reader.readVint();

      int extraSize = 0;
      if ((headerFlags & 0x0001) != 0) {
        extraSize = reader.readVint();
      }

      int dataSize = 0;
      if ((headerFlags & 0x0002) != 0) {
        dataSize = reader.readVint();
      }

      if (headerType == 1) {
        // Main Archive Header
        final arcFlags = reader.readVint();
        if ((arcFlags & 0x0001) != 0) {
          reader.readVint(); // Volume number
        }
      } else if (headerType == 2) {
        // File Header
        final fileFlags = reader.readVint();
        final unpackedSize = reader.readVint();
        final attributes = reader.readVint();

        // Optional Unix-format time field (0x0002)
        if ((fileFlags & 0x0002) != 0) {
          reader.readUint32(); // mtime
        }

        // Optional CRC32 field (0x0004)
        int? fileCrc;
        if ((fileFlags & 0x0004) != 0) {
          fileCrc = reader.readUint32();
        }

        final compression = reader.readVint();
        final hostOs = reader.readVint();
        final nameLen = reader.readVint();

        final nameBytes = reader.readBytes(nameLen);
        final name = utf8.decode(nameBytes, allowMalformed: true);

        final isDirectory = (fileFlags & 0x0001) != 0;
        final dataOffset = blockHeaderEnd;

        _entries.add(
          RarArchiveEntry(
            name: name,
            size: unpackedSize,
            isDirectory: isDirectory,
            dataOffset: dataOffset,
            packedSize: dataSize,
            compressionMethod: compression,
            crc: fileCrc,
          ),
        );
      } else if (headerType == 5) {
        // End of Archive Header
        break;
      }

      // Advance offset past the block header and data area
      offset = blockHeaderEnd + dataSize;
    }
  }

  /// Parses the RAR4 archive blocks.
  Future<void> _parseRar4(RandomAccessFile raf, int len) async {
    int offset = 7; // RAR4 signature is 7 bytes
    while (offset < len) {
      if (offset + 7 > len) {
        break; // Truncated block header
      }
      await raf.setPosition(offset);

      // Read base header (7 bytes)
      final headerBytes = await raf.read(7);
      if (headerBytes.length < 7) break;

      final crc = (headerBytes[1] << 8) | headerBytes[0];
      final type = headerBytes[2];
      final flags = (headerBytes[4] << 8) | headerBytes[3];
      final size = (headerBytes[6] << 8) | headerBytes[5];

      if (size < 7) {
        throw RarException('Invalid block size $size at offset $offset');
      }

      bool hasAdd = (flags & 0x8000) != 0;
      int addSize = 0;
      if (hasAdd) {
        if (offset + 11 > len) {
          throw RarException('Truncated block header for addSize at offset $offset');
        }
        final addSizeBytes = await raf.read(4);
        addSize = (addSizeBytes[3] << 24) |
            (addSizeBytes[2] << 16) |
            (addSizeBytes[1] << 8) |
            addSizeBytes[0];
      }

      final headerSize = hasAdd ? 11 : 7;
      final bodySize = size - headerSize;

      if (offset + size > len) {
        throw RarException('Truncated block body at offset $offset');
      }

      if (type == 0x74) {
        // File Header
        final bodyBytes = await raf.read(bodySize);
        if (bodyBytes.length < bodySize) {
          throw RarException('Failed to read block body at offset $offset');
        }

        if (bodySize < 21) {
          throw RarException('File header body too short at offset $offset');
        }

        final lowUnpSize = (bodyBytes[3] << 24) |
            (bodyBytes[2] << 16) |
            (bodyBytes[1] << 8) |
            bodyBytes[0];
        final hostOs = bodyBytes[4];
        final fileCrc = (bodyBytes[8] << 24) |
            (bodyBytes[7] << 16) |
            (bodyBytes[6] << 8) |
            bodyBytes[5];
        final fileTime = (bodyBytes[12] << 24) |
            (bodyBytes[11] << 16) |
            (bodyBytes[10] << 8) |
            bodyBytes[9];
        final rarVer = bodyBytes[13];
        final method = bodyBytes[14];
        final nameSize = (bodyBytes[16] << 8) | bodyBytes[15];
        final attr = (bodyBytes[20] << 24) |
            (bodyBytes[19] << 16) |
            (bodyBytes[18] << 8) |
            bodyBytes[17];

        int highPackSize = 0;
        int highUnpSize = 0;
        int nameOffset = 21;

        if ((flags & 0x0100) != 0) {
          if (bodySize < 29) {
            throw RarException('File header body too short for 64-bit sizes at offset $offset');
          }
          highPackSize = (bodyBytes[24] << 24) |
              (bodyBytes[23] << 16) |
              (bodyBytes[22] << 8) |
              bodyBytes[21];
          highUnpSize = (bodyBytes[28] << 24) |
              (bodyBytes[27] << 16) |
              (bodyBytes[26] << 8) |
              bodyBytes[25];
          nameOffset = 29;
        }

        if (nameOffset + nameSize > bodySize) {
          throw RarException('File name extends beyond block body size at offset $offset');
        }

        final nameBytes = bodyBytes.sublist(nameOffset, nameOffset + nameSize);
        String name = '';
        if ((flags & 0x0200) != 0) {
          final nullIdx = nameBytes.indexOf(0);
          if (nullIdx != -1) {
            name = utf8.decode(nameBytes.sublist(0, nullIdx), allowMalformed: true);
          } else {
            name = utf8.decode(nameBytes, allowMalformed: true);
          }
        } else {
          name = utf8.decode(nameBytes, allowMalformed: true);
        }

        // Normalize Windows backslashes
        name = name.replaceAll('\\', '/');

        final isDirectory = (flags & 0x00E0) == 0x00E0;
        final unpackedSize = (highUnpSize << 32) | lowUnpSize;
        final packedSize = (highPackSize << 32) | addSize;

        // In RAR4, 0x30 is store (uncompressed). We normalize it to 0 for internal consistency.
        final compression = (method == 0x30) ? 0 : method;

        _entries.add(
          RarArchiveEntry(
            name: name,
            size: unpackedSize,
            isDirectory: isDirectory,
            dataOffset: offset + size,
            packedSize: packedSize,
            compressionMethod: compression,
            crc: fileCrc,
          ),
        );
      } else if (type == 0x7b) {
        // Terminator block
        break;
      }

      offset += size + addSize;
    }
  }

  /// Helper to read a variable-length integer (vint) from a file on disk.
  static Future<int> _readVintFromFile(RandomAccessFile raf) async {
    int value = 0;
    int shift = 0;
    while (true) {
      final b = await raf.readByte();
      if (b < 0) {
        throw RarException('Unexpected EOF reading vint from file');
      }
      value |= (b & 0x7f) << shift;
      if ((b & 0x80) == 0) {
        break;
      }
      shift += 7;
    }
    return value;
  }

  @override
  Future<List<RarArchiveEntry>> getArchiveEntries() async {
    return List.unmodifiable(_entries);
  }

  @override
  Future<List<int>> extractEntry({required RarArchiveEntry entry}) async {
    if (entry.isDirectory) {
      return const [];
    }

    if (entry.compressionMethod != 0) {
      final err =
          'Unsupported compression method: 0x${entry.compressionMethod.toRadixString(16)}. '
          'Only stored (uncompressed) entries are supported.';
      stderr.writeln(err);
      throw RarException(err);
    }

    try {
      final raf = await _file.open(mode: FileMode.read);
      try {
        await raf.setPosition(entry.dataOffset);
        final data = await raf.read(entry.packedSize);
        if (data.length < entry.packedSize) {
          throw RarException(
            'Truncated file data for "${entry.name}": Read ${data.length} bytes, expected ${entry.packedSize}.',
          );
        }
        return data;
      } finally {
        await raf.close();
      }
    } catch (e, stackTrace) {
      stderr.writeln(
          'Error extracting RAR entry "${entry.name}": $e\n$stackTrace');
      if (e is RarException) {
        rethrow;
      }
      throw RarException('Failed to extract RAR entry "${entry.name}"', e);
    }
  }

  @override
  Future<RarArchiveEntry> findEntry({required String name}) async {
    // Try exact match first
    for (final entry in _entries) {
      if (entry.name == name) {
        return entry;
      }
    }
    // Try relative match (suffix match on path boundary)
    for (final entry in _entries) {
      if (entry.name.endsWith('/$name')) {
        return entry;
      }
    }
    throw RarException('Archive entry not found: $name');
  }
}

/// Helper reader class to parse fields from a memory byte array.
class _BytesReader {
  final List<int> _bytes;
  int _offset = 0;

  _BytesReader(this._bytes);

  /// Reads a variable-length integer (vint).
  int readVint() {
    int value = 0;
    int shift = 0;
    while (true) {
      if (_offset >= _bytes.length) {
        throw RarException('Unexpected EOF reading vint from byte array');
      }
      final b = _bytes[_offset++];
      value |= (b & 0x7f) << shift;
      if ((b & 0x80) == 0) {
        break;
      }
      shift += 7;
    }
    return value;
  }

  /// Reads a little-endian 32-bit unsigned integer.
  int readUint32() {
    if (_offset + 4 > _bytes.length) {
      throw RarException('Unexpected EOF reading uint32 from byte array');
    }
    final b0 = _bytes[_offset++];
    final b1 = _bytes[_offset++];
    final b2 = _bytes[_offset++];
    final b3 = _bytes[_offset++];
    return (b3 << 24) | (b2 << 16) | (b1 << 8) | b0;
  }

  /// Reads [count] raw bytes from the buffer.
  List<int> readBytes(int count) {
    if (_offset + count > _bytes.length) {
      throw RarException('Unexpected EOF reading bytes from byte array');
    }
    final result = _bytes.sublist(_offset, _offset + count);
    _offset += count;
    return result;
  }
}
