import 'dart:convert';
import 'package:another_rar/rar_reader.dart';
import 'package:test/test.dart';
import 'package:universal_io/io.dart';

void main() {
  group('RAR Archive Extraction tests', () {
    const testRarPath = 'test/SampleRar.rar';

    test('should open a valid RAR5 archive successfully', () async {
      final rarFile = await RarArchiveReader.open(testRarPath);
      expect(rarFile, isNotNull);
      expect(rarFile, isA<RarFile>());
    });

    test('should retrieve entries with correct attributes', () async {
      final rarFile = await RarArchiveReader.open(testRarPath);
      final entries = await rarFile.getArchiveEntries();

      expect(entries, isNotEmpty);
      expect(entries.length, equals(3));

      final helloEntry =
          entries.firstWhere((e) => e.name == 'SampleRar/hello_world.txt');
      expect(helloEntry.size, equals(20));
      expect(helloEntry.isDirectory, isFalse);

      final sampleEntry = entries
          .firstWhere((e) => e.name == 'SampleRar/subfolder_test/sample.txt');
      expect(sampleEntry.size, equals(19));
      expect(sampleEntry.isDirectory, isFalse);

      final subfolderEntry =
          entries.firstWhere((e) => e.name == 'SampleRar/subfolder_test');
      expect(subfolderEntry.isDirectory, isTrue);
    });

    test(
        'should extract entry content correctly in raw bytes and string format',
        () async {
      final rarFile = await RarArchiveReader.open(testRarPath);
      final entries = await rarFile.getArchiveEntries();

      for (final entryTest in entries) {
        print("Entries in archive: ${entryTest.name}");
      }

      // Extract hello_world.txt
      final helloEntry =
          entries.firstWhere((e) => e.name == 'SampleRar/hello_world.txt');
      final helloBytes = await rarFile.extractEntry(entry: helloEntry);
      expect(helloBytes, isNotEmpty);
      expect(helloBytes.length, equals(20));
      final helloText = utf8.decode(helloBytes);
      expect(helloText, equals('Hello world sample.\n'));

      // Extract subfolder_test/sample.txt
      final sampleEntry = entries
          .firstWhere((e) => e.name == 'SampleRar/subfolder_test/sample.txt');
      final sampleBytes = await rarFile.extractEntry(entry: sampleEntry);
      expect(sampleBytes, isNotEmpty);
      expect(sampleBytes.length, equals(19));
      final sampleText = utf8.decode(sampleBytes);
      expect(sampleText, equals('Sample inner file.\n'));
    });

    group('findEntry tests', () {
      test('should find an entry by name successfully (exact and relative)',
          () async {
        final rarFile = await RarArchiveReader.open(testRarPath);

        // Test finds exact name
        final helloEntryExact =
            await rarFile.findEntry(name: 'SampleRar/hello_world.txt');
        expect(helloEntryExact.name, equals('SampleRar/hello_world.txt'));
        expect(helloEntryExact.size, equals(20));

        // Test finds relative name (as specified in EC-002)
        final helloEntryRelative =
            await rarFile.findEntry(name: 'hello_world.txt');
        expect(helloEntryRelative.name, equals('SampleRar/hello_world.txt'));

        final sampleEntryRelative =
            await rarFile.findEntry(name: 'subfolder_test/sample.txt');
        expect(sampleEntryRelative.name,
            equals('SampleRar/subfolder_test/sample.txt'));
        expect(sampleEntryRelative.size, equals(19));
      });

      test('should throw RarException when entry is not found', () async {
        final rarFile = await RarArchiveReader.open(testRarPath);
        expect(
          () => rarFile.findEntry(name: 'non_existent.txt'),
          throwsA(isA<RarException>()),
        );
      });
    });

    test('should throw RarException when opening a non-existent file',
        () async {
      expect(
        () => RarArchiveReader.open('test/does_not_exist.rar'),
        throwsA(isA<RarException>()),
      );
    });

    test('should throw RarException when file signature is invalid', () async {
      // Using this script or pubspec.yaml itself as an invalid RAR archive
      expect(
        () => RarArchiveReader.open('pubspec.yaml'),
        throwsA(isA<RarException>()),
      );
    });

    group('universal_io support tests', () {
      test('should open and read archive using openFile', () async {
        final file = File(testRarPath);
        final rarFile = await RarArchiveReader.openFile(file: file);
        expect(rarFile, isNotNull);

        final entries = await rarFile.getArchiveEntries();
        expect(entries, isNotEmpty);

        final helloEntry =
            entries.firstWhere((e) => e.name == 'SampleRar/hello_world.txt');
        expect(helloEntry.size, equals(20));
      });

      test('should open and read archive using openUri', () async {
        final uri = Uri.file(testRarPath);
        final rarFile = await RarArchiveReader.openUri(uri: uri);
        expect(rarFile, isNotNull);

        final entries = await rarFile.getArchiveEntries();
        expect(entries, isNotEmpty);

        final helloEntry =
            entries.firstWhere((e) => e.name == 'SampleRar/hello_world.txt');
        expect(helloEntry.size, equals(20));
      });

      test('openFile should throw RarException when file does not exist',
          () async {
        final file = File('test/does_not_exist.rar');
        expect(
          () => RarArchiveReader.openFile(file: file),
          throwsA(isA<RarException>()),
        );
      });

      test('openUri should throw RarException when file does not exist',
          () async {
        final uri = Uri.file('test/does_not_exist.rar');
        expect(
          () => RarArchiveReader.openUri(uri: uri),
          throwsA(isA<RarException>()),
        );
      });
    });
  });
}
