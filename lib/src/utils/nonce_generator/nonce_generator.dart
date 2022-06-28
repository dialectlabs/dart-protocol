import 'package:pinenacl/ed25519.dart';
import 'package:pinenacl/tweetnacl.dart';

const NONCE_SIZE_BYTES = 24;

Uint8List generateRandomNonceWithPrefix(int memberId) {
  return Uint8List.fromList(
      [memberId] + TweetNaCl.randombytes(NONCE_SIZE_BYTES - 1));
}
