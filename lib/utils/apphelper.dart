import 'package:flutter_blue_plus/flutter_blue_plus.dart';

class Apphelper {
  static BluetoothDevice? connectedDevice;
  static String? printerType;
  static int? shopid = 0;
  static bool? gsttype;

  totalgst(double rate, int cess, int gst, bool gstcount, int numberofcount) {
    double restrate = gstcount
        ? (rate - ((cess + gst) / (100 + cess + gst)) * rate)
        : rate.toDouble();
    // print("object restrate $restrate");
    // return restrate * numberofcount;
    return restrate;
  }
}
