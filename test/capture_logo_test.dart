import 'dart:io';
import 'dart:ui' as ui;
import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:myexpense/shared/widgets/hand_and_bag_logo.dart';

void main() {
  testWidgets('Capture Hand and Bag Logo', (WidgetTester tester) async {
    final boundaryKey = GlobalKey();

    // Use a MaterialApp and keep size constraints to render the logo beautifully
    await tester.pumpWidget(
      MaterialApp(
        debugShowCheckedModeBanner: false,
        theme: ThemeData(fontFamily: 'Roboto'),
        home: Scaffold(
          backgroundColor: Colors.white,
          body: Center(
            child: RepaintBoundary(
              key: boundaryKey,
              child: Container(
                color: Colors.white,
                padding: const EdgeInsets.all(24),
                child: const HandAndBagLogo(size: 200),
              ),
            ),
          ),
        ),
      ),
    );

    // Wait for the asset image (hand.png) to be fully loaded and painted
    await tester.pumpAndSettle();
    await Future.delayed(const Duration(milliseconds: 500));
    await tester.pump();

    final RenderRepaintBoundary boundary =
        boundaryKey.currentContext!.findRenderObject() as RenderRepaintBoundary;
    final ui.Image image = await boundary.toImage(pixelRatio: 4.0);
    final byteData = await image.toByteData(format: ui.ImageByteFormat.png);
    final pngBytes = byteData!.buffer.asUint8List();

    final outDir = Directory('c:/Users/ARPI/.gemini/antigravity/brain/66825713-30e8-47e6-83ec-8620e984e033');
    if (!outDir.existsSync()) {
      outDir.createSync(recursive: true);
    }

    final file = File('${outDir.path}/exact_hand_and_bag_logo.png');
    await file.writeAsBytes(pngBytes);
    print('Saved exact logo to: ${file.path}');
  });
}
