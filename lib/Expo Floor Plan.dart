import 'package:animate_do/animate_do.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart'; // For SystemNavigator.pop

class EFPScreen extends StatefulWidget {
  const EFPScreen({Key? key}) : super(key: key);

  @override
  _EFPScreenState createState() => _EFPScreenState();
}

class _EFPScreenState extends State<EFPScreen> {
  @override
  void initState() {
    super.initState();
  }

  Future<bool> _onWillPop() async {
    return (await showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Êtes-vous sûr'),
        content: const Text('Voulez-vous quitter une application'),
        actions: <Widget>[
          TextButton(
            onPressed: () => Navigator.of(context).pop(false),
            child: const Text('Non'),
          ),
          TextButton(
            onPressed: () => SystemNavigator.pop(),
            child: const Text('Oui '),
          ),
        ],
      ),
    )) ??
        false;
  }

  @override
  Widget build(BuildContext context) {
    return FadeInDown(
      child: WillPopScope(
        onWillPop: _onWillPop,
        child: Scaffold(
          appBar: AppBar(
            title: const Text(
              "Manual Expo Map", // Updated title
              style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
            ),
            backgroundColor: const Color(0xff261350),
            elevation: 0,
            centerTitle: true,
            actions: const <Widget>[],
          ),
          body: Container(
            color: Colors.grey[100], // Background color for the map area
            child: InteractiveViewer(
              boundaryMargin: const EdgeInsets.all(20.0),
              minScale: 0.5,
              maxScale: 4.0,
              child: GestureDetector(
                onTapUp: (details) {
                  final RenderBox renderBox = context.findRenderObject() as RenderBox;
                  final localPosition = renderBox.globalToLocal(details.globalPosition);

                  // In a real scenario, you'd perform hit-testing here to identify
                  // which manually drawn element (e.g., booth) was tapped.
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(
                      content: Text('Map area tapped at: X=${localPosition.dx.toInt()}, Y=${localPosition.dy.toInt()}'),
                      duration: const Duration(milliseconds: 1000),
                    ),
                  );
                },
                child: CustomPaint(
                  // CustomPaint is used to draw custom graphics
                  size: Size.infinite, // Take up all available space
                  painter: ExpoMapPainter(), // Our custom painter for the map
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}

// Custom Painter to draw the expo map elements manually
class ExpoMapPainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    // Define reusable Paint objects for different styles
    final boothPaint = Paint()
      ..color = Colors.blue.shade200
      ..style = PaintingStyle.fill;
    final boothBorderPaint = Paint()
      ..color = Colors.blue.shade700
      ..style = PaintingStyle.stroke
      ..strokeWidth = 2.0;
    final aislePaint = Paint()
      ..color = Colors.grey.shade300
      ..style = PaintingStyle.fill;
    final textColor = Colors.black87;

    // --- Draw the overall background of the expo floor ---
    canvas.drawRect(Rect.fromLTWH(0, 0, size.width, size.height), Paint()..color = Colors.white);

    // --- Draw Main Aisles ---
    // Horizontal Aisle (main path)
    canvas.drawRect(Rect.fromLTWH(0, size.height * 0.4, size.width, size.height * 0.2), aislePaint);
    // Vertical Aisle (connecting to horizontal)
    canvas.drawRect(Rect.fromLTWH(size.width * 0.45, 0, size.width * 0.1, size.height), aislePaint);


    // --- Draw Booths ---
    // Booth 101 (Top-Left)
    final booth101Rect = Rect.fromLTWH(size.width * 0.05, size.height * 0.05, size.width * 0.35, size.height * 0.3);
    canvas.drawRect(booth101Rect, boothPaint);
    canvas.drawRect(booth101Rect, boothBorderPaint);
    _drawText(canvas, "Booth 101", booth101Rect.center.dx, booth101Rect.center.dy, textColor, fontSize: 16.0);

    // Booth 102 (Top-Right)
    final booth102Rect = Rect.fromLTWH(size.width * 0.60, size.height * 0.05, size.width * 0.35, size.height * 0.3);
    canvas.drawRect(booth102Rect, boothPaint);
    canvas.drawRect(booth102Rect, boothBorderPaint);
    _drawText(canvas, "Booth 102", booth102Rect.center.dx, booth102Rect.center.dy, textColor, fontSize: 16.0);

    // Booth 201 (Bottom-Left)
    final booth201Rect = Rect.fromLTWH(size.width * 0.05, size.height * 0.65, size.width * 0.35, size.height * 0.3);
    canvas.drawRect(booth201Rect, boothPaint);
    canvas.drawRect(booth201Rect, boothBorderPaint);
    _drawText(canvas, "Booth 201", booth201Rect.center.dx, booth201Rect.center.dy, textColor, fontSize: 16.0);

    // Booth 202 (Bottom-Right)
    final booth202Rect = Rect.fromLTWH(size.width * 0.60, size.height * 0.65, size.width * 0.35, size.height * 0.3);
    canvas.drawRect(booth202Rect, boothPaint);
    canvas.drawRect(booth202Rect, boothBorderPaint);
    _drawText(canvas, "Booth 202", booth202Rect.center.dx, booth202Rect.center.dy, textColor, fontSize: 16.0);

    // Central Info Point / Main Stage
    final centerPointRect = Rect.fromLTWH(size.width * 0.4, size.height * 0.45, size.width * 0.2, size.height * 0.1);
    canvas.drawRect(centerPointRect, Paint()..color = Colors.green.shade200..style = PaintingStyle.fill);
    canvas.drawRect(centerPointRect, Paint()..color = Colors.green.shade700..style = PaintingStyle.stroke..strokeWidth = 2.0);
    _drawText(canvas, "Info", centerPointRect.center.dx, centerPointRect.center.dy, Colors.green.shade900, fontSize: 14.0);
  }

  // Helper function to draw text on the canvas
  void _drawText(Canvas canvas, String text, double x, double y, Color color, {double fontSize = 12.0}) {
    final textSpan = TextSpan(
      text: text,
      style: TextStyle(
        color: color,
        fontSize: fontSize,
        fontWeight: FontWeight.bold,
      ),
    );
    final textPainter = TextPainter(
      text: textSpan,
      textDirection: TextDirection.ltr,
    );
    textPainter.layout(
      minWidth: 0,
      maxWidth: 150, // Max width for text wrapping if needed
    );
    // Position text in center of desired point
    textPainter.paint(canvas, Offset(x - textPainter.width / 2, y - textPainter.height / 2));
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) {
    // Set to true if any properties that affect the drawing change
    return false;
  }
}