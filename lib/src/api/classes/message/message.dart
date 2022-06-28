import 'package:solana/solana.dart';

class Message {
  Ed25519HDPublicKey owner;
  String text;
  int timestamp;
  Message(this.owner, this.text, this.timestamp);
}
