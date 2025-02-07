import 'dart:io';
import 'dart:typed_data';
import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';
import 'package:path_provider/path_provider.dart';
import 'package:share_plus/share_plus.dart';

class DetailImagePage extends StatelessWidget {
  final Uint8List imageBytes;

   DetailImagePage({Key? key, required this.imageBytes}) : super(key: key);

   final GlobalKey _globalKey = GlobalKey();

  // Function to capture widget and convert it to image

Future<void> _captureAndShare(BuildContext context) async {
  try {
    WidgetsBinding.instance.addPostFrameCallback((_) async {
      if (_globalKey.currentContext != null) {
        RenderRepaintBoundary boundary = _globalKey.currentContext!
            .findRenderObject() as RenderRepaintBoundary;
        var image = await boundary.toImage(pixelRatio: 3.0);
        ByteData? byteData = await image.toByteData(format: ImageByteFormat.png);
        Uint8List uint8List = byteData!.buffer.asUint8List();

        // Save image to temporary directory
        final directory = await getTemporaryDirectory();
        final file = File(
            '${directory.path}/captured_image_${DateTime.now().millisecondsSinceEpoch}.png');
        await file.writeAsBytes(uint8List);

        // Use XFile to share the image
        final xFile = XFile(file.path);
        final result = await Share.shareXFiles([xFile], text: 'Text bisa di custom');
        if (result != null) {
          print("Image shared successfully!");
        } else {
          print("Sharing failed");
        }
      } else {
        print("Error: GlobalKey context is null");
      }
    });
  } catch (e) {
    print('Error capturing and sharing the image: $e');
  }
}

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      
      appBar: AppBar(
        title: const Text('Detail Image'),
        titleTextStyle: const TextStyle(color: Colors.white, fontSize: 20, fontWeight: FontWeight.bold),
        backgroundColor: Colors.black,
        elevation: 0,
        centerTitle: true,
        iconTheme: const IconThemeData(color: Colors.white),
      ),
      backgroundColor: Colors.black,
      body: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Expanded(
           child: Center(
              child: RepaintBoundary(
                key: _globalKey, // 🔹 Tambahkan RepaintBoundary dengan GlobalKey
                child: Image.memory(
                  imageBytes,
                  fit: BoxFit.contain,
                ),
              ),
            ),
          ),  
          Padding(
            padding: const EdgeInsets.all(16.0),
            child: ElevatedButton.icon(
              onPressed: () async {
                await _captureAndShare(context);
              },
              icon: const Icon(Icons.share),
              label: const Text('Share'),
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.black,
                foregroundColor: Colors.white,
                padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 24),
              ),
            ),
          ),
        ],
      ),
    );
  }
}