# EC-001: Archive Entities

1. Create a class called RarFile which contains the following two functions:
    - Future<List<RarArchiveEntry>> getArchiveEntries(): Returns a list of all entries in the RAR archive.
    - Future<List<int>> extractEntry(RarArchiveEntry entry): Extracts the content of the specified entry from the RAR archive.
2. Create a class called RarArchiveEntry which contains the following properties:
    - name: The name of the entry.
    - size: The size of the entry.
    - isDirectory: Whether the entry is a directory.
3. Create a root class RarArchiveReader with the following functions:
    - static Future<RarFile> open(String filePath): Opens the RAR archive at the specified file path.

## Important
1. Because this package is intended to run on multiple platforms, we will not use Dart FFI to implement the extraction of the RAR archive. Instead, we will use a pure Dart implementation of the RAR extraction algorithm.

2. Because this package will be used in mobile devices with small memory it must use a streaming approach to extract the content of the entries. It must not unrar the entire file in memory.


# Test Case
1. A test case will need to open [Test RAR](../../../../test/SampleRar.rar).
2. The expected structure is:
```
SampleRar
├── hello_world.txt
└── subfolder_test
    └── sample.txt

```
3. The content of hello_world.txt is "Hello World"
4. The content of subfolder_test/sample.txt is "Sample Text"
