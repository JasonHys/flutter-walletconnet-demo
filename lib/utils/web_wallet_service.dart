import 'dart:async';
import 'package:flutter/material.dart';
import 'package:walletconnect/utils/chain_data.dart';
import 'package:walletconnect/utils/chain_metadata.dart';
import 'package:walletconnect/utils/dialog.dart';
import 'package:walletconnect/utils/navkey.dart';
import 'package:walletconnect_flutter_v2/apis/core/core.dart';
import 'package:walletconnect_flutter_v2/apis/core/pairing/utils/pairing_models.dart';
import 'package:walletconnect_flutter_v2/apis/core/relay_client/relay_client_models.dart';
import 'package:walletconnect_flutter_v2/apis/core/store/store_models.dart';
import 'package:walletconnect_flutter_v2/apis/models/json_rpc_response.dart';
import 'package:walletconnect_flutter_v2/apis/sign_api/models/session_models.dart';
import 'package:walletconnect_flutter_v2/apis/sign_api/models/sign_client_events.dart';
import 'package:walletconnect_flutter_v2/apis/utils/constants.dart';
import 'package:walletconnect_flutter_v2/apis/utils/errors.dart';
import 'package:walletconnect_flutter_v2/apis/utils/log_level.dart';
import 'package:walletconnect_flutter_v2/apis/web3wallet/web3wallet.dart';

class Web3WalletService {
  Web3Wallet? _web3Wallet;
  static late Web3Wallet instance;

  static onPair(String key) {
    final Uri uriData = Uri.parse(key);
    instance.pair(uri: uriData);
  }

// 支持的方法
  Map<String, dynamic Function(String, dynamic)> get methodRequestHandlers => {
        'personal_sign': personalSign,
        'eth_sign': ethSign,
        'eth_signTransaction': ethSignTransaction,
        'eth_sendTransaction': ethSendTransaction,
        'eth_signTypedData': ethSignTypedData,
        'eth_signTypedData_v4': ethSignTypedDataV4,
        'wallet_switchEthereumChain': switchChain,
        'wallet_addEthereumChain': addChain,
      };
  static void onClose(String key) {
    String topKey = instance.sessions
        .getAll()
        .where((element) => element.pairingTopic == key)
        .first
        .topic;
    ;
    instance.disconnectSession(
      topic: topKey,
      reason: Errors.getSdkError(Errors.USER_DISCONNECTED),
    );
    // instance.core.pairing.disconnect(topic: key);
  }

  Future<void> create() async {
    // Create the web3wallet
    _web3Wallet = await Web3Wallet.createInstance(
      // core: Core(
      //   projectId: 'ea5e36f5d18677fba5c851536c45294c',
      //   logLevel: LogLevel.error,
      // ),
      projectId: 'ea5e36f5d18677fba5c851536c45294c',
      metadata: const PairingMetadata(
        name: '连接3',
        description: '连接3',
        url: 'https://walletconnect.com/',
        icons: [
          'https://docs.walletconnect.com/assets/images/web3walletLogo-54d3b546146931ceaf47a3500868a73a.png'
        ],
      ),
    );

    List<String> keys = ChainData.mainChains.map((e) => e.chainId).toList();
    for (final chainId in keys) {
      _web3Wallet!.registerAccount(
        chainId: chainId,
        // 0x8e325b68e7af42f3c21dbc4611cbe9268c0d328c
        accountAddress: "",
      );

      for (var handler in methodRequestHandlers.entries) {
        _web3Wallet!.registerRequestHandler(
          chainId: chainId,
          method: handler.key,
          handler: handler.value,
        );
      }

      for (final event in EventsConstants.requiredEvents) {
        _web3Wallet!.registerEventEmitter(
          chainId: chainId,
          event: event,
        );
      }
    }

    // Setup our listeners
    debugPrint('web3wallet create');
    instance = _web3Wallet!;
    _web3Wallet!.core.pairing.onPairingInvalid.subscribe(_onPairingInvalid);
    _web3Wallet!.core.pairing.onPairingCreate.subscribe(_onPairingCreate);
    _web3Wallet!.pairings.onSync.subscribe(_onPairingsSync);
    // 扫码验证
    _web3Wallet!.onSessionProposal.subscribe(_onSessionProposal);
    _web3Wallet!.onSessionProposalError.subscribe(_onSessionProposalError);
    // _web3Wallet!.onAuthRequest.subscribe(_onAuthRequest);
    _web3Wallet!.core.relayClient.onRelayClientError
        .subscribe(_onRelayClientError);
    _web3Wallet!.onSessionRequest.subscribe(_onSessionRequest);
    instance.onSessionDelete.subscribe(_onSessionDelete);
    init();
  }

  static List<PairingInfo> getPair() {
    List<PairingInfo> pairings;
    pairings = instance.pairings.getAll();
    return pairings;
  }

  static void getsseion() {
    List list = instance.sessions.getAll();
    print('sessions===================${list}');
    List list1 = instance.pairings.getAll();
    print('pairings=================${list1}');
    List list2 = instance.completeRequests.getAll();
    print('completeRequests=========${list2}');
  }

  void init() {
    // Await the initialization of the web3wallet
    debugPrint('web3wallet init');
    _web3Wallet!.init();

    // sessions= _web3Wallet!.sessions.getAll();
    // auth = _web3Wallet!.completeRequests.getAll();
  }

  @override
  FutureOr onDispose() {
    debugPrint('web3wallet dispose');
    _web3Wallet!.core.pairing.onPairingInvalid.unsubscribe(_onPairingInvalid);
    _web3Wallet!.pairings.onSync.unsubscribe(_onPairingsSync);
    _web3Wallet!.onSessionProposal.unsubscribe(_onSessionProposal);
    _web3Wallet!.onSessionProposalError.unsubscribe(_onSessionProposalError);
    // _web3Wallet!.onAuthRequest.unsubscribe(_onAuthRequest);
    _web3Wallet!.core.relayClient.onRelayClientError
        .unsubscribe(_onRelayClientError);
  }

  @override
  Web3Wallet getWeb3Wallet() {
    return _web3Wallet!;
  }

  // 断开连接
  _onSessionDelete(dynamic args) {
    debugPrint('[$runtimeType] _onSessionDelete ${args}');
  }

  void _onPairingsSync(StoreSyncEvent? args) {
    debugPrint('[$runtimeType] _onPairingsSync ${args}');
    List<PairingInfo> list = _web3Wallet!.pairings.getAll();
    print('list =========${list}');
  }

  void _onRelayClientError(ErrorEvent? args) {
    debugPrint('[$runtimeType] _onRelayClientError ${args?.error}');
  }

  void _onSessionProposalError(SessionProposalErrorEvent? args) async {
    debugPrint('[$runtimeType] _onSessionProposalError $args');
    if (args != null) {
      String errorMessage = args.error.message;
      if (args.error.code == 5100) {
        errorMessage =
            errorMessage.replaceFirst('Requested:', '\n\nRequested:');
        errorMessage =
            errorMessage.replaceFirst('Supported:', '\n\nSupported:');
      }
    }
  }

  Map<String, Namespace> _generateNamespaces(
      Map<String, Namespace>? approvedNamespaces, ChainType chainType,
      {required String account}) {
    //
    final constructedNS = Map<String, Namespace>.from(approvedNamespaces ?? {});
    List<String> accountList = [];
    if (constructedNS[chainType.name]!.accounts.isNotEmpty) {
      accountList = constructedNS[chainType.name]!.accounts.map((e) {
        List<String> keys = e.split(':');
        String key = '${keys[0]}:${keys[1]}:${account}';
        return key;
      }).toList();
    }
    constructedNS[chainType.name] =
        constructedNS[chainType.name]!.copyWith(methods: [
      'personal_sign',
      ...constructedNS[chainType.name]!.methods,
    ], accounts: accountList);
    return constructedNS;
  }

  void _onSessionProposal(SessionProposalEvent? args) async {
    print('yanzheng');
    if (args != null) {
      // generatedNamespaces is constructed based on registered methods handlers
      // so if you want to handle requests using onSessionRequest event then you would need to manually add that method in the approved namespaces
      final approvedNS = _generateNamespaces(
          args.params.generatedNamespaces!, ChainType.eip155,
          account: "0xE2BE444EF66780A7D5b5A81604229935B99823FA");
      // final proposalData = args.params.copyWith(
      //   generatedNamespaces: approvedNS,
      // );
      var approved = await DialogUtils.showDialog();
      // 连接钱包弹窗
      if (approved == true) {
        _web3Wallet!.approveSession(
          id: args.id,
          namespaces: approvedNS,
        );
        // final scheme = args.params.proposer.metadata.redirect?.native ?? '';
        // DeepLinkHandler.goTo(scheme, delay: 300);
      } else {
        _web3Wallet!.rejectSession(
          id: args.id,
          reason: Errors.getSdkError(Errors.USER_REJECTED),
        );
        _web3Wallet!.core.pairing.disconnect(
          topic: args.params.pairingTopic,
        );
      }
    }
  }

  void _onPairingInvalid(PairingInvalidEvent? args) {
    debugPrint('[$runtimeType] _onPairingInvalid $args');
  }

  void _onPairingCreate(PairingEvent? args) {
    debugPrint('[$runtimeType] _onPairingCreate $args');
  }

  void _onSessionRequest(SessionRequestEvent? args) async {}

  // personal_sign is handled using onSessionRequest event for demo purposes
  Future<void> personalSign(String topic, dynamic parameters) async {
    debugPrint('[$runtimeType] personalSign request: $parameters');
    print('request==${_web3Wallet!.pendingRequests.getAll().last}');
    var pRequest = _web3Wallet!.pendingRequests.getAll().last;
    var approved = await DialogUtils.showDialog();
    var response = JsonRpcResponse(
      id: pRequest.id,
      jsonrpc: '2.0',
    );
    if (approved) {
      response = response.copyWith(
          result: '0xE2BE444EF66780A7D5b5A81604229935B99823FA');
      _web3Wallet!.respondSessionRequest(
        topic: topic,
        response: response,
      );
    }
  }

  Future<void> ethSign(String topic, dynamic parameters) async {
    debugPrint('[$runtimeType] ethSign request: $parameters');
  }

  Future<void> ethSignTypedData(String topic, dynamic parameters) async {
    debugPrint('[$runtimeType] ethSignTypedData request: $parameters');
  }

  Future<void> ethSignTypedDataV4(String topic, dynamic parameters) async {
    debugPrint('[$runtimeType] ethSignTypedDataV4 request: $parameters');
  }

  Future<void> ethSignTransaction(String topic, dynamic parameters) async {
    debugPrint('[$runtimeType] ethSignTransaction request: $parameters');
  }

  Future<void> ethSendTransaction(String topic, dynamic parameters) async {
    debugPrint('[$runtimeType] ethSendTransaction request: $parameters');
  }

  Future<void> switchChain(String topic, dynamic parameters) async {
    debugPrint('received switchChain request: $topic $parameters');
  }

  Future<void> addChain(String topic, dynamic parameters) async {
    debugPrint('received addChain request: $topic $parameters');
  }
}
