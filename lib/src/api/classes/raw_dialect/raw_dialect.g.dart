// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'raw_dialect.dart';

// **************************************************************************
// BorshSerializableGenerator
// **************************************************************************

mixin _$RawDialect {
  List<Member> get members => throw UnimplementedError();
  RawCyclicByteBuffer get messages => throw UnimplementedError();
  int get lastMessageTimestamp => throw UnimplementedError();
  bool get encrypted => throw UnimplementedError();

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
  _RawDialect({
    required this.members,
    required this.messages,
    required this.lastMessageTimestamp,
    required this.encrypted,
  }) : super._();

  final List<Member> members;
  final RawCyclicByteBuffer messages;
  final int lastMessageTimestamp;
  final bool encrypted;
}

class BRawDialect implements BType<RawDialect> {
  const BRawDialect();

  @override
  void write(BinaryWriter writer, RawDialect value) {
    writer.writeStruct(value.toBorsh());
  }

  @override
  RawDialect read(BinaryReader reader) {
    return RawDialect(
      members: const BFixedArray(2, BMember()).read(reader),
      messages: const BRawCyclicByteBuffer().read(reader),
      lastMessageTimestamp: const BU32().read(reader),
      encrypted: const BBool().read(reader),
    );
  }
}

RawDialect _$RawDialectFromBorsh(Uint8List data) {
  final reader = BinaryReader(data.buffer.asByteData());

  return const BRawDialect().read(reader);
}
