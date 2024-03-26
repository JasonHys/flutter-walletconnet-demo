import 'package:flutter/material.dart';
import 'package:walletconnect/utils/navkey.dart';
import 'package:walletconnect/utils/web_wallet_service.dart';
import 'package:walletconnect_flutter_v2/apis/core/pairing/utils/pairing_models.dart';
import 'package:walletconnect_flutter_v2/apis/sign_api/models/proposal_models.dart';
import 'package:walletconnect_flutter_v2/apis/sign_api/models/session_models.dart';
import 'package:walletconnect_flutter_v2/apis/sign_api/models/sign_client_events.dart';
import 'package:walletconnect_flutter_v2/apis/sign_api/sign_client.dart';
import 'package:walletconnect_flutter_v2/apis/web3wallet/web3wallet.dart';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  // This widget is the root of your application.
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Flutter Demo',
      navigatorKey: NavKey.navKey,
      theme: ThemeData(
        // This is the theme of your application.
        //
        // TRY THIS: Try running your application with "flutter run". You'll see
        // the application has a purple toolbar. Then, without quitting the app,
        // try changing the seedColor in the colorScheme below to Colors.green
        // and then invoke "hot reload" (save your changes or press the "hot
        // reload" button in a Flutter-supported IDE, or press "r" if you used
        // the command line to start the app).
        //
        // Notice that the counter didn't reset back to zero; the application
        // state is not lost during the reload. To reset the state, use hot
        // restart instead.
        //
        // This works for code too, not just values: Most code changes can be
        // tested with just a hot reload.
        colorScheme: ColorScheme.fromSeed(seedColor: Colors.deepPurple),
        useMaterial3: true,
      ),
      home: MyHomePage(title: 'Flutter Demo Home Page'),
    );
  }
}

class MyHomePage extends StatefulWidget {
  MyHomePage({super.key, required this.title});
  String title;

  @override
  State<MyHomePage> createState() => _MyHomePageState();
}

class _MyHomePageState extends State<MyHomePage> {
  List<PairingInfo> list = [];

  @override
  void initState() {
    super.initState();
  }

  onPair() async {
    String key =
        'wc:86c69700226ca5647c08d985f330a7a56fe841096aa9e9d71b767e3b050a9ed9@2?expiryTimestamp=1709880780&relay-protocol=irn&symKey=0c0905d99b9a81b00fbfccd1905d452ee3fb337ebceff6110e38842678b075e8';
    await Web3WalletService.onPair(key);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Theme.of(context).colorScheme.inversePrimary,
        title: Text(widget.title),
      ),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: <Widget>[
            const Text(
              'You have pushed the button this many times:',
            ),
            if (list.isNotEmpty)
              Container(
                height: 400,
                child: ListView.builder(
                  itemCount: list.length,
                  itemBuilder: (e, index) {
                    if (list[index].peerMetadata != null) {
                      return Column(
                        children: [
                          Text('$index'),
                          Text('${list![index].peerMetadata!.name}'),
                          Text('${list![index].peerMetadata!.url}'),
                          TextButton(
                              onPressed: () {
                                String key = list![index].topic;
                                Web3WalletService.onClose(key);
                              },
                              child: Text('断开连接')),
                          SizedBox(
                            height: 30,
                          )
                        ],
                      );
                    }
                  },
                ),
              ),
            Text(
              '132456',
              style: Theme.of(context).textTheme.headlineMedium,
            ),
          ],
        ),
      ),
      floatingActionButton: Row(
        children: [
          SizedBox(
            width: 50,
          ),
          FloatingActionButton(
            onPressed: () async {
              Web3WalletService web3walletService = Web3WalletService();
              await web3walletService.create();
              List<PairingInfo> list1 = Web3WalletService.getPair();
              setState(() {
                list = list1;
                widget.title = '1222';
              });
            },
            tooltip: 'Increment',
            child: const Icon(Icons.abc),
          ),
          SizedBox(
            width: 50,
          ),
          FloatingActionButton(
            onPressed: () {
              onPair();
            },
            tooltip: 'Increment',
            child: const Icon(Icons.qr_code_rounded),
          ),
          SizedBox(
            width: 50,
          ),
          FloatingActionButton(
            onPressed: () {
              List<PairingInfo> list1 = Web3WalletService.getPair();
              Web3WalletService.getsseion();
              setState(() {
                list = list1;
                widget.title = '1223';
              });
            },
            tooltip: 'Increment',
            child: const Icon(Icons.ac_unit_outlined),
          )
        ],
      ), // This trailing comma makes auto-formatting nicer for build methods.
    );
  }
}
