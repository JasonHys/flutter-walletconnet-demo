import 'package:flutter/material.dart';
import 'package:walletconnect/utils/navkey.dart';

class DialogUtils {
  static Future<bool> showDialog() async {
    bool yes = await showModalBottomSheet(
        context: NavKey.getContext(),
        builder: (BuildContext context) {
          return Center(
            child: Column(
              children: [
                const Text('0xE2BE444EF66780A7D5b5A81604229935B99823FA'),
                Row(
                  children: [
                    InkWell(
                      onTap: () {
                        Navigator.of(context).pop(false);
                      },
                      child: const Text('取消'),
                    ),
                    const SizedBox(
                      width: 50,
                    ),
                    InkWell(
                      onTap: () {
                        Navigator.of(context).pop(true);
                      },
                      child: const Text('确定'),
                    )
                  ],
                )
              ],
            ),
          );
        });
    return yes;
  }
}
