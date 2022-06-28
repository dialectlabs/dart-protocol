import 'dart:typed_data';

import 'package:convert/convert.dart';
import 'package:crypto/crypto.dart';
import 'package:dialect_web3/src/core/constants.dart';
import 'package:solana/encoder.dart';
import 'package:solana/solana.dart';

class DialectInstructions {
  static Instruction closeDialect(
      Ed25519HDPublicKey owner,
      Ed25519HDPublicKey dialect,
      int dialectNonce,
      Ed25519HDPublicKey dialectProgramId) {
    List<AccountMeta> _keys = [
      AccountMeta(pubKey: owner, isSigner: true, isWriteable: true),
      AccountMeta(pubKey: dialect, isSigner: false, isWriteable: true),
      AccountMeta(
          pubKey: SYSVAR_RENT_PUBKEY, isSigner: false, isWriteable: false),
      AccountMeta(
          pubKey: SYSTEM_PROGRAM_ID, isSigner: false, isWriteable: false),
    ];
    List<int> data = [
      ...sha256
          .convert(Uint8List.fromList("global:close_dialect".codeUnits))
          .bytes
          .sublist(0, 8),
      dialectNonce
    ];
    return Instruction(
        programId: dialectProgramId, accounts: _keys, data: ByteArray(data));
  }

  static Instruction closeMetadata(
      Ed25519HDPublicKey user,
      Ed25519HDPublicKey metadata,
      int metadataNonce,
      Ed25519HDPublicKey dialectProgramId) {
    List<AccountMeta> _keys = [
      AccountMeta(pubKey: user, isSigner: true, isWriteable: true),
      AccountMeta(pubKey: metadata, isSigner: true, isWriteable: false),
      AccountMeta(
          pubKey: SYSVAR_RENT_PUBKEY, isSigner: false, isWriteable: false),
      AccountMeta(
          pubKey: SYSTEM_PROGRAM_ID, isSigner: false, isWriteable: false),
    ];
    List<int> data = [
      ...sha256
          .convert(Uint8List.fromList("global:create_metadata".codeUnits))
          .bytes
          .sublist(0, 8),
      metadataNonce,
    ];
    return Instruction(
        programId: dialectProgramId, accounts: _keys, data: ByteArray(data));
  }

  static Instruction createDialect(
      Ed25519HDPublicKey owner,
      Ed25519HDPublicKey member0,
      Ed25519HDPublicKey member1,
      Ed25519HDPublicKey dialect,
      int dialectNonce,
      bool encrypted,
      List<bool> scopes,
      Ed25519HDPublicKey dialectProgramId) {
    List<AccountMeta> _keys = [
      AccountMeta(pubKey: owner, isSigner: true, isWriteable: true),
      AccountMeta(pubKey: member0, isSigner: false, isWriteable: false),
      AccountMeta(pubKey: member1, isSigner: false, isWriteable: false),
      AccountMeta(pubKey: dialect, isSigner: false, isWriteable: true),
      AccountMeta(
          pubKey: SYSVAR_RENT_PUBKEY, isSigner: false, isWriteable: false),
      AccountMeta(
          pubKey: SYSTEM_PROGRAM_ID, isSigner: false, isWriteable: false),
    ];
    List<int> data = [
      ...sha256
          .convert(Uint8List.fromList("global:create_dialect".codeUnits))
          .bytes
          .sublist(0, 8),
      dialectNonce,
      encrypted ? 1 : 0
    ];
    for (var scope in scopes) {
      data.addAll([scope ? 1 : 0]);
    }
    return Instruction(
        programId: dialectProgramId, accounts: _keys, data: ByteArray(data));
  }

  static Instruction createMetadata(
      Ed25519HDPublicKey user,
      Ed25519HDPublicKey metadata,
      int metadataNonce,
      Ed25519HDPublicKey dialectProgramId) {
    List<AccountMeta> _keys = [
      AccountMeta(pubKey: user, isSigner: true, isWriteable: true),
      AccountMeta(pubKey: metadata, isSigner: true, isWriteable: false),
      AccountMeta(
          pubKey: SYSVAR_RENT_PUBKEY, isSigner: false, isWriteable: false),
      AccountMeta(
          pubKey: SYSTEM_PROGRAM_ID, isSigner: false, isWriteable: false),
    ];
    List<int> data = [
      ...sha256
          .convert(Uint8List.fromList("global:create_metadata".codeUnits))
          .bytes
          .sublist(0, 8),
      metadataNonce,
    ];
    return Instruction(
        programId: dialectProgramId, accounts: _keys, data: ByteArray(data));
  }

  static Instruction sendMessage(
      Ed25519HDPublicKey sender,
      Ed25519HDPublicKey dialect,
      int dialectNonce,
      List<int> text,
      Ed25519HDPublicKey dialectProgramId) {
    List<AccountMeta> _keys = [
      AccountMeta(pubKey: sender, isSigner: true, isWriteable: true),
      AccountMeta(pubKey: dialect, isSigner: false, isWriteable: true),
      AccountMeta(
          pubKey: SYSVAR_RENT_PUBKEY, isSigner: false, isWriteable: false),
      AccountMeta(
          pubKey: SYSTEM_PROGRAM_ID, isSigner: false, isWriteable: false),
    ];
    List<int> data = [
      ...sha256
          .convert(Uint8List.fromList("global:send_message".codeUnits))
          .bytes
          .sublist(0, 8),
      dialectNonce,
      ...text.length.intToBytes(),
      ...text
    ];
    return Instruction(
        programId: dialectProgramId, accounts: _keys, data: ByteArray(data));
  }

  static Instruction subscribeUser(
      Ed25519HDPublicKey signer,
      Ed25519HDPublicKey user,
      Ed25519HDPublicKey metadata,
      Ed25519HDPublicKey dialect,
      int dialectNonce,
      int metadataNonce,
      bool encrypted,
      List<bool> scopes,
      Ed25519HDPublicKey dialectProgramId) {
    List<AccountMeta> _keys = [
      AccountMeta(pubKey: signer, isSigner: true, isWriteable: true),
      AccountMeta(pubKey: user, isSigner: false, isWriteable: false),
      AccountMeta(pubKey: metadata, isSigner: true, isWriteable: false),
      AccountMeta(pubKey: dialect, isSigner: false, isWriteable: false),
      AccountMeta(
          pubKey: SYSVAR_RENT_PUBKEY, isSigner: false, isWriteable: false),
      AccountMeta(
          pubKey: SYSTEM_PROGRAM_ID, isSigner: false, isWriteable: false),
    ];
    List<int> data = [
      ...sha256
          .convert(Uint8List.fromList("global:subscribe_user".codeUnits))
          .bytes
          .sublist(0, 8),
      dialectNonce,
      metadataNonce
    ];
    for (var scope in scopes) {
      data.addAll([scope ? 1 : 0]);
    }
    return Instruction(
        programId: dialectProgramId, accounts: _keys, data: ByteArray(data));
  }
}

extension Encoder on int {
  List<int> intToBytes([int bitSize = 32]) {
    return List.from(
        hex.decode(toRadixString(16).padLeft(2 * bitSize ~/ 8, '0')).reversed);
  }
}
