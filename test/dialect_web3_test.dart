import 'dart:convert';

import 'package:dialect_protocol/dialect_web3.dart';
import 'package:solana/dto.dart';
import 'package:solana/solana.dart';
import 'package:test/test.dart';

void main() {
  group('web3 tests', () {
    late RpcClient client;
    late ProgramAccount program;
    late List<Ed25519HDKeyPair> users;
    setUp(() async {
      final networkUrl = programs.localnet.clusterAddress;
      final dialectProgramId = programs.localnet.programAddress;
      client = RpcClient(networkUrl);
      final account = await client.getAccountInfo(dialectProgramId);
      program = ProgramAccount(account: account!, pubkey: dialectProgramId);
      users = [
        await Ed25519HDKeyPair.random(),
        await Ed25519HDKeyPair.random()
      ];
    });

    test('retrieve account data on local', () async {
      try {
        fundUsers(client: client, keypairs: users);
        final user1 = users[0];
        final user2 = users[1];
        final dialectMembers = [
          Member(publicKey: user1.publicKey, scopes: [true, true]),
          Member(publicKey: user2.publicKey, scopes: [false, true])
        ];
        final user1Dialect = await createDialect(
            client: client,
            program: program,
            owner: KeypairWallet.fromKeypair(user1),
            members: dialectMembers);
        await sendMessage(client, program, user1Dialect,
            KeypairWallet.fromKeypair(user1), "Hello dialect!");
        final dialect = await getDialectForMembers(
            client, program, dialectMembers.map((e) => e.publicKey).toList());
        print(JsonEncoder().convert(dialect.dialect.messages));
      } catch (e) {
        print("error $e");
      }
    });
  });
}

Future fundUsers({
  required RpcClient client,
  required List<Ed25519HDKeyPair> keypairs,
  int amount = 10 * LAMPORTS_PER_SOL,
}) async {
  await Future.wait(
    keypairs.map((keypair) async {
      final fromAirdropSignature = await client.requestAirdrop(
        keypair.publicKey.toBase58(),
        amount,
      );
      await waitForFinality(
          client: client, transactionStr: fromAirdropSignature);
    }),
  );
}
