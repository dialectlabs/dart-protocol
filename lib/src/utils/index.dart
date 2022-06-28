import 'dart:io';

import 'package:solana/dto.dart';
import 'package:solana/solana.dart';

export './cyclic_bytebuffer/cyclic_bytebuffer.dart';
export './ed2curve/ed2curve_utils.dart';
export './nonce_generator/nonce_generator.dart';
export './public_key/public_key.dart';

Future<TransactionDetails> waitForFinality(
    {required RpcClient client,
    required String transactionStr,
    Commitment commitment = Commitment.finalized,
    int maxRetries = 20,
    int sleepDuration = 1000}) async {
  try {
    return await waitForFinalityInner(
        client: client,
        transactionStr: transactionStr,
        commitment: commitment,
        maxRetries: maxRetries,
        sleepDuration: sleepDuration);
  } catch (e) {
    // TODO: log
    rethrow;
  }
}

Future<TransactionDetails> waitForFinalityInner(
    {required RpcClient client,
    required String transactionStr,
    Commitment commitment = Commitment.finalized,
    int maxRetries = 10,
    int sleepDuration = 500}) async {
  TransactionDetails? transaction;
  for (var n = 0; n < maxRetries; n++) {
    transaction =
        await client.getTransaction(transactionStr, commitment: commitment);
    if (transaction != null) {
      return transaction;
    }
    sleep(Duration(milliseconds: sleepDuration));
  }
  throw Exception('Transaction failed to finalize');
}

class Finality {
  static const String _finalized = "finalized";
  static const String _confirmed = "confirmed";
  late String _finality;
  Finality.confirmed() {
    _finality = _confirmed;
  }

  Finality.finalized() {
    _finality = _finalized;
  }

  bool get confirmed => _finality == _confirmed;
  bool get finalized => _finality == _finalized;
}
