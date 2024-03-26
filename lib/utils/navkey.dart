import 'package:flutter/material.dart';

class NavKey {
  static final navKey = GlobalKey<NavigatorState>();

  static BuildContext getContext() {
    return navKey.currentContext!;
  }
}
