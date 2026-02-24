import 'package:flutter/foundation.dart';

class Utils {
  static void dPrint(Object? object) {
    if (kDebugMode) {
      print(object);
    }
  }
}
