import 'package:flutter/material.dart';
import 'package:qr_flutter/qr_flutter.dart';

class QRImage extends StatelessWidget {
  final String sign_in_time;

  const QRImage(this.sign_in_time, {Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Flutter + QR code'),
        centerTitle: true,
      ),
      body: Center(
        child: QrImage(
          data:
              sign_in_time, // Use the sign_in_time string directly as the data.
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
