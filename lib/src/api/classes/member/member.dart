import 'package:borsh_annotation/borsh_annotation.dart';
import 'package:dialect_protocol/src/api/borsh/borsh_extensions.dart';
import 'package:solana/solana.dart';

part 'member.g.dart';

@BorshSerializable()
class Member with _$Member {
  factory Member(
      {@BPublicKey() required Ed25519HDPublicKey publicKey,
      @BFixedArray(2, BBool()) required List<bool> scopes}) = _Member;

  factory Member.fromBorsh(Uint8List data) => _$MemberFromBorsh(data);

  Member._();
}
