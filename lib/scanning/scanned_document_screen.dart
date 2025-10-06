import 'dart:typed_data';
import 'package:flutter/material.dart';

class ScannedDocumentScreen extends StatelessWidget {
  final Uint8List scannedImageBytes;

  const ScannedDocumentScreen({super.key, required this.scannedImageBytes});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black,
      appBar: AppBar(
        title: const Text(
          "Scanned Document",
          style: TextStyle(color: Colors.white),
        ),
        backgroundColor: Colors.black,
        iconTheme: const IconThemeData(color: Colors.white),
      ),
      body: Center(child: Image.memory(scannedImageBytes, fit: BoxFit.contain)),
    );
  }
}
