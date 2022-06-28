import 'package:borsh_annotation/borsh_annotation.dart';
import 'package:dialect_web3/src/api/classes/subscription/subscription.dart';

part 'metadata.g.dart';

@BorshSerializable()
class Metadata with _$Metadata {
  factory Metadata(
      {@BArray(BSubscription())
          required List<Subscription> subscriptions}) = _Metadata;

  factory Metadata.fromBorsh(Uint8List data) => _$MetadataFromBorsh(data);

  Metadata._();
}
