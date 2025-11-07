// lib/qr_scanner_view.dart (Final Correction without formats parameter)

import 'package:flutter/material.dart';
import 'package:mobile_scanner/mobile_scanner.dart';

class QrScannerView extends StatelessWidget {
  const QrScannerView({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Scan QR Code'),
        backgroundColor: const Color(0xff261350),
        foregroundColor: Colors.white,
      ),
      body: MobileScanner(
        // 🚀 FINAL FIX: Removing the 'formats' parameter entirely.
        // MobileScanner defaults to scanning all supported codes, including QR.
        onDetect: (BarcodeCapture capture) {
          final List<Barcode> barcodes = capture.barcodes;
          if (barcodes.isNotEmpty) {
            final String scannedData = barcodes.first.rawValue ?? '';

            // Return the scanned data back to the ScannedBadgesScreen
            Navigator.pop(context, scannedData);
          }
        },
      ),
    );
  }
}