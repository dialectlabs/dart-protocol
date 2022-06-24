// modified from ed25519_hd_public_key.dart

import 'package:solana/solana.dart';

const _maxBumpSeed = 255;
const _maxSeedLength = 32;
const _maxSeeds = 16;

Future<ProgramAddressResult> findProgramAddressWithNonce({
  required Iterable<Iterable<int>> seeds,
  required Ed25519HDPublicKey programId,
}) async {
  if (seeds.length > _maxSeeds) {
    throw const FormatException('you can give me up to $_maxSeeds seeds');
  }
  final overflowingSeed = seeds.where((s) => s.length > _maxSeedLength);
  if (overflowingSeed.isNotEmpty) {
    throw const FormatException(
      'one or more of the seeds provided is too big',
    );
  }
  final flatSeeds = seeds.fold(<int>[], _flatten);
  int bumpSeed = _maxBumpSeed;
  while (bumpSeed >= 0) {
    try {
      final pubKey = await Ed25519HDPublicKey.createProgramAddress(
        seeds: [...flatSeeds, bumpSeed],
        programId: programId,
      );
      return ProgramAddressResult(publicKey: pubKey, nonce: bumpSeed);
    } on FormatException {
      bumpSeed -= 1;
    }
  }

  throw const FormatException('cannot find program address with these seeds');
}

Iterable<int> _flatten(Iterable<int> concatenated, Iterable<int> current) =>
    concatenated.followedBy(current).toList();

class ProgramAddressResult {
  Ed25519HDPublicKey publicKey;
  int nonce;
  ProgramAddressResult({required this.publicKey, required this.nonce});
}
