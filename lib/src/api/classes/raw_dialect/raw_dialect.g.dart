// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'raw_dialect.dart';

RawDialect _$RawDialectFromBorsh(Uint8List data) {
  final reader = BinaryReader(data.buffer.asByteData());

  return const BRawDialect().read(reader);
}

class BRawDialect implements BType<RawDialect> {
  const BRawDialect();

  @override
  RawDialect read(BinaryReader reader) {
    return RawDialect(
      members: const BFixedArray(2, BMember()).read(reader),
      messages: const BRawCyclicByteBuffer().read(reader),
      lastMessageTimestamp: const BU32().read(reader),
      encrypted: const BBool().read(reader),
    );
  }

  @override
  void write(BinaryWriter writer, RawDialect value) {
    writer.writeStruct(value.toBorsh());
  }
}

// **************************************************************************
// BorshSerializableGenerator
// **************************************************************************

mixin _$RawDialect {
  bool get encrypted => throw UnimplementedError();
  int get lastMessageTimestamp => throw UnimplementedError();
  List<Member> get members => throw UnimplementedError();
  RawCyclicByteBuffer get messages => throw UnimplementedError();

  Uint8List toBorsh() {
    final writer = BinaryWriter();

    const BFixedArray(2, BMember()).write(writer, members);
    const BRawCyclicByteBuffer().write(writer, messages);
    const BU32().write(writer, lastMessageTimestamp);
    const BBool().write(writer, encrypted);

    return writer.toArray();
  }
}

class _RawDialect extends RawDialect {
  @override
  final List<Member> members;

  @override
  final RawCyclicByteBuffer messages;
  @override
  final int lastMessageTimestamp;
  @override
  final bool encrypted;
  _RawDialect({
    required this.members,
    required this.messages,
    required this.lastMessageTimestamp,
    required this.encrypted,
  }) : super._();
}
