// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'member.dart';

Member _$MemberFromBorsh(Uint8List data) {
  final reader = BinaryReader(data.buffer.asByteData());

  return const BMember().read(reader);
}

class BMember implements BType<Member> {
  const BMember();

  @override
  Member read(BinaryReader reader) {
    return Member(
      publicKey: const BPublicKey().read(reader),
      scopes: const BFixedArray(2, BBool()).read(reader),
    );
  }

  @override
  void write(BinaryWriter writer, Member value) {
    writer.writeStruct(value.toBorsh());
  }
}

// **************************************************************************
// BorshSerializableGenerator
// **************************************************************************

mixin _$Member {
  Ed25519HDPublicKey get publicKey => throw UnimplementedError();
  List<bool> get scopes => throw UnimplementedError();

  Uint8List toBorsh() {
    final writer = BinaryWriter();

    const BPublicKey().write(writer, publicKey);
    const BFixedArray(2, BBool()).write(writer, scopes);

    return writer.toArray();
  }
}

class _Member extends Member {
  @override
  final Ed25519HDPublicKey publicKey;

  @override
  final List<bool> scopes;
  _Member({
    required this.publicKey,
    required this.scopes,
  }) : super._();
}
