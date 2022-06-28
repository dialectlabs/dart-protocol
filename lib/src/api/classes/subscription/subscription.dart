import 'package:borsh_annotation/borsh_annotation.dart';
import 'package:dialect_web3/src/api/borsh/borsh_extensions.dart';
import 'package:solana/solana.dart';

part 'subscription.g.dart';

@BorshSerializable()
class Subscription with _$Subscription {
  factory Subscription(
      {@BPublicKey() required Ed25519HDPublicKey pubKey,
      @BBool() required bool enabled}) = _Subscription;

  factory Subscription.fromBorsh(Uint8List data) =>
      _$SubscriptionFromBorsh(data);

  Subscription._();
}
