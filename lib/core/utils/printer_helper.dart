import 'package:intl/intl.dart';
import 'package:print_bluetooth_thermal/print_bluetooth_thermal.dart';
import 'package:permission_handler/permission_handler.dart';

import 'sol_currency.dart';

class EscPos {
  static const List<int> init = [0x1B, 0x40];
  static const List<int> selectWindows1252 = [0x1B, 0x74, 16];
  static const List<int> alignCenter = [0x1B, 0x61, 0x01];
  static const List<int> alignLeft = [0x1B, 0x61, 0x00];
  static const List<int> alignRight = [0x1B, 0x61, 0x02];
  static const List<int> boldOn = [0x1B, 0x45, 0x01];
  static const List<int> boldOff = [0x1B, 0x45, 0x00];
  static const List<int> textNormal = [0x1D, 0x21, 0x00];
  static const List<int> textLarge = [0x1D, 0x21, 0x11];
  static const List<int> lineFeed = [0x0A];
}

class PrinterHelper {
  // Singleton
  static final PrinterHelper _instance = PrinterHelper._internal();
  factory PrinterHelper() => _instance;
  PrinterHelper._internal();

  bool _isConnected = false;
  bool get isConnected => _isConnected;

  Future<bool> checkPermission() async {
    // Request Bluetooth and Location permissions
    // Android 12+ needs BLUETOOTH_SCAN, BLUETOOTH_CONNECT
    // Older Android needs BLUETOOTH, BLUETOOTH_ADMIN, ACCESS_FINE_LOCATION

    Map<Permission, PermissionStatus> statuses = await [
      Permission.bluetooth,
      Permission.bluetoothScan,
      Permission.bluetoothConnect,
      Permission.location,
    ].request();

    return statuses.values.every((status) => status.isGranted);
  }

  Future<List<BluetoothInfo>> getBondedDevices() async {
    try {
      final List<BluetoothInfo> list =
          await PrintBluetoothThermal.pairedBluetooths;
      return list;
    } catch (e) {
      return [];
    }
  }

  Future<bool> connect(String macAddress) async {
    try {
      final bool result =
          await PrintBluetoothThermal.connect(macPrinterAddress: macAddress);
      _isConnected = result;
      return result;
    } catch (e) {
      _isConnected = false;
      return false;
    }
  }

  Future<bool> disconnect() async {
    try {
      final bool result = await PrintBluetoothThermal.disconnect;
      _isConnected =
          !result; // If disconnected successfully, isConnected is false
      return result;
    } catch (e) {
      return false;
    }
  }

  Future<void> printText(String text) async {
    if (!_isConnected) return;

    final bool connectionStatus = await PrintBluetoothThermal.connectionStatus;
    if (connectionStatus) {
      await PrintBluetoothThermal.writeBytes([
        ...EscPos.init,
        ...EscPos.selectWindows1252,
        ..._textToBytes(text),
      ]);
    }
  }

  Future<void> printReceipt({
    required String shopName,
    required String address1,
    required String address2,
    required String phone,
    required List<Map<String, dynamic>> items, // Name, Qty, Price, Total
    required double total,
    required String footer,
  }) async {
    if (!_isConnected) return;

    final bytes = buildReceipt(
      shopName: shopName,
      address1: address1,
      address2: address2,
      phone: phone,
      items: items,
      total: total,
      footer: footer,
      issuedAt: DateTime.now(),
    );
    await PrintBluetoothThermal.writeBytes(bytes);
  }

  static List<int> buildReceipt({
    required String shopName,
    required String address1,
    required String address2,
    required String phone,
    required List<Map<String, dynamic>> items,
    required double total,
    required String footer,
    required DateTime issuedAt,
  }) {
    final bytes = <int>[];

    // Init
    bytes.addAll(EscPos.init);
    bytes.addAll(EscPos.selectWindows1252);

    // Shop Name (Center, Bold, Large)
    bytes.addAll(EscPos.alignCenter);
    bytes.addAll(EscPos.boldOn);
    bytes.addAll(EscPos.textLarge);
    bytes.addAll(_textToBytes(shopName));
    bytes.addAll(EscPos.lineFeed);

    // Address & Phone (Normal, Center)
    bytes.addAll(EscPos.textNormal);
    bytes.addAll(EscPos.boldOff);
    if (address1.isNotEmpty) {
      bytes.addAll(_textToBytes(address1));
      bytes.addAll(EscPos.lineFeed);
    }
    if (address2.isNotEmpty) {
      bytes.addAll(_textToBytes(address2));
      bytes.addAll(EscPos.lineFeed);
    }
    bytes.addAll(_textToBytes(phone));
    bytes.addAll(EscPos.lineFeed);

    // Date and Time
    final formattedDate = DateFormat('dd/MM/yyyy HH:mm').format(issuedAt);
    bytes.addAll(_textToBytes(formattedDate));
    bytes.addAll(EscPos.lineFeed);

    bytes.addAll(_textToBytes('--------------------------------'));
    bytes.addAll(EscPos.lineFeed);

    // Header (Align Left)
    bytes.addAll(EscPos.alignLeft);
    bytes.addAll(_textToBytes('Producto'));
    bytes.addAll(EscPos.lineFeed);
    bytes.addAll(
        _textToBytes('Precio unit.'.padLeft(16) + 'Importe'.padLeft(16)));
    bytes.addAll(EscPos.lineFeed);
    bytes.addAll(_textToBytes('--------------------------------'));
    bytes.addAll(EscPos.lineFeed);

    // Items
    for (final item in items) {
      final price = SolCurrency.format(item['price'] as num);
      final subtotal = SolCurrency.format(item['total'] as num);
      bytes.addAll(_textToBytes("${item['qty']}x ${item['name']}"));
      bytes.addAll(EscPos.lineFeed);
      bytes.addAll(_textToBytes(price.padLeft(16) + subtotal.padLeft(16)));
      bytes.addAll(EscPos.lineFeed);
    }

    bytes.addAll(_textToBytes('--------------------------------'));
    bytes.addAll(EscPos.lineFeed);

    // Total (Align Right)
    bytes.addAll(EscPos.alignRight);
    bytes.addAll(EscPos.boldOn);
    bytes.addAll(_textToBytes('TOTAL ${SolCurrency.format(total)}'));
    bytes.addAll(EscPos.lineFeed);
    bytes.addAll(EscPos.boldOff);
    bytes.addAll(EscPos.lineFeed);

    // Footer (Center)
    bytes.addAll(EscPos.alignCenter);
    bytes.addAll(_textToBytes(footer));
    bytes.addAll(EscPos.lineFeed);
    bytes.addAll(EscPos.lineFeed); // One line space after footer
    bytes.addAll(EscPos.lineFeed);
    bytes.addAll(EscPos.lineFeed); // Additional Feed

    return bytes;
  }

  static List<int> _textToBytes(String text) {
    // The Spanish characters in Latin-1 use the same bytes in Windows-1252.
    return text.runes.map((rune) => rune <= 0xFF ? rune : 0x3F).toList();
  }
}
