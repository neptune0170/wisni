import 'dart:io';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:flutter/src/widgets/framework.dart';
import 'package:flutter/src/widgets/placeholder.dart';
import 'package:qr_code_scanner/qr_code_scanner.dart';

class QrCodeScanner extends StatefulWidget {
  const QrCodeScanner({super.key});

  @override
  State<QrCodeScanner> createState() => _QrCodeScannerState();
}

class _QrCodeScannerState extends State<QrCodeScanner> {
  final GlobalKey qrKey = GlobalKey(debugLabel: 'QR');
  Barcode? result;
  QRViewController? controller;

  @override
  void reassemble() {
    super.reassemble();
    if (Platform.isAndroid) {
      controller!.pauseCamera();
    } else if (Platform.isIOS) {
      controller!.resumeCamera();
    }
  }

  // final qrKey = GlobalKey(debugLabel: 'QR');
  // Barcode? barcode;
  // QRViewController? controller;

  // @override
  // void dispose() {
  //   controller?.dispose();
  //   super.dispose();
  // }

  // @override
  // void reassemble() async {
  //   super.reassemble();

  //   if (Platform.isAndroid) {
  //     await controller!.pauseCamera();
  //   }
  //   controller!.resumeCamera();
  // }

  String _docid = '6nd04S1UdBiTxHQsHS2y';
  String _name = '';
  Future<void> _fetchName() async {
    try {
      final snapshot = await FirebaseFirestore.instance
          .collection('address')
          .doc('${_docid}')
          .get();
      final data = snapshot.data() as Map<String, dynamic>;
      final name = data['name'] as String;
      setState(() {
        _name = name;
      });
    } catch (e) {
      print('Error fetching name: $e');
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Column(
        children: <Widget>[
          Expanded(
            flex: 5,
            child: QRView(
              key: qrKey,
              onQRViewCreated: _onQRViewCreated,
              overlay: QrScannerOverlayShape(
                borderColor: Colors.greenAccent,
                borderRadius: 10,
                borderLength: 20,
                borderWidth: 10,
                cutOutSize: MediaQuery.of(context).size.width * 0.8,
              ),
            ),
          ),
          Expanded(
            flex: 1,
            child: Center(
              child: (result != null && _name != "")
                  ? Text('Data: ${result!.code} name:$_name')
                  : Text('Scan a code'),
            ),
          )
        ],
      ),
    );
  }

  void _onQRViewCreated(QRViewController controller) {
    this.controller = controller;
    controller.scannedDataStream.listen((scanData) {
      setState(() {
        result = scanData;
      });
    });
    _fetchName();
  }

  @override
  void dispose() {
    controller?.dispose();
    super.dispose();
  }

  // return Scaffold(
  //     //   body: Stack(
  //     // alignment: Alignment.center,
  //     // children: [
  //     //   buildQrView(context),
  //     //   Positioned(bottom: 10, child: buildResult()),
  //     // ],
  //     //  )
  //     );
}

  // Widget buildResult() => Container(
  //       padding: EdgeInsets.all(12),
  //       decoration: BoxDecoration(
  //           color: Color.fromRGBO(255, 255, 255, 1),
  //           borderRadius: BorderRadius.circular(8)),
  //       child: Text(
  //         barcode != null ? 'Result : ${barcode!.code}' : 'Scan a Code!',
  //         maxLines: 3,
  //       ),
  //     );

  // Widget buildQrView(BuildContext context) => QRView(
  //       key: qrKey,
  //       onQRViewCreated: onQRViewCreated,
  //       overlay: QrScannerOverlayShape(
  //         borderColor: Colors.greenAccent,
  //         borderRadius: 10,
  //         borderLength: 20,
  //         borderWidth: 10,
  //         cutOutSize: MediaQuery.of(context).size.width * 0.8,
  //       ),
  //     );

  // void onQRViewCreated(QRViewController controller) {
  //   setState(() => this.controller = controller);

  //   controller.scannedDataStream
  //       .listen((barcode) => setState(() => this.barcode));
  // }
//}
