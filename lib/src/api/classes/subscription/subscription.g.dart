// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'subscription.dart';

// **************************************************************************
// BorshSerializableGenerator
// **************************************************************************

mixin _$Subscription {
  Ed25519HDPublicKey get pubKey => throw UnimplementedError();
  bool get enabled => throw UnimplementedError();

  Uint8List toBorsh() {
    final writer = BinaryWriter();

    const BPublicKey().write(writer, pubKey);
    const BBool().write(writer, enabled);

    return writer.toArray();
  }
}

class _Subscription extends Subscription {
  _Subscription({
    required this.pubKey,
    required this.enabled,
  }) : super._();

  final Ed25519HDPublicKey pubKey;
  final bool enabled;
}

class BSubscription implements BType<Subscription> {
  const BSubscription();

  @override
  void write(BinaryWriter writer, Subscription value) {
    writer.writeStruct(value.toBorsh());
  }

  @override
  Subscription read(BinaryReader reader) {
    return Subscription(
      pubKey: const BPublicKey().read(reader),
      enabled: const BBool().read(reader),
    );
  }
}

Subscription _$SubscriptionFromBorsh(Uint8List data) {
  final reader = BinaryReader(data.buffer.asByteData());

  return const BSubscription().read(reader);
}
