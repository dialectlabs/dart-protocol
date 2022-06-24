import 'package:dialect_protocol/dialect_web3.dart';
import 'package:solana/solana.dart';

import '../test/dialect_web3_test.dart';

void main() async {
  final client = RpcClient(programs.localnet.clusterAddress);
  final program = await createDialectProgram(
      client, Ed25519HDPublicKey.fromBase58(programs.localnet.programAddress));
  final Ed25519HDKeyPair user1 = await Ed25519HDKeyPair.random();
  final Ed25519HDKeyPair user2 = await Ed25519HDKeyPair.random();
  await fundUsers(client: client, keypairs: [user1, user2]); // fund users

  final List<Member> dialectMembers = [
    Member(publicKey: user1.publicKey, scopes: [true, true]),
    Member(publicKey: user2.publicKey, scopes: [false, true])
  ];

  // create dialect on behalf of first user
  final user1Dialect = await createDialect(
      client: client,
      program: program,
      owner: KeypairWallet.fromKeypair(user1),
      members: dialectMembers,
      encrypted: false);

  // send message
  await sendMessage(client, program, user1Dialect,
      KeypairWallet.fromKeypair(user1), "Hello dialect!");

  // get dialect
  final dialect = await getDialectForMembers(
      client, program, dialectMembers.map((e) => e.publicKey).toList());
  print(dialect.dialect.messages.map((e) => e.text));
}
