import 'dart:io';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';

import 'package:qr_code_scanner/qr_code_scanner.dart';
import 'package:wsini/pages/navigatedPage.dart';

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

  void showAlertDialog(BuildContext context) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: Text('Alert'),
          content: Text('Alert message'),
          actions: <Widget>[
            TextButton(
              onPressed: () {
                Navigator.of(context).pop();
              },
              child: Text('OK'),
            ),
          ],
        );
      },
    );
  }

  // String _docid = '6nd04S1UdBiTxHQsHS2y';
  String? _name;
  late final members;

  final currentUserId = 'GtLj1cV33YgwNgcWJFASWmqrI1a2';
  void fetchData(docid) {
    Future<void> _fetchName(docid) async {
      try {
        final snapshot = await FirebaseFirestore.instance
            .collection('address')
            .doc(docid)
            .get();
        final data = snapshot.data() as Map<String, dynamic>;
        members = data['members'] as List<dynamic>;
        final name = data['name'] as String;
        setState(() {
          _name = name;
        });
      } catch (e) {
        print('Error fetching name: $e');
      }
    }

    _fetchName(docid).then((value) {
      final isCurrentUserMember = members.contains(currentUserId);

      if (_name != null && !isCurrentUserMember) {
        Navigator.pushReplacement(
            context, MaterialPageRoute(builder: (_) => NotAuthenticatedUser()));
      }
      if (isCurrentUserMember) {
        // Handle the case where currentUserId is present in members
        Navigator.pushReplacement(
            context, MaterialPageRoute(builder: (_) => NewPage()));
      } else {
        // Handle the case where currentUserId is not present in members
        Navigator.pushReplacement(
            context, MaterialPageRoute(builder: (_) => NotAuthenticatedUser()));
      }
    });
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
              child: (result != null)
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
    String doc_id = '';
    controller.scannedDataStream.listen((scanData) async {
      setState(() {
        result = scanData;
        doc_id = result!.code!;
        // _fetchName(doc_id);
      });
      fetchData(doc_id);
    });
  }

  @override
  void dispose() {
    controller?.dispose();
    super.dispose();
  }
}
