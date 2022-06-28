// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'metadata.dart';

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
  _Metadata({
    required this.subscriptions,
  }) : super._();

  final List<Subscription> subscriptions;
}

class BMetadata implements BType<Metadata> {
  const BMetadata();

  @override
  void write(BinaryWriter writer, Metadata value) {
    writer.writeStruct(value.toBorsh());
  }

  @override
  Metadata read(BinaryReader reader) {
    return Metadata(
      subscriptions: const BArray(BSubscription()).read(reader),
    );
  }
}

Metadata _$MetadataFromBorsh(Uint8List data) {
  final reader = BinaryReader(data.buffer.asByteData());

  return const BMetadata().read(reader);
}
