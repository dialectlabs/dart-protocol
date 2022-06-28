import 'package:pinenacl/ed25519.dart';

const ITEM_METADATA_OVERHEAD = 2;

class BufferItem {
  int offset;
  Uint8List buffer;
  BufferItem(this.offset, this.buffer);
}

class CyclicByteBuffer {
  int readOffset;
  int writeOffset;
  int itemsCount;
  final Uint8List _buffer;

  CyclicByteBuffer(
      this.readOffset, this.writeOffset, this.itemsCount, Uint8List buffer)
      : _buffer = buffer;

  Uint8List get raw => _buffer;

  append(Uint8List item) {
    final metadata = uint16ToBytes(item.length);
    final itemWithMetadata = Uint8List.fromList([...metadata, ...item]);
    final newWriteOffset = _mod(writeOffset + itemWithMetadata.length);
    while (_noSpaceAvailableFor(itemWithMetadata)) {
      _eraseOldestItem();
    }
    _writeNewItem(itemWithMetadata, newWriteOffset);
  }

  List<BufferItem> items() {
    var itemsRead = 0;
    List<BufferItem> acc = [];
    while (_canRead(itemsRead)) {
      final itemSize =
          uint16FromBytes(_read(ITEM_METADATA_OVERHEAD, readOffset));
      final item = _read(itemSize, _mod(readOffset + ITEM_METADATA_OVERHEAD));
      acc.add(BufferItem(readOffset, item));
      readOffset = _mod(readOffset + ITEM_METADATA_OVERHEAD + itemSize);
      itemsRead++;
    }
    return acc;
  }

  int uint16FromBytes(Uint8List bytes) {
    return (bytes[0] << 8) | bytes[1];
  }

  Uint8List uint16ToBytes(int value) {
    return Uint8List.fromList([(value & 0xff00) >>> 8, value & 0xff00]);
  }

  bool _canRead(int readCount) {
    return readCount < itemsCount;
  }

  _eraseOldestItem() {
    final itemSize = ITEM_METADATA_OVERHEAD + _readItemSize();
    _write(_zeros(itemSize), readOffset);
    readOffset = _mod(readOffset + itemSize);
    itemsCount--;
  }

  int _getAvailableSpace() {
    if (itemsCount == 0) {
      return _buffer.length;
    }
    return _mod(readOffset - writeOffset + _buffer.length);
  }

  int _mod(int n) {
    return n % _buffer.length;
  }

  _noSpaceAvailableFor(Uint8List item) {
    return _getAvailableSpace() < item.length;
  }

  Uint8List _read(int size, int offset) {
    final tailSize = _buffer.length - offset;
    if (tailSize >= size) {
      return _buffer.sublist(offset, offset + size);
    }
    final tail = _buffer.sublist(offset, _buffer.length);
    final head = _buffer.sublist(0, size - tail.length);
    return Uint8List.fromList([...tail, ...head]);
  }

  int _readItemSize() {
    final tailSize = _buffer.length - readOffset;
    if (tailSize >= ITEM_METADATA_OVERHEAD) {
      return uint16FromBytes(
          Uint8List.fromList([_buffer[readOffset], _buffer[readOffset + 1]]));
    }
    return uint16FromBytes(
        Uint8List.fromList([_buffer[readOffset], _buffer[0]]));
  }

  _write(Uint8List data, int offset) {
    data.asMap().forEach((index, value) {
      final pos = _mod(offset + index);
      _buffer[pos] = value;
    });
  }

  _writeNewItem(Uint8List itemWithMetadata, int newWriteoOffset) {
    _write(itemWithMetadata, writeOffset);
    writeOffset = newWriteoOffset;
    itemsCount++;
  }

  Uint8List _zeros(int oldestItemSize) {
    return Uint8List(oldestItemSize);
  }

  static CyclicByteBuffer empty(int size) {
    return CyclicByteBuffer(0, 0, 0, Uint8List(size));
  }
}
