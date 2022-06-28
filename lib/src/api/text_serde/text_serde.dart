import 'dart:convert';

import 'package:dialect_protocol/src/api/classes/member/member.dart';
import 'package:dialect_protocol/src/utils/ed2curve/ed2curve_utils.dart';
import 'package:dialect_protocol/src/utils/nonce_generator/nonce_generator.dart';
import 'package:pinenacl/x25519.dart';
import 'package:solana/solana.dart';

class DialectAttributes {
  bool encrypted;
  List<Member> members;
  DialectAttributes(this.encrypted, this.members);
}

class EncryptedTextSerde implements TextSerde {
  final _unencryptedTextSerde = UnencryptedTextSerde();

  final EncryptionProps encryptionProps;
  final List<Ed25519HDPublicKey> members;

  EncryptedTextSerde({required this.encryptionProps, required this.members});

  Box box(Ed25519HDPublicKey otherMember) {
    return Box(
        myPrivateKey:
            PrivateKey(encryptionProps.diffieHellmanKeyPair.secretKey),
        theirPublicKey: PublicKey(Ed2CurveUtils.convertPublicKey(
            Uint8List.fromList(otherMember.bytes))));
  }

  @override
  String deserialize(Uint8List bytes) {
    final encryptionNonce = bytes.sublist(0, NONCE_SIZE_BYTES);
    final encryptedText = bytes.sublist(NONCE_SIZE_BYTES, bytes.length);
    final otherMember = _findOtherMember(encryptionProps.ed25519PublicKey);
    final text = box(otherMember)
        .decrypt(ByteList.fromList(encryptedText), nonce: encryptionNonce);
    return _unencryptedTextSerde.deserialize(text);
  }

  @override
  Uint8List serialize(String text) {
    final publicKey = encryptionProps.ed25519PublicKey;
    final senderMemberIdx = _findMemberIdx(publicKey);
    final textBytes = _unencryptedTextSerde.serialize(text);
    final otherMember = _findOtherMember(publicKey);
    final encryptionNonce = generateRandomNonceWithPrefix(senderMemberIdx);
    final encryptedText =
        box(otherMember).encrypt(textBytes, nonce: encryptionNonce);
    return Uint8List.fromList(encryptedText);
  }

  int _findMemberIdx(Ed25519HDPublicKey key) {
    final memberIdx =
        members.indexWhere((element) => element.toBase58() == key.toBase58());
    if (memberIdx == -1) {
      throw Exception('Expected to have another member');
    }
    return memberIdx;
  }

  Ed25519HDPublicKey _findOtherMember(Ed25519HDPublicKey key) {
    try {
      final otherMember =
          members.firstWhere((element) => element.toBase58() != key.toBase58());
      return otherMember;
    } catch (e) {
      throw Exception('Expected to have other member');
    }
  }
}

class EncryptionProps {
  Ed25519HDPublicKey ed25519PublicKey;
  Curve25519KeyPair diffieHellmanKeyPair;

  EncryptionProps(this.ed25519PublicKey, this.diffieHellmanKeyPair);
}

abstract class TextSerde {
  String deserialize(Uint8List bytes);
  Uint8List serialize(String text);
}

class TextSerdeFactory {
  static TextSerde create(
      DialectAttributes attributes, EncryptionProps? encryptionProps) {
    if (!attributes.encrypted) {
      return UnencryptedTextSerde();
    }
    if (attributes.encrypted && encryptionProps != null) {
      return EncryptedTextSerde(
          encryptionProps: encryptionProps,
          members: attributes.members.map((e) => e.publicKey).toList());
    }
    throw Exception('Cannot proceed without encryptionProps');
  }
}

class UnencryptedTextSerde implements TextSerde {
  @override
  String deserialize(Uint8List bytes) {
    return utf8.decode(bytes);
  }

  @override
  Uint8List serialize(String text) {
    return Uint8List.fromList(utf8.encode(text));
  }
}
