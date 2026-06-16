# EC-003: Archive Universal IO Support

1. Update root class RarArchiveReader to support universal_io with the following functions:
    - static Future<RarFile> openFile({required File file}): Opens the RAR archive at the specified universal_io File.
    - static Future<RarFile> openUri({required Uri uri}): Opens the RAR archive at the specified universal_io Uri.
2. Update any code using dart:io file io classes to use universal_io instead.

## Important
1. Use the universal_io package for file operations instead of the native dart:io package.