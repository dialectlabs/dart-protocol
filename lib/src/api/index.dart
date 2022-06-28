import 'dart:convert';
import 'dart:typed_data';

import 'package:dialect_web3/dialect_web3.dart';
import 'package:dialect_web3/src/api/classes/message/message.dart' as message;
import 'package:solana/dto.dart';
import 'package:solana/solana.dart' as sol;

export './borsh/borsh_extensions.dart';
export './classes/classes.dart';
export './dialect_instructions.dart';
export './text_serde/text_serde.dart';

const accountDescriptorSize = 8;

const deviceTokenLength = 64;
const deviceTokenPaddingLength =
    deviceTokenPayloadLength - deviceTokenLength - ENCRYPTION_OVERHEAD_BYTES;

const deviceTokenPayloadLength = 128;
const dialectAccountMember0Offset = accountDescriptorSize;
const dialectAccountMember1Offset =
    dialectAccountMember0Offset + dialectAccountMemberSize;
const dialectAccountMemberSize = 34;

Future<DialectAccount> createDialect(
    {required sol.RpcClient client,
    required ProgramAccount program,
    required KeypairWallet owner,
    required List<Member> members,
    bool encrypted = false,
    EncryptionProps? encryptionProps}) async {
  members
      .sort((a, b) => a.publicKey.toBase58().compareTo(b.publicKey.toBase58()));
  final programAddr = await getDialectProgramAddress(
      program, members.map((e) => e.publicKey).toList());
  final tx = await client.signAndSendTransaction(
      sol.Message(instructions: [
        DialectInstructions.createDialect(
            owner.publicKey,
            members[0].publicKey,
            members[1].publicKey,
            programAddr.publicKey,
            programAddr.nonce,
            encrypted,
            members.map((e) => e.scopes).expand((element) => element).toList(),
            sol.Ed25519HDPublicKey.fromBase58(program.pubkey))
      ]),
      owner.signers);

  await waitForFinality(client: client, transactionStr: tx);
  return await getDialectForMembers(
      client, program, members.map((e) => e.publicKey).toList(),
      encryptionProps: encryptionProps);
}

Future<ProgramAccount> createDialectProgram(
    sol.RpcClient client, sol.Ed25519HDPublicKey dialectProgramAddress) async {
  final account = await client.getAccountInfo(dialectProgramAddress.toBase58());

  return ProgramAccount(
      account: account!, pubkey: dialectProgramAddress.toBase58());
}

Future deleteDialect(sol.RpcClient client, ProgramAccount program,
    DialectAccount dialectAccount, KeypairWallet owner) async {
  final addressResult = await getDialectProgramAddress(
      program, dialectAccount.dialect.members.map((e) => e.publicKey).toList());
  final tx = await client.signAndSendTransaction(
      sol.Message(instructions: [
        DialectInstructions.closeDialect(
            owner.publicKey,
            addressResult.publicKey,
            addressResult.nonce,
            sol.Ed25519HDPublicKey.fromBase58(program.pubkey))
      ]),
      owner.signers);
  await waitForFinality(client: client, transactionStr: tx);
}

Future<List<DialectAccount>> findDialects(sol.RpcClient client,
    ProgramAccount program, FindDialectQuery query) async {
  final List<ProgramDataFilter> memberFilters = query.userPk != null
      ? [
          ProgramDataFilter.memcmp(
              offset: dialectAccountMember0Offset, bytes: query.userPk!.bytes),
          ProgramDataFilter.memcmp(
              offset: dialectAccountMember1Offset, bytes: query.userPk!.bytes)
        ]
      : [];
  final results = await Future.wait(memberFilters.map((e) => client
      .getProgramAccounts(program.pubkey,
          encoding: Encoding.base64, filters: [e])));
  final dialects = results.expand((element) => element).map((e) {
    final rawDialect = parseBytesFromAccount(e.account, RawDialect.fromBorsh);
    return DialectAccount(
        dialect: parseRawDialect(rawDialect),
        publicKey: sol.Ed25519HDPublicKey.fromBase58(e.pubkey));
  }).toList();
  dialects.sort((d1, d2) =>
      d2.dialect.lastMessageTimestamp -
      d1.dialect.lastMessageTimestamp); // descending
  return dialects;
}

Future<DialectAccount> getDialect(sol.RpcClient client, ProgramAccount program,
    sol.Ed25519HDPublicKey publicKey, EncryptionProps? encryptionProps) async {
  final rawDialect =
      await fetchAccount(client, publicKey, RawDialect.fromBorsh);
  final dialect = parseRawDialect(rawDialect, encryptionProps: encryptionProps);
  return DialectAccount(dialect: dialect, publicKey: publicKey);
}

Future<DialectAccount> getDialectForMembers(sol.RpcClient client,
    ProgramAccount program, List<sol.Ed25519HDPublicKey> members,
    {EncryptionProps? encryptionProps}) async {
  members.sort((a, b) => a.toBase58().compareTo(b.toBase58()));
  final pubKeyResult = await getDialectProgramAddress(program, members);
  return await getDialect(
      client, program, pubKeyResult.publicKey, encryptionProps);
}

Future<ProgramAddressResult> getDialectProgramAddress(
    ProgramAccount program, List<sol.Ed25519HDPublicKey> members) {
  members.sort((a, b) => a.toBase58().compareTo(b.toBase58()));
  var seeds = [utf8.encode('dialect'), ...members.map((e) => e.bytes)];
  return findProgramAddressWithNonce(
      seeds: seeds,
      programId: sol.Ed25519HDPublicKey.fromBase58(program.pubkey));
}

bool isDialectAdmin(DialectAccount dialect, sol.Ed25519HDPublicKey user) {
  return dialect.dialect.members.any((element) =>
      element.publicKey.toBase58() == user.toBase58() && element.scopes[0]);
}

List<message.Message> parseMessages(RawDialect rawDialect,
    {EncryptionProps? encryptionProps}) {
  final encrypted = rawDialect.encrypted;
  final rawMessagesBuffer = rawDialect.messages;
  final members = rawDialect.members;
  if (encrypted && encryptionProps == null) {
    return [];
  }
  final messagesBuffer = CyclicByteBuffer(
      rawMessagesBuffer.readOffset,
      rawMessagesBuffer.writeOffset,
      rawMessagesBuffer.itemsCount,
      Uint8List.fromList(rawMessagesBuffer.buffer));
  final textSerde = TextSerdeFactory.create(
      DialectAttributes(rawDialect.encrypted, rawDialect.members),
      encryptionProps);

  List<message.Message> allMessages = messagesBuffer.items().map((item) {
    final byteBuffer = ByteData.view(item.buffer.buffer);
    final ownerMemberIndex = byteBuffer.getUint8(0);
    final messageOwner = members[ownerMemberIndex];
    final timestamp = byteBuffer.getUint32(1) * 1000;
    final serializedText =
        Uint8List.fromList(byteBuffer.buffer.asUint8List().sublist(5));
    final text = textSerde.deserialize(serializedText);
    return message.Message(messageOwner.publicKey, text, timestamp);
  }).toList();
  return allMessages.reversed.toList();
}

Dialect parseRawDialect(RawDialect rawDialect,
    {EncryptionProps? encryptionProps}) {
  return Dialect(
      members: rawDialect.members,
      messages: parseMessages(rawDialect, encryptionProps: encryptionProps),
      nextMessageIdx: rawDialect.messages.writeOffset,
      lastMessageTimestamp: rawDialect.lastMessageTimestamp * 1000,
      encrypted: rawDialect.encrypted);
}

Future<message.Message?> sendMessage(
    sol.RpcClient client,
    ProgramAccount program,
    DialectAccount dialectAccount,
    KeypairWallet sender,
    String text,
    {EncryptionProps? encryptionProps}) async {
  final addressResult = await getDialectProgramAddress(
      program, dialectAccount.dialect.members.map((e) => e.publicKey).toList());
  final textSerde = TextSerdeFactory.create(
      DialectAttributes(
          dialectAccount.dialect.encrypted, dialectAccount.dialect.members),
      encryptionProps);
  final serializedText = textSerde.serialize(text);

  final tx = await client.signAndSendTransaction(
      sol.Message(instructions: [
        DialectInstructions.sendMessage(
            sender.publicKey,
            addressResult.publicKey,
            addressResult.nonce,
            serializedText,
            sol.Ed25519HDPublicKey.fromBase58(program.pubkey))
      ]),
      sender.signers);
  await waitForFinality(client: client, transactionStr: tx);

  final d = await getDialect(
      client, program, addressResult.publicKey, encryptionProps);
  return d.dialect.messages[0];
}

Future<Metadata> _createMetadata(
    {required sol.RpcClient client,
    required ProgramAccount program,
    required KeypairWallet user}) async {
  final addressResult =
      await _getMetadataProgramAddress(program, user.publicKey);
  final tx = await client.signAndSendTransaction(
      sol.Message(instructions: [
        DialectInstructions.createMetadata(
            user.publicKey,
            addressResult.publicKey,
            addressResult.nonce,
            sol.Ed25519HDPublicKey.fromBase58(program.pubkey))
      ]),
      user.signers);
  await waitForFinality(client: client, transactionStr: tx);
  return await _getMetadata(
      client, program, KeypairWallet.fromKeypair(user.keyPair), null);
}

Future _deleteMetadata(
    sol.RpcClient client, ProgramAccount program, KeypairWallet user) async {
  final addressResult =
      await _getMetadataProgramAddress(program, user.publicKey);
  final tx = await client.signAndSendTransaction(
      sol.Message(instructions: [
        DialectInstructions.closeMetadata(
            user.publicKey,
            addressResult.publicKey,
            addressResult.nonce,
            sol.Ed25519HDPublicKey.fromBase58(program.pubkey))
      ]),
      user.signers);
  await waitForFinality(client: client, transactionStr: tx);
}

Future<List<DialectAccount>> _getDialects(
    sol.RpcClient client, ProgramAccount program, KeypairWallet user,
    {EncryptionProps? encryptionProps}) async {
  final metadata = await _getMetadata(client, program, user, null);
  final enbaledSubscriptions =
      metadata.subscriptions.where((element) => element.enabled);
  final dialects = await Future.wait(enbaledSubscriptions
      .map((e) => getDialect(client, program, e.pubKey, encryptionProps)));
  dialects.sort((d1, d2) =>
      d2.dialect.lastMessageTimestamp - d1.dialect.lastMessageTimestamp);
  return dialects;
}

Future<Metadata> _getMetadata(sol.RpcClient client, ProgramAccount program,
    KeypairWallet user, KeypairWallet? otherParty) async {
  var shouldDecrypt = false;
  var userIsKeypair = user.isKeypair;
  var otherPartyIsKeypair = otherParty != null && otherParty.isKeypair;

  if (otherParty != null && (userIsKeypair || otherPartyIsKeypair)) {
    shouldDecrypt = true;
  }
  final addressResult = await _getMetadataProgramAddress(
      program,
      userIsKeypair
          ? (await user.keyPair!.extractPublicKey())
          : user.publicKey);
  final metadata =
      await fetchAccount(client, addressResult.publicKey, Metadata.fromBorsh);
  return Metadata(
      subscriptions: metadata.subscriptions
          .where((element) => element.pubKey != DEFAULT_PUBKEY)
          .toList());
}

Future<ProgramAddressResult> _getMetadataProgramAddress(
    ProgramAccount program, sol.Ed25519HDPublicKey user) {
  return findProgramAddressWithNonce(
      seeds: [utf8.encode('metadata'), utf8.encode(user.toBase58())],
      programId: sol.Ed25519HDPublicKey.fromBase58(program.pubkey));
}

class FindDialectQuery {
  sol.Ed25519HDPublicKey? userPk;
  FindDialectQuery({required this.userPk});
}

class KeypairWallet {
  sol.Ed25519HDKeyPair? keyPair;
  sol.Ed25519HDPublicKey? wallet;

  KeypairWallet.fromKeypair(this.keyPair);

  KeypairWallet.fromWallet(this.wallet);

  bool get isKeypair => keyPair != null;

  bool get isWallet => wallet != null;
  sol.Ed25519HDPublicKey get publicKey =>
      keyPair != null ? keyPair!.publicKey : wallet!;

  List<sol.Ed25519HDKeyPair> get signers => keyPair != null ? [keyPair!] : [];
}
