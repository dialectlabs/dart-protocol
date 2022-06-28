// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'metadata.dart';

Metadata _$MetadataFromBorsh(Uint8List data) {
  final reader = BinaryReader(data.buffer.asByteData());

  return const BMetadata().read(reader);
}

class BMetadata implements BType<Metadata> {
  const BMetadata();

  @override
  Metadata read(BinaryReader reader) {
    return Metadata(
      subscriptions: const BArray(BSubscription()).read(reader),
    );
  }

  @override
  void write(BinaryWriter writer, Metadata value) {
    writer.writeStruct(value.toBorsh());
  }
}

// **************************************************************************
// BorshSerializableGenerator
// **************************************************************************

mixin _$Metadata {
  List<Subscription> get subscriptions => throw UnimplementedError();

  Uint8List toBorsh() {
    final writer = BinaryWriter();

    const BArray(BSubscription()).write(writer, subscriptions);

    return writer.toArray();
  }
}

class _Metadata extends Metadata {
  @override
  final List<Subscription> subscriptions;

  _Metadata({
    required this.subscriptions,
  }) : super._();
}
