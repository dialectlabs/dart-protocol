final programs = ProgramsConfig.standard;

class ProgramConfig {
  static ProgramConfig get devnet => ProgramConfig(
      "https://api.devnet.solana.com",
      "2YFyZAg8rBtuvzFFiGvXwPHFAQJ2FXZoS7bYCKticpjk");
  static ProgramConfig get localnet => ProgramConfig(
      "http://127.0.0.1:8899", "2YFyZAg8rBtuvzFFiGvXwPHFAQJ2FXZoS7bYCKticpjk");
  static ProgramConfig get mainnet => ProgramConfig(
      "https://api.mainnet-beta.solana.com",
      "CeNUxGUsSeb5RuAGvaMLNx3tEZrpBwQqA7Gs99vMPCAb");

  static ProgramConfig get testnet => ProgramConfig("", "");
  String clusterAddress;
  String programAddress;
  ProgramConfig(this.clusterAddress, this.programAddress);
}

class ProgramsConfig {
  static ProgramsConfig get standard => ProgramsConfig(
      ProgramConfig.mainnet, ProgramConfig.devnet, ProgramConfig.localnet);
  ProgramConfig mainnet;
  ProgramConfig devnet;

  ProgramConfig localnet;

  ProgramsConfig(this.mainnet, this.devnet, this.localnet);
}
