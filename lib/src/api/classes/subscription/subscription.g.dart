// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'subscription.dart';

Subscription _$SubscriptionFromBorsh(Uint8List data) {
  final reader = BinaryReader(data.buffer.asByteData());

  return const BSubscription().read(reader);
}

class BSubscription implements BType<Subscription> {
  const BSubscription();

  @override
  Subscription read(BinaryReader reader) {
    return Subscription(
      pubKey: const BPublicKey().read(reader),
      enabled: const BBool().read(reader),
    );
  }

  @override
  void write(BinaryWriter writer, Subscription value) {
    writer.writeStruct(value.toBorsh());
  }
}

// **************************************************************************
// BorshSerializableGenerator
// **************************************************************************

mixin _$Subscription {
  bool get enabled => throw UnimplementedError();
  Ed25519HDPublicKey get pubKey => throw UnimplementedError();

  Uint8List toBorsh() {
    final writer = BinaryWriter();

    const BPublicKey().write(writer, pubKey);
    const BBool().write(writer, enabled);

    return writer.toArray();
  }
}

class _Subscription extends Subscription {
  @override
  final Ed25519HDPublicKey pubKey;

  @override
  final bool enabled;
  _Subscription({
    required this.pubKey,
    required this.enabled,
  }) : super._();
}
