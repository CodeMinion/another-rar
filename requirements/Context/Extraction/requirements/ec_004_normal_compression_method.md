# EC-004: 0x33 Normal Compression Method Support 

1. Archive entries compressed with Normal (0x33) compression method shall be extracted successfully.
2. This should be supported only for RAR4.

# Important
This must be performed natively using Dart no external libraries.

## RAR4 Compression Methods:

| Method Code (Hex) | Method Name | Description |
|---|---|---|
| 0x30 | Store | No compression |
| 0x31 | Fastest | Fastest compression (lowest ratio) |
| 0x32 | Fast | Fast compression |
| 0x33 | Normal | Normal compression |
| 0x34 | Good | Good compression |
| 0x35 | Best | Best compression (highest ratio) |