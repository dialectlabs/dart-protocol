import 'package:borsh_annotation/borsh_annotation.dart';
import 'package:dialect_web3/src/api/borsh/borsh_extensions.dart';

import '../classes.dart';

part 'raw_dialect.g.dart';

@BorshSerializable()
class RawDialect with _$RawDialect {
  factory RawDialect({
    @BFixedArray(2, BMember()) required List<Member> members,
    @BRawCyclicByteBuffer() required RawCyclicByteBuffer messages,
    @BU32() required int lastMessageTimestamp,
    @BBool() required bool encrypted,
  }) = _RawDialect;

  factory RawDialect.fromBorsh(Uint8List data) => _$RawDialectFromBorsh(data);

  RawDialect._();
}
