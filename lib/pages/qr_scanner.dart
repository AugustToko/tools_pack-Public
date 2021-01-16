/*
 * Project: tools_pack Public
 * Module: toolspack
 * Last Modified: 21-1-16 下午12:40
 * Copyright (c) 2021 August https://blog.geek-cloud.top/
 */

import 'package:flutter/material.dart';
import 'package:super_qr_reader/super_qr_reader.dart';

class QRScannerPage extends StatefulWidget {
  QRScannerPage({Key key}) : super(key: key);

  @override
  _QRScannerPageState createState() => new _QRScannerPageState();
}

class _QRScannerPageState extends State<QRScannerPage> {
  String result = '';

  var scanResult;

  @override
  void initState() {
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Package example app'),
      ),
      body: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 16),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: <Widget>[
            RaisedButton(
              onPressed: () async {
                String results = await Navigator.push(
                  // waiting for the scan results
                  context,
                  MaterialPageRoute(
                    builder: (context) => ScanView(), // open the scan view
                  ),
                );

                if (results != null) {
                  setState(() {
                    result = results;
                  });
                }
              },
              child: Text("扫码/tap to scan"),
            ),
            Text(result), // display the scan results
          ],
        ),
      ),
    );
  }
}
