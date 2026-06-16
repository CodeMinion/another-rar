# EC-002: Archive Find Entry

1. RarFile should have a function Future<RarArchiveEntry> findEntry({required String name})
  1.1. FindEntry should return a RarArchiveEntry if the entry is found
  1.2. FindEntry should throw a RarException if the entry is not found

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
5. Test should check that the function finds the entry hello_world.txt
6. Test should check that the function finds the entry subfolder_test/sample.txt
7. Test should throw a RarException if the entry subfolder_test/sample.txt is not found
