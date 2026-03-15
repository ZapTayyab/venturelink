import 'package:http/http.dart' as http;
import 'package:web3dart/web3dart.dart';
import '../core/errors/error_handler.dart';

/// VentureLink Blockchain Service
/// Uses Ethereum Sepolia testnet for student demo purposes.
/// Records investment transactions immutably on-chain.
class BlockchainService {
  BlockchainService._();

  // Sepolia testnet RPC - free to use
  static const String _rpcUrl =
      'https://ethereum-sepolia-rpc.publicnode.com';

  // Your deployed contract address (deploy once using Remix IDE)
  // See CONTRACT_ABI and SOLIDITY below
  static const String _contractAddress =
      '0x0000000000000000000000000000000000000000'; // REPLACE after deploy

  // Contract ABI - matches InvestmentLedger.sol
  static const String _contractAbi = '''
[
  {
    "inputs": [
      {"internalType": "string", "name": "investmentId", "type": "string"},
      {"internalType": "string", "name": "investorId", "type": "string"},
      {"internalType": "string", "name": "startupId", "type": "string"},
      {"internalType": "string", "name": "roundId", "type": "string"},
      {"internalType": "uint256", "name": "amountUsd", "type": "uint256"}
    ],
    "name": "recordInvestment",
    "outputs": [],
    "stateMutability": "nonpayable",
    "type": "function"
  },
  {
    "inputs": [{"internalType": "string", "name": "investmentId", "type": "string"}],
    "name": "getInvestment",
    "outputs": [
      {"internalType": "string", "name": "investorId", "type": "string"},
      {"internalType": "string", "name": "startupId", "type": "string"},
      {"internalType": "string", "name": "roundId", "type": "string"},
      {"internalType": "uint256", "name": "amountUsd", "type": "uint256"},
      {"internalType": "uint256", "name": "timestamp", "type": "uint256"},
      {"internalType": "bool", "name": "exists", "type": "bool"}
    ],
    "stateMutability": "view",
    "type": "function"
  },
  {
    "anonymous": false,
    "inputs": [
      {"indexed": true, "internalType": "string", "name": "investmentId", "type": "string"},
      {"indexed": false, "internalType": "string", "name": "investorId", "type": "string"},
      {"indexed": false, "internalType": "string", "name": "startupId", "type": "string"},
      {"indexed": false, "internalType": "uint256", "name": "amountUsd", "type": "uint256"},
      {"indexed": false, "internalType": "uint256", "name": "timestamp", "type": "uint256"}
    ],
    "name": "InvestmentRecorded",
    "type": "event"
  }
]
''';

  static Web3Client? _client;
  static DeployedContract? _contract;
  static EthPrivateKey? _credentials;

  /// Initialize with the platform wallet private key
  /// In production: use Firebase Secret Manager, NOT hardcoded
  /// For student demo: generate a fresh Sepolia wallet and fund with faucet
  static Future<void> init({required String privateKey}) async {
    try {
      _client = Web3Client(_rpcUrl, http.Client());
      _credentials = EthPrivateKey.fromHex(privateKey);

      if (_contractAddress == '0x0000000000000000000000000000000000000000') {
        ErrorHandler.logWarning(
            'BlockchainService: Contract not deployed yet. Using mock mode.');
        return;
      }

      final abi = ContractAbi.fromJson(_contractAbi, 'InvestmentLedger');
      _contract = DeployedContract(
        abi,
        EthereumAddress.fromHex(_contractAddress),
      );

      ErrorHandler.log('BlockchainService initialized on Sepolia testnet');
    } catch (e, stack) {
      ErrorHandler.log('BlockchainService init failed', error: e, stackTrace: stack);
    }
  }

  /// Record an investment on the blockchain
  /// Returns the transaction hash, or a mock hash if not deployed
  static Future<BlockchainReceipt> recordInvestment({
    required String investmentId,
    required String investorId,
    required String startupId,
    required String roundId,
    required double amountUsd,
  }) async {
    // Mock mode for when contract is not deployed yet
    if (_client == null ||
        _contract == null ||
        _contractAddress == '0x0000000000000000000000000000000000000000') {
      return _mockReceipt(investmentId, amountUsd);
    }

    try {
      final function = _contract!.function('recordInvestment');
      final amountInCents = BigInt.from((amountUsd * 100).round());

      final txHash = await _client!.sendTransaction(
        _credentials!,
        Transaction.callContract(
          contract: _contract!,
          function: function,
          parameters: [
            investmentId,
            investorId,
            startupId,
            roundId,
            amountInCents,
          ],
        ),
        chainId: 11155111, // Sepolia chain ID
        fetchChainIdFromNetworkId: false,
      );

      ErrorHandler.log('Investment recorded on blockchain: $txHash');

      return BlockchainReceipt(
        txHash: txHash,
        investmentId: investmentId,
        amountUsd: amountUsd,
        timestamp: DateTime.now(),
        network: 'Sepolia Testnet',
        explorerUrl: 'https://sepolia.etherscan.io/tx/$txHash',
        isMock: false,
      );
    } catch (e, stack) {
      ErrorHandler.log('Blockchain record failed, using mock',
          error: e, stackTrace: stack);
      return _mockReceipt(investmentId, amountUsd);
    }
  }

  /// Verify an investment exists on chain
  static Future<bool> verifyInvestment(String investmentId) async {
    if (_client == null || _contract == null) return false;
    try {
      final function = _contract!.function('getInvestment');
      final result = await _client!.call(
        contract: _contract!,
        function: function,
        params: [investmentId],
      );
      return result[5] as bool; // exists field
    } catch (e) {
      return false;
    }
  }

  static BlockchainReceipt _mockReceipt(
      String investmentId, double amountUsd) {
    // Generate deterministic mock hash for demo
    final mockHash =
        '0x${investmentId.hashCode.abs().toRadixString(16).padLeft(64, '0')}';
    return BlockchainReceipt(
      txHash: mockHash,
      investmentId: investmentId,
      amountUsd: amountUsd,
      timestamp: DateTime.now(),
      network: 'Demo (Deploy contract for real chain)',
      explorerUrl: 'https://sepolia.etherscan.io',
      isMock: true,
    );
  }

  static Future<void> dispose() async {
    await _client?.dispose();
    _client = null;
    _contract = null;
  }
}

class BlockchainReceipt {
  final String txHash;
  final String investmentId;
  final double amountUsd;
  final DateTime timestamp;
  final String network;
  final String explorerUrl;
  final bool isMock;

  const BlockchainReceipt({
    required this.txHash,
    required this.investmentId,
    required this.amountUsd,
    required this.timestamp,
    required this.network,
    required this.explorerUrl,
    required this.isMock,
  });

  String get shortHash =>
      '${txHash.substring(0, 10)}...${txHash.substring(txHash.length - 6)}';

  Map<String, dynamic> toMap() => {
        'txHash': txHash,
        'network': network,
        'explorerUrl': explorerUrl,
        'isMock': isMock,
        'recordedAt': timestamp.toIso8601String(),
      };
}