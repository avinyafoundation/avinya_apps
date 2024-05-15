import 'package:flutter/material.dart';
import 'package:qr_flutter/qr_flutter.dart';

class QRImage extends StatelessWidget {
  final String data;

  const QRImage(this.data, {Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('QR code',style: TextStyle(color: Colors.black)),
        centerTitle: true,
        backgroundColor: Color.fromARGB(255, 236, 230, 253),
        iconTheme: IconThemeData(color: Colors.black),
      ),
      body: Center(
        child: QrImage(
          data: data, // Use the sign_in_time string directly as the data.
          size: 280,
          // You can include embeddedImageStyle Property if you
          // wanna embed an image from your Asset folder
          embeddedImageStyle: QrEmbeddedImageStyle(
            size: const Size(
              100,
              100,
            ),
          ),
        ),
      ),
    );
  }
}
