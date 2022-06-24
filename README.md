
[![Twitter Follow](https://img.shields.io/twitter/follow/saydialect?style=social)](https://twitter.com/saydialect)
[![Discord](https://img.shields.io/discord/944285706963017758?label=Discord)](https://discord.gg/cxtZVyrJ)

# Protocol & web3

## Summary

Dialect is a smart messaging protocol for dapp notifications and wallet-to-wallet messaging on the Solana Blockchain.

Dialect `v0` currently supports one-to-one messaging between wallets, which powers both dapp notifications as well as user-to-user chat. Future versions of Dialect will also support one-to-many and many-to-many messaging.

This repository contains a dart client for Dialect's Solana program, published as `dialect_web3`. This repository does not contain the Dialect rust programs (protocol). For more information on Dialect's protocol, including instructions for local development, visit our [protocol GitHub](https://github.com/dialectlabs/protocol).

## Table of Contents

1. Usage
2. Local Development
3. Examples
4. Message Encryption

## Usage

This section describes how to use Dialect protocol in your app by showing you an example in the`example/` directory of this repository. Follow along in this section, & refer to the code in those examples.

### Create your first dialect, send and receive message

The example in `example/dialect_web3_example.dart` demonstrates how to create a new dialect, send and receive message.

```dart
import 'package:dialect_protocol/dialect_protocol.dart';
import 'package:dialect_protocol/src/api/index_test.dart';
import 'package:solana/solana.dart';

final program = // ... initialize dialect program
final Ed25519HDKeyPair user1 = await Ed25519HDKeyPair.random();
final Ed25519HDKeyPair user2 = await Ed25519HDKeyPair.random();
// fund users

final List<Member> dialectMembers = [
    Member(publicKey: user1.publicKey, scopes: [true, true]),
    Member(publicKey: user2.publicKey, scopes: [false, true])
];

final user1Dialect = await createDialect(
    client: client,
    program: program,
    owner: KeypairWallet.fromKeypair(user1),
    members: dialectMembers,
    encrypted: false); // create dialect on behalf of first user

await sendMessage(client, program, user1Dialect,
    KeypairWallet.fromKeypair(user1), "Hello dialect!"); // send message

final dialect = await getDialectForMembers(
    client, program, dialectMembers.map((e) => e.publicKey).toList()); // get dialect
print(dialect.dialect.messages.map((e) => e.text));
// Will print (Hello dialect!)
```

Run the example above

```shell
dart example/dialect_web3_example.dart
```

## Local Development

Using this Dialect client with Solana's deployed mainnet and devnet works out-of-the-box as expected. If you'd like to use this client to develop with a local running instance of the Dialect program, follow the [Local Development](https://github.com/dialectlabs/protocol#local-development) section of our [protocol GitHub](https://github.com/dialectlabs/protocol).

## Message Encryption

A note about the encryption nonce.

https://pynacl.readthedocs.io/en/v0.2.1/secret/

### Nonce

The 24 bytes nonce (Number used once) given to encrypt() and decrypt() must **_NEVER_** be reused for a particular key.
Reusing the nonce means an attacker will have enough information to recover your secret key and encrypt or decrypt arbitrary messages.
A nonce is not considered secret and may be freely transmitted or stored in plaintext alongside the ciphertext.

A nonce does not need to be random, nor does the method of generating them need to be secret.
A nonce could simply be a counter incremented with each message encrypted.

Both the sender and the receiver should record every nonce both that they’ve used and they’ve received from the other.
They should reject any message which reuses a nonce and they should make absolutely sure never to reuse a nonce.
It is not enough to simply use a random value and hope that it’s not being reused (simply generating random values would open up the system to a Birthday Attack).

One good method of generating nonces is for each person to pick a unique prefix, for example b"p1" and b"p2". When each person generates a nonce they prefix it, so instead of nacl.utils.random(24) you’d do b"p1" + nacl.utils.random(22). This prefix serves as a guarantee that no two messages from different people will inadvertently overlap nonces while in transit. They should still record every nonce they’ve personally used and every nonce they’ve received to prevent reuse or replays.

## Features, bugs, and further help

For feature requests, bug reports, or additional assistance using this client, feel free to reach out in our [Dialect Discord server](https://discord.gg/cxtZVyrJ). We will continue to update documentation as often as possible.