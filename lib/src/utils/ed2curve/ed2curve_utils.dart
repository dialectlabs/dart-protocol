import 'package:pinenacl/ed25519.dart';
import 'package:pinenacl/tweetnacl.dart';

typedef Curve25519Key = Uint8List;

typedef Ed25519Key = Uint8List;

class Curve25519KeyPair {
  Curve25519Key publicKey;
  Curve25519Key secretKey;

  Curve25519KeyPair(this.publicKey, this.secretKey);
}

class Ed2CurveUtils {
  static Curve25519KeyPair convertKeyPair(
      Uint8List publicKey, Uint8List secretKey) {
    var newPk = Uint8List(TweetNaCl.publicKeyLength);
    var newSk = Uint8List(TweetNaCl.secretKeyLength);
    newPk = convertPublicKey(publicKey);
    newSk = convertPrivateKey(secretKey);
    return Curve25519KeyPair(newPk, newSk);
  }

  static Curve25519KeyPair? convertKeyPairOpt(
      Uint8List publicKey, Uint8List secretKey) {
    try {
      return convertKeyPair(publicKey, secretKey);
    } catch (e) {
      return null;
    }
  }

  static Curve25519Key convertPrivateKey(Ed25519Key secretKey) {
    var newSk = Uint8List(TweetNaCl.secretKeyLength);
    var oldSk = Uint8List.fromList(secretKey);
    var skResult =
        TweetNaClExt.crypto_sign_ed25519_sk_to_x25519_sk(newSk, oldSk);
    if (skResult == -1) {
      throw Exception('Failed to convert secret key');
    }
    return newSk;
  }

  static Curve25519Key convertPublicKey(Ed25519Key publicKey) {
    var newPk = Uint8List(TweetNaCl.publicKeyLength);
    var oldPk = Uint8List.fromList(publicKey);
    var pkResult =
        TweetNaClExt.crypto_sign_ed25519_pk_to_x25519_pk(newPk, oldPk);
    if (pkResult == -1) {
      throw Exception('Failed to convert public key');
    }
    return newPk;
  }

  static Curve25519Key? convertPublicKeyOpt(Ed25519Key publicKey) {
    try {
      return convertPublicKey(publicKey);
    } catch (e) {
      return null;
    }
  }
}
