import 'package:borsh_annotation/borsh_annotation.dart';
import 'package:crypto/crypto.dart';
import 'package:recase/recase.dart';
import 'package:solana/dto.dart';
import 'package:solana/solana.dart';

const ACCOUNT_DISCRIMINATOR_SIZE = 8;

Uint8List accountDiscriminator(String name) {
  final camelCaseName = ReCase(name).camelCase;
  final str =
      sha256.convert(Uint8List.fromList("account:$camelCaseName".codeUnits));
  return Uint8List.fromList(str.bytes.sublist(0, ACCOUNT_DISCRIMINATOR_SIZE));
}

Future<T> fetchAccount<T>(RpcClient client, Ed25519HDPublicKey publicKey,
    T Function(Uint8List) convert,
    {int skip = 8, Encoding encoding = Encoding.base64}) async {
  final account =
      await client.getAccountInfo(publicKey.toBase58(), encoding: encoding);
  if (account == null) {
    throw AccountNotFoundException();
  }
  return parseBytesFromAccount(account, convert);
}

T parseBytesFromAccount<T>(Account account, T Function(Uint8List) convert,
    {int skip = 8}) {
  final accountData = (account.data as BinaryAccountData).data;
  final data = Uint8List.fromList(accountData);
  return convert(data.sublist(skip));
}

class AccountNotFoundException implements Exception {
  final String type;
  final String title;
  final String? message;

  AccountNotFoundException()
      : type = "AccountNotFoundException",
        title = "Error",
        message = "Account does not exist.";
}

class BBool extends BType<bool> {
  const BBool();

  @override
  bool read(BinaryReader reader) => reader.readU8() != 0;

  @override
  void write(BinaryWriter writer, bool value) {
    writer.writeU8(value ? 1 : 0);
  }
}

class BPublicKey extends BType<Ed25519HDPublicKey> {
  const BPublicKey();

  @override
  Ed25519HDPublicKey read(BinaryReader reader) {
    final data = reader.readFixedArray(32, () => reader.readU8());

    return Ed25519HDPublicKey(data);
  }

  @override
  void write(BinaryWriter writer, Ed25519HDPublicKey value) {
    final data = value.bytes;
    writer.writeFixedArray<int>(data, writer.writeU8);
  }
}
