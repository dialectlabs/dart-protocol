import 'package:solana/solana.dart';

class AccountData<T> {
  T parsed;
  Ed25519HDPublicKey pubKey;
  AccountData(this.parsed, this.pubKey);
}
