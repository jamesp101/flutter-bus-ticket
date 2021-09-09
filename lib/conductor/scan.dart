import 'dart:io';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:flutter_easyloading/flutter_easyloading.dart';

import 'package:qr_code_scanner/qr_code_scanner.dart';

class ScanPage extends StatefulWidget {
  ScanPage({Key? key}) : super(key: key);

  @override
  _ScanPageState createState() => _ScanPageState();
}

class _ScanPageState extends State<ScanPage> {
  final qrKey = GlobalKey(debugLabel: 'QR');
  late QRViewController controller;

  final manualController = TextEditingController();

  bool isCameraOn = false;
  @override
  void reassemble() {
    super.reassemble();
    controller.pauseCamera();
  }

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: EdgeInsets.all(12),
      child: Column(
        children: [setPage()],
      ),
    );
  }

  Widget setPage() {
    if (isCameraOn) {
      return setCameraWidget();
    } else {
      return setButtonWidget();
    }
  }

  Widget setCameraWidget() {
    return Expanded(
        flex: 5,
        child: QRView(
          key: qrKey,
          onQRViewCreated: _onQRviewCreated,
        ));
  }

  Widget setButtonWidget() {
    return Column(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        SizedBox(
          height: 60,
          width: double.infinity,
          child: ElevatedButton(
            child: Text('Scan'),
            onPressed: () {
              setState(() {
                isCameraOn = true;
              });
            },
          ),
        ),
        SizedBox(
          height: 60,
          width: double.infinity,
          child: TextButton(
            child: Text('Manual'),
            onPressed: () {
              manualTicket();
            },
          ),
        ),
      ],
    );
  }

  void _onQRviewCreated(QRViewController controller) {
    this.controller = controller;

    controller.scannedDataStream.listen((Barcode scanData) async {
      controller.pauseCamera();

      if (await ticketIsOk(scanData.code)) {
        showDialog(
            context: context,
            builder: (context) => AlertDialog(
                  title: Text('Confirm this ticket?'),
                  content: Column(
                    crossAxisAlignment: CrossAxisAlignment.center,
                    children: [
                      Text('Confirm this ticket?'),
                      Text('ID: ${scanData.code}')
                    ],
                  ),
                  actions: [
                    TextButton(
                        child: Text('Cancel'),
                        onPressed: () {
                          setState(() {
                            Navigator.pop(
                              context,
                            );
                            isCameraOn = false;
                          });
                        }),
                    TextButton(
                        child: Text('OK'),
                        onPressed: () async {
                          await updateTicket(scanData.code);
                          setState(() {
                            isCameraOn = false;
                            Navigator.pop(
                              context,
                            );
                          });
                        }),
                  ],
                ));
      } else {
        setState(() {
          this.isCameraOn = false;
        });
      }
    });
  }

  @override
  void dispose() {
    controller.dispose();
    super.dispose();
  }

  Future<bool> ticketIsOk(String id) async {
    EasyLoading.show(status: 'Processing');
    var ticket =
        await FirebaseFirestore.instance.collection('tickets').doc(id).get();

    if (!ticket.exists) {
      EasyLoading.showError('Ticket does not exist.');
      return false;
    }

    if (ticket.data()!['status'] == 'Used') {
      EasyLoading.showError('Success');
      return false;
    } else {
      EasyLoading.showSuccess('Ticket is already used');
      return false;
    }
  }

  Future<bool> updateTicket(String id) async {
    EasyLoading.show(status: 'Processing');
    try {
      await FirebaseFirestore.instance
          .collection('tickets')
          .doc(id)
          .update({'status': 'Used'});
      EasyLoading.dismiss();
      EasyLoading.showSuccess('Success');
      return true;
    } catch (error) {
      EasyLoading.dismiss();
      print(error);
      EasyLoading.showError(error.toString());
      return false;
    }
  }

  void manualTicket() {
    showDialog(
        context: context,
        builder: (BuildContext context) => AlertDialog(
              title: Text('Input Ticket'),
              content: TextFormField(
                controller: manualController,
                decoration: InputDecoration(
                    labelText: 'Password',
                    border: OutlineInputBorder(),
                    prefixIcon: Icon(Icons.airplane_ticket)),
              ),
              actions: [
                TextButton(
                    child: Text('Cancel'),
                    onPressed: () {
                      setState(() {
                        Navigator.pop(
                          context,
                        );
                      });
                    }),
                TextButton(
                    child: Text('OK'),
                    onPressed: () async {
                      if (await ticketIsOk(manualController.text)) {
                        await updateTicket(manualController.text);
                      }
                    }),
              ],
            ));
  }
}
