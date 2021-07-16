import 'dart:math';
import 'dart:ui';

import 'package:flutter/material.dart';

void main() => runApp(MyApp());

class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Tweening and Curves',
      home: Page2(),
    );
  }
}

class GraphPainter extends CustomPainter {
  final Offset currentPoint;
  final Path shadowPath;
  final Path followPath;
  final Path? comparePath;
  final double graphSize;

  GraphPainter({
    required this.currentPoint,
    required this.shadowPath,
    required this.followPath,
    required this.comparePath,
    required this.graphSize,
  });

  static final backgroundPaint = Paint()..color = Colors.grey[200]!;
  static final currentPointPaint = Paint()..color = Colors.red;
  static final shadowPaint = Paint()
    ..color = Colors.grey
    ..style = PaintingStyle.stroke
    ..strokeWidth = 3;
  static final comparePaint = Paint()
    ..color = Colors.green[500]!
    ..style = PaintingStyle.stroke
    ..strokeWidth = 2;
  static final followPaint = Paint()
    ..color = Colors.blue
    ..style = PaintingStyle.stroke
    ..strokeWidth = 4;
  static final borderPaint = Paint()
    ..color = Colors.grey[700]!
    ..style = PaintingStyle.stroke
    ..strokeWidth = 3;

  @override
  void paint(Canvas canvas, Size size) {
    _drawBackground(canvas, size);
    canvas.translate(
        size.width / 2 - graphSize / 2, size.height / 2 - graphSize / 2);
    _drawBorder(canvas, size);
    canvas.translate(0, graphSize);
    if (comparePath != null) {
      canvas.drawPath(comparePath!, comparePaint);
    }
    canvas.drawPath(shadowPath, shadowPaint);
    canvas.drawPath(followPath, followPaint);
    canvas.drawCircle(
        Offset(currentPoint.dx, -currentPoint.dy), 4, currentPointPaint);
  }

  void _drawBackground(Canvas canvas, Size size) {
    canvas.drawRect(
        Rect.fromLTWH(0, 0, size.width, size.height), backgroundPaint);
  }

  void _drawBorder(Canvas canvas, Size size) {
    canvas.drawLine(Offset(0, 0), Offset(0, graphSize), borderPaint);
    canvas.drawLine(
        Offset(0, graphSize), Offset(graphSize, graphSize), borderPaint);
  }

  @override
  bool shouldRepaint(CustomPainter oldDelegate) {
    return true;
  }
}

class CircleCurve extends Curve {
  @override
  double transformInternal(double t) {
     double y = 0;
    if (t <= 0.5)
      y = sqrt(0.5 * 0.5 - (0.5 - t * 2) * (0.5 - t * 2)) * 2;
    else if( t>= 0.5 && t < 1) {
      y = -sqrt(0.5 * 0.5 - (0.5 - (1 - t) * 2) * (0.5 - (1 - t) * 2)) * 2;
    }
    return y;
  }

  double getValueX(value) {
    double x = 1;
    if (value <= 0.5) {
      x = (value - 0.25) * 4;
    } else if(value >= 0.5 && value < 1)
      x = (0.75 - value) * 4;
    return x;
  }
}

class SquareCurve extends Curve {
  @override
  double transformInternal(double t) {
    double y = 0.5;
    if (t <= 0.25)
      y = 0.5;
    else if (t >= 0.25 && t <= 0.5)
      y = 0.5 - (t - 0.25) * 4; // t*0.25/0.5
    else if (t >= 0.5 && t <= 0.75)
      y = -0.5;
    else if (t >= 0.75 && t <= 1) y = (t - 0.75) * 4 - 0.5;
    return y * 2;
  }

  double getValueX(t) {
    double x = 0.5;
    if (t <= 0.25)
      x = (t) * 4 - 0.5;
    else if (t >= 0.25 && t <= 0.5)
      x = 0.5;
    else if (t >= 0.5 && t <= 0.75)
      x = 0.5 - (t - 0.5) * 4;
    else if (t >= 0.75 && t <= 1) x = -0.5;
    return x * 2;
  }
}

class Page2 extends StatefulWidget {
  @override
  State<StatefulWidget> createState() {
    return Page2State();
  }
}

class Page2State extends State<Page2> with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late CurvedAnimation circle;
  late CurvedAnimation square;

  late Animatable<double> animatable;

  @override
  void initState() {
    super.initState();
    _controller =
        AnimationController(vsync: this, duration: Duration(seconds: 3));
    circle =
        CurvedAnimation(parent: _controller, curve: CircleCurve());
    square = CurvedAnimation(parent: _controller, curve: SquareCurve());
  }

  @override
  Widget build(BuildContext context) {
    _controller.repeat();
    return Scaffold(
      appBar: AppBar(
        title: Text('Page2'),
      ),
      body: Container(
        alignment: Alignment.center,
        child: AnimatedBuilder(
            animation: _controller,
            builder: (context, child) {
              return Column(
                children: [
                  Expanded(child: Align(
                      alignment: Alignment(
                          CircleCurve().getValueX(_controller.value),
                          -circle.curve.transform(_controller.value)),
                      child: Icon(Icons.stream))),
                  Expanded(child: Align(
                      alignment: Alignment(
                          SquareCurve().getValueX(_controller.value),
                          -square.curve.transform(_controller.value)),
                      child: Icon(Icons.memory)))
                ],
              );
            }),
      ),
    );
  }
}
