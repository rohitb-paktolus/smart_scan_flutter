import 'dart:io';
import 'package:flutter/material.dart';
import 'package:opencv_dart/opencv_dart.dart' as cv;
import 'package:flutter/services.dart';
import 'package:smart_scan_flutter/scanning/scanned_document_screen.dart';

class ImagePreviewScreen extends StatefulWidget {
  final String imagePath;

  const ImagePreviewScreen({super.key, required this.imagePath});

  @override
  State<ImagePreviewScreen> createState() => _ImagePreviewScreenState();
}

class _ImagePreviewScreenState extends State<ImagePreviewScreen> {
  static const double _FALLBACK_PADDING_RATIO = 0.05;
  late File _imageFile;
  bool _isProcessing = true;
  List<Offset> _corners = [];
  late Uint8List _imageBytes;
  Size _imageSize = Size.zero;
  int? _activeCornerIndex;

  @override
  void initState() {
    super.initState();
    _imageFile = File(widget.imagePath);
    _loadImageAndDetectEdges();
  }

  // Utility to sort the 4 corners consistently (TL, TR, BR, BL)
  List<Offset> _sortCorners(List<Offset> corners) {
    if (corners.length != 4) return corners;

    // 1. Calculate the center of the quadrilateral (not used for sorting, but good check)
    // final centerX = corners.map((c) => c.dx).reduce((a, b) => a + b) / 4;
    // final centerY = corners.map((c) => c.dy).reduce((a, b) => a + b) / 4;

    // 2. Sort based on position relative to the center
    List<Offset> sorted = corners.toList();

    // Sort by Y-coordinate first (approximate Top vs Bottom)
    sorted.sort((a, b) => a.dy.compareTo(b.dy));

    List<Offset> top = sorted.sublist(0, 2);
    List<Offset> bottom = sorted.sublist(2, 4);

    // Sort top and bottom groups by X-coordinate (Left vs Right)
    top.sort((a, b) => a.dx.compareTo(b.dx));
    bottom.sort((a, b) => a.dx.compareTo(b.dx));

    // The final order is TL, TR, BR, BL
    return [top[0], top[1], bottom[1], bottom[0]];
  }

  Future<void> _loadImageAndDetectEdges() async {
    setState(() {
      _isProcessing = true;
    });

    try {
      _imageBytes = await _imageFile.readAsBytes();
      final image = await decodeImageFromList(_imageBytes);
      final originalImageSize = Size(
        image.width.toDouble(),
        image.height.toDouble(),
      );
      _imageSize = originalImageSize;

      final mat = cv.imread(widget.imagePath, flags: cv.IMREAD_COLOR);
      final grayMat = cv.cvtColor(mat, cv.COLOR_BGR2GRAY);

      // --- 1. MASK 1: Adaptive Thresholding (Detects dark objects) ---
      // This is robust for dark text/objects on lighter backgrounds (like the book)
      final threshInv = cv.adaptiveThreshold(
        grayMat,
        255,
        cv.ADAPTIVE_THRESH_GAUSSIAN_C,
        cv.THRESH_BINARY_INV, // Dark object becomes white blob
        31,
        15,
      );

      // --- 2. MASK 2: Canny Edge Detection (Detects screen edges, high contrast paper) ---
      // We'll blur the grayscale image first for clean edges
      final blurred = cv.gaussianBlur(grayMat, (5, 5), 0);

      // Adjust Canny thresholds based on testing (75 and 200 are decent starting points)
      final edges = cv.canny(blurred, 75, 200);

      // --- 3. COMBINE MASKS ---
      // Use a Bitwise OR operation to combine the two masks.
      // A pixel is white (part of a contour) if it was detected by EITHER thresholding OR Canny.
      final combinedMask = await cv.bitwiseOR(threshInv, edges);

      // --- 4. MORPHOLOGICAL OPERATIONS: Clean up the combined mask ---
      // Use a larger kernel and more iterations for aggressive cleanup on the complex combined mask.
      final kernel = cv.getStructuringElement(cv.MORPH_RECT, (
        7,
        7,
      )); // Larger kernel
      final dilatedMat = cv.dilate(
        combinedMask,
        kernel,
        iterations: 2,
      ); // More dilation
      final erodedMat = cv.erode(
        dilatedMat,
        kernel,
        iterations: 1,
      ); // Cleanup erosion

      // Use the cleaned mask (erodedMat) for contour finding
      final contoursResult = cv.findContours(
        erodedMat,
        cv.RETR_EXTERNAL,
        cv.CHAIN_APPROX_SIMPLE,
      );
      final (contours, _) = contoursResult;

      List<Offset> documentCorners = [];
      double maxArea = 0;

      // Sort contours by area in descending order
      final sortedContours =
          contours.toList()..sort((a, b) {
            final areaA = cv.contourArea(a);
            final areaB = cv.contourArea(b);
            return areaB.compareTo(areaA);
          });

      // Iterate over a decent number of largest contours
      for (int i = 0; i < sortedContours.length && i < 10; i++) {
        final contour = sortedContours[i];
        final perimeter = cv.arcLength(contour, true);

        final epsilon = 0.04 * perimeter;

        final approx = cv.approxPolyDP(contour, epsilon, true);

        if (approx.length == 4) {
          final area = cv.contourArea(approx);
          final totalImageArea =
              originalImageSize.width * originalImageSize.height;

          // Check for significant area
          if (area > maxArea && area > totalImageArea * 0.15) {
            maxArea = area;

            documentCorners =
                approx.map<Offset>((point) {
                  final x = (point.x).toDouble();
                  final y = (point.y).toDouble();
                  return Offset(x, y);
                }).toList();

            // Apply the essential sorting routine
            documentCorners = _sortCorners(documentCorners);
            break;
          }
        }
      }

      // --- FALLBACK LOGIC ---
      if (documentCorners.isEmpty) {
        // Determine the padding value based on a small ratio of the shorter side
        final paddingValue =
            _imageSize.width < _imageSize.height
                ? _imageSize.width * _FALLBACK_PADDING_RATIO
                : _imageSize.height * _FALLBACK_PADDING_RATIO;

        // If no suitable quadrilateral was found, use the entire image boundary
        documentCorners = [
          Offset(paddingValue, paddingValue),
          Offset(_imageSize.width - paddingValue, paddingValue),
          Offset(
            _imageSize.width - paddingValue,
            _imageSize.height - paddingValue,
          ),
          Offset(paddingValue, _imageSize.height - paddingValue),
        ];
        // NOTE: The corners are already in the correct order (TL, TR, BR, BL)

        debugPrint(
          "No document contour found. Defaulting to padded full image bounds.",
        );
      }

      setState(() {
        _corners = documentCorners;
        _isProcessing = false;
      });
    } catch (e) {
      debugPrint("OpenCV document detection failed: $e");
      setState(() {
        _isProcessing = false;
      });
    }
  }

  // Helper function to map screen position to original image coordinates
  Offset _screenToImageCoords(Offset screenPoint, Size displaySize) {
    if (_imageSize == Size.zero) return screenPoint;

    final originalRatio = _imageSize.width / _imageSize.height;
    final displayRatio = displaySize.width / displaySize.height;

    double scale;
    Offset offset;

    if (originalRatio > displayRatio) {
      scale = displaySize.width / _imageSize.width;
      final scaledHeight = _imageSize.height * scale;
      offset = Offset(0, (displaySize.height - scaledHeight) / 2);
    } else {
      scale = displaySize.height / _imageSize.height;
      final scaledWidth = _imageSize.width * scale;
      offset = Offset((displaySize.width - scaledWidth) / 2, 0);
    }

    // Inverse scale and translation
    final imageX = (screenPoint.dx - offset.dx) / scale;
    final imageY = (screenPoint.dy - offset.dy) / scale;

    // Clamp values to stay within image bounds
    final clampedX = imageX.clamp(0.0, _imageSize.width);
    final clampedY = imageY.clamp(0.0, _imageSize.height);

    return Offset(clampedX, clampedY);
  }

  void _handlePanStart(DragStartDetails details, Size displaySize) {
    // Check if the touch is near any corner marker (in screen coordinates)
    const double hitRadius = 25.0; // Margin of error for tap target

    // Convert the original corners to their current screen positions
    final cornerPainter = DocumentBoxPainter(
      corners: _corners,
      originalImageSize: _imageSize,
      displaySize: displaySize,
      activeCornerIndex: null,
    );
    final List<Offset> screenCorners = cornerPainter.getScreenCorners();

    int? bestMatchIndex;
    for (int i = 0; i < screenCorners.length; i++) {
      final distance = (screenCorners[i] - details.localPosition).distance;
      if (distance < hitRadius) {
        bestMatchIndex = i;
        break;
      }
    }

    setState(() {
      _activeCornerIndex = bestMatchIndex;
    });
  }

  void _handlePanUpdate(DragUpdateDetails details, Size displaySize) {
    if (_activeCornerIndex != null) {
      // Get the new position in original image coordinates
      final newImagePosition = _screenToImageCoords(
        details.localPosition,
        displaySize,
      );

      setState(() {
        // Update the corner position
        _corners[_activeCornerIndex!] = newImagePosition;
      });
    }
  }

  void _handlePanEnd() {
    if (_activeCornerIndex != null) {
      setState(() {
        // Re-sort the corners after the drag is complete
        // This ensures the polygon path remains correct (TL, TR, BR, BL)
        _corners = _sortCorners(_corners);
        _activeCornerIndex = null;
      });
    }
  }

  Future<void> _processAndCropDocument() async {
    if (_corners.length != 4 || _imageSize == Size.zero) return;

    // --- 1. CALCULATE DYNAMIC OUTPUT SIZE ---
    // Calculate the width and height of the resulting rectangle based on the adjusted corners.
    // The corners are sorted: TL(0), TR(1), BR(2), BL(3).

    // Width is the average of the top and bottom edge lengths
    final topWidth = (_corners[1] - _corners[0]).distance;
    final bottomWidth = (_corners[2] - _corners[3]).distance;
    final outputWidth = ((topWidth + bottomWidth) / 2).toInt();

    // Height is the average of the left and right edge lengths
    final leftHeight = (_corners[3] - _corners[0]).distance;
    final rightHeight = (_corners[2] - _corners[1]).distance;
    final outputHeight = ((leftHeight + rightHeight) / 2).toInt();

    // Safety check: ensure min size (though corners should prevent 0)
    if (outputWidth <= 0 || outputHeight <= 0) return;

    // 2. Read the original image into a Mat
    final mat = await cv.imdecodeAsync(_imageBytes, cv.IMREAD_COLOR);

    // 3. Define the source points (current corners in the Mat)
    final srcPointsList = [
      cv.Point(_corners[0].dx.toInt(), _corners[0].dy.toInt()), // TL
      cv.Point(_corners[1].dx.toInt(), _corners[1].dy.toInt()), // TR
      cv.Point(_corners[2].dx.toInt(), _corners[2].dy.toInt()), // BR
      cv.Point(_corners[3].dx.toInt(), _corners[3].dy.toInt()), // BL
    ];
    final srcPoints = cv.VecPoint.fromList(srcPointsList);

    // 4. Define the destination points (the perfect rectangle of the final output)
    final dstPointsList = [
      cv.Point(0, 0), // TL
      cv.Point(outputWidth, 0), // TR
      cv.Point(outputWidth, outputHeight), // BR
      cv.Point(0, outputHeight), // BL
    ];
    final dstPoints = cv.VecPoint.fromList(dstPointsList);

    // 5. Calculate and Apply the perspective warp
    final transformMatrix = cv.getPerspectiveTransform(srcPoints, dstPoints);
    final warpedMatColor = await cv.warpPerspectiveAsync(mat, transformMatrix, (
      outputWidth,
      outputHeight,
    ));

    // --- 6. POST-PROCESSING ENHANCEMENT (Contrast) ---
    // Convert to grayscale for thresholding
    final warpedGray = await cv.cvtColor(warpedMatColor, cv.COLOR_BGR2GRAY);

    // Apply Adaptive Thresholding (Otsu's method combined with THRESH_BINARY)
    // This dramatically increases contrast, making text stand out.
    // Note: If you want a non-binary, enhanced look, consider CLAHE here instead.
    final (_, processedMat) = await cv.threshold(
      warpedGray,
      0, // Set threshold to 0 to enable auto Otsu
      255,
      cv.THRESH_BINARY | cv.THRESH_OTSU,
    );

    // 7. Convert the resulting Mat back to bytes
    // Use the processed (high-contrast) Mat for the final output
    final resultBytes = (await cv.imencodeAsync(".png", processedMat)).$2;

    // 8. Navigate to the new screen
    if (mounted) {
      Navigator.of(context).push(
        MaterialPageRoute(
          builder:
              (context) =>
                  ScannedDocumentScreen(scannedImageBytes: resultBytes),
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black,
      appBar: AppBar(
        title: const Text(
          "Document Preview",
          style: TextStyle(color: Colors.white),
        ),
        backgroundColor: Colors.black,
        iconTheme: const IconThemeData(color: Colors.white),
        actions: [
          if (!_isProcessing)
            IconButton(
              onPressed: () {
                _processAndCropDocument();
              },
              icon: const Icon(Icons.check),
            ),
        ],
      ),
      body:
          _isProcessing
              ? const Center(child: CircularProgressIndicator())
              : LayoutBuilder(
                builder: (context, constraints) {
                  final displaySize = Size(
                    constraints.maxWidth,
                    constraints.maxHeight,
                  );

                  return Stack(
                    children: [
                      // Display the image
                      Positioned.fill(
                        child: FittedBox(
                          fit: BoxFit.contain,
                          child: Image.file(_imageFile),
                        ),
                      ),

                      // Draw detected document polygon
                      if (_corners.isNotEmpty && _imageSize != Size.zero)
                        GestureDetector(
                          onPanStart:
                              (details) =>
                                  _handlePanStart(details, displaySize),
                          onPanUpdate:
                              (details) =>
                                  _handlePanUpdate(details, displaySize),
                          onPanEnd: (details) => _handlePanEnd(),
                          child: CustomPaint(
                            painter: DocumentBoxPainter(
                              corners: _corners,
                              originalImageSize: _imageSize,
                              displaySize: displaySize,
                              activeCornerIndex: _activeCornerIndex,
                            ),
                            child: Container(),
                          ),
                        ),
                    ],
                  );
                },
              ),
    );
  }
}

class DocumentBoxPainter extends CustomPainter {
  final List<Offset> corners;
  final Size originalImageSize;
  final Size displaySize;
  final int? activeCornerIndex;

  DocumentBoxPainter({
    required this.corners,
    required this.originalImageSize,
    required this.displaySize,
    required this.activeCornerIndex,
  });

  List<Offset> getScreenCorners() {
    // 1. Calculate the scale and offset applied by FittedBox(fit: BoxFit.contain)
    final originalRatio = originalImageSize.width / originalImageSize.height;
    final displayRatio = displaySize.width / displaySize.height;

    double scale;
    Offset offset;

    if (originalRatio > displayRatio) {
      scale = displaySize.width / originalImageSize.width;
      final scaledHeight = originalImageSize.height * scale;
      offset = Offset(0, (displaySize.height - scaledHeight) / 2);
    } else {
      scale = displaySize.height / originalImageSize.height;
      final scaledWidth = originalImageSize.width * scale;
      offset = Offset((displaySize.width - scaledWidth) / 2, 0);
    }

    // 2. Map and scale the corners
    return corners.map((originalPoint) {
      final scaledX = originalPoint.dx * scale;
      final scaledY = originalPoint.dy * scale;
      return Offset(scaledX + offset.dx, scaledY + offset.dy);
    }).toList();
  }

  @override
  void paint(Canvas canvas, Size size) {
    if (corners.isEmpty) return;

    final scaledCorners = getScreenCorners();

    // 3. Draw the Path and Circles
    final paint =
        Paint()
          ..color = Colors.lightBlueAccent
          ..strokeWidth = 3
          ..style = PaintingStyle.stroke;

    final path = Path()..addPolygon(scaledCorners, true);
    canvas.drawPath(path, paint);

    // Draw corner circles
    const double radius = 6.0;
    for (int i = 0; i < scaledCorners.length; i++) {
      final c = scaledCorners[i];

      // Highlight the active corner
      final cornerPaint =
          Paint()
            ..color = (activeCornerIndex == i ? Colors.yellow : Colors.red)
            ..style = PaintingStyle.fill;

      canvas.drawCircle(c, radius, cornerPaint);
    }
  }

  @override
  bool shouldRepaint(covariant DocumentBoxPainter oldDelegate) {
    return oldDelegate.corners != corners ||
        oldDelegate.originalImageSize != originalImageSize;
  }
}
