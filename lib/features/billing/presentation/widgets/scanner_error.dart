import 'package:flutter/material.dart';
import 'package:mobile_scanner/mobile_scanner.dart';

Widget buildScannerError(BuildContext context, MobileScannerException error) {
  final message = error.errorCode == MobileScannerErrorCode.permissionDenied
      ? 'Concede el permiso de cámara para escanear códigos de barras.'
      : 'No se pudo iniciar la cámara.';

  return ColoredBox(
    color: Colors.black,
    child: Center(
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 24),
        child: Text(
          message,
          textAlign: TextAlign.center,
          style: const TextStyle(color: Colors.white),
        ),
      ),
    ),
  );
}
