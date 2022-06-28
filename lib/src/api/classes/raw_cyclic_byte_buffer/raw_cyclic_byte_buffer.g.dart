// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'raw_cyclic_byte_buffer.dart';

// **************************************************************************
// BorshSerializableGenerator
// **************************************************************************

mixin _$RawCyclicByteBuffer {
  int get readOffset => throw UnimplementedError();
  int get writeOffset => throw UnimplementedError();
  int get itemsCount => throw UnimplementedError();
  List<int> get buffer => throw UnimplementedError();

  Uint8List toBorsh() {
    final writer = BinaryWriter();

    const BU16().write(writer, readOffset);
    const BU16().write(writer, writeOffset);
    const BU16().write(writer, itemsCount);
    const BFixedArray(8192, BU8()).write(writer, buffer);

    return writer.toArray();
  }
}

class _RawCyclicByteBuffer extends RawCyclicByteBuffer {
  _RawCyclicByteBuffer({
    required this.readOffset,
    required this.writeOffset,
    required this.itemsCount,
    required this.buffer,
  }) : super._();

  final int readOffset;
  final int writeOffset;
  final int itemsCount;
  final List<int> buffer;
}

class BRawCyclicByteBuffer implements BType<RawCyclicByteBuffer> {
  const BRawCyclicByteBuffer();

  @override
  void write(BinaryWriter writer, RawCyclicByteBuffer value) {
    writer.writeStruct(value.toBorsh());
  }

  @override
  RawCyclicByteBuffer read(BinaryReader reader) {
    return RawCyclicByteBuffer(
      readOffset: const BU16().read(reader),
      writeOffset: const BU16().read(reader),
      itemsCount: const BU16().read(reader),
      buffer: const BFixedArray(8192, BU8()).read(reader),
    );
  }
}

RawCyclicByteBuffer _$RawCyclicByteBufferFromBorsh(Uint8List data) {
  final reader = BinaryReader(data.buffer.asByteData());

  return const BRawCyclicByteBuffer().read(reader);
}
