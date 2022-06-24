import 'package:borsh_annotation/borsh_annotation.dart';

part 'raw_cyclic_byte_buffer.g.dart';

@BorshSerializable()
class RawCyclicByteBuffer with _$RawCyclicByteBuffer {
  factory RawCyclicByteBuffer(
          {@BU16() required int readOffset,
          @BU16() required int writeOffset,
          @BU16() required int itemsCount,
          @BFixedArray(8192, BU8()) required List<int> buffer}) =
      _RawCyclicByteBuffer;

  factory RawCyclicByteBuffer.fromBorsh(Uint8List data) =>
      _$RawCyclicByteBufferFromBorsh(data);

  RawCyclicByteBuffer._();
}
