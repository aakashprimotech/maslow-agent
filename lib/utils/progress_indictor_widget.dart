import 'dart:async';
import 'package:flutter/material.dart';
import 'colors.dart';

class ProgressIndicatorWidget extends StatefulWidget {
  final List<String> steps;
  final Function(int) clickedStep;

  const ProgressIndicatorWidget({super.key, required this.steps,required this.clickedStep});

  @override
  _ProgressIndicatorWidgetState createState() => _ProgressIndicatorWidgetState();
}

class _ProgressIndicatorWidgetState extends State<ProgressIndicatorWidget> with SingleTickerProviderStateMixin {
  late StreamController<int> _streamController;
  late AnimationController _animationController;
  late Animation<double> _animation;
  int _currentStep = 0;

  @override
  void initState() {
    super.initState();

    _streamController = StreamController<int>.broadcast();
    _animationController = AnimationController(
      duration: const Duration(milliseconds: 500),
      vsync: this,
    )..addListener(() {
      setState(() {});
    });

    _animation = Tween<double>(begin: 0.0, end: 1.0).animate(_animationController);
    _startProgress();
  }

  void _startProgress() {
    Timer.periodic(const Duration(seconds: 1), (Timer timer) {
      if (_currentStep < widget.steps.length - 1) {
        _currentStep++;
        _streamController.add(_currentStep); // Emit the updated step
        _animationController.forward(from: 0.0).then((_) {
          _animationController.reset();
        });
      } else {
        timer.cancel();
      }
    });
  }

  @override
  void dispose() {
    _streamController.close();
    _animationController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
      builder: (context, constraints) {
        final double availableWidth = constraints.maxWidth - 115;
        const double circleDiameter = 15.0;
        final int numSteps = widget.steps.length;
        final double spacing = numSteps > 1
            ? (availableWidth - circleDiameter) / (numSteps - 1)
            : 0;

        return Row(
          children: [
            const Padding(
              padding: EdgeInsets.only(top: 18),
              child: Text('Start', style: TextStyle(fontSize: 14, color: Colors.black87, fontWeight: FontWeight.w600)),
            ),
            const SizedBox(width: 10),
            Expanded(
              child: Stack(
                clipBehavior: Clip.none,
                children: [
                  Positioned(
                    top: 30,
                    left: 0,
                    right: 0,
                    child: CustomPaint(
                      painter: LinePainter(widget.steps.length -1, availableWidth, spacing),
                    ),
                  ),
                  ...widget.steps.asMap().entries.map((entry) {
                    int index = entry.key;
                    String tooltipText = entry.value;
                    double position = index * spacing;
                    return Positioned(
                      top: 30 - (circleDiameter / 2),
                      left: position,
                      child: GestureDetector(
                        onTap: () => _onCircleTapped(index),
                        child: Column(
                          children: [
                            Tooltip(
                              message: tooltipText,
                              child: AnimatedContainer(
                                duration: const Duration(milliseconds: 500),
                                width: _currentStep >= index
                                    ? circleDiameter
                                    : circleDiameter * 0.8,
                                height: _currentStep >= index
                                    ? circleDiameter
                                    : circleDiameter * 0.8,
                                decoration: BoxDecoration(
                                  color: _currentStep >= index
                                      ? AppColors.greenColorBtn
                                      : AppColors.greenColorBtn,
                                  shape: BoxShape.circle,
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),
                    );
                  }),
                ],
              ),
            ),
            const Padding(
              padding: EdgeInsets.only(top: 18),
              child: Text(
                'Finished',
                style: TextStyle(fontSize: 14, color: Colors.black87, fontWeight: FontWeight.w600),
              ),
            ),
          ],
        );
      },
    );
  }

  void _onCircleTapped(int index) {
    widget.clickedStep(index);
    print('Circle $index tapped: ${widget.steps[index]}');
  }
}


class LinePainter extends CustomPainter {
  final int currentStep;
  final double width;
  final double spacing;

  LinePainter(this.currentStep, this.width, this.spacing);

  @override
  void paint(Canvas canvas, Size size) {
    final Paint paint = Paint()
      ..color = AppColors.greenColorBtn.withAlpha(50)
      ..strokeWidth = 3.0
      ..style = PaintingStyle.stroke;

    final Paint completedPaint = Paint()
      ..color = AppColors.greenColorBtn
      ..strokeWidth = 3.0
      ..style = PaintingStyle.stroke;

    const double startX = 0;
    final double endX = width;

    // Draw the base line (grey line)
    canvas.drawLine(
      Offset(startX, size.height / 2),
      Offset(endX, size.height / 2),
      paint,
    );

    // Draw the completed line (green line)
    if (currentStep > 0) {
      double completedWidth = currentStep * spacing;
      canvas.drawLine(
        Offset(startX, size.height / 2),
        Offset(completedWidth, size.height / 2),
        completedPaint,
      );
    }
  }

  @override
  bool shouldRepaint(LinePainter oldDelegate) {
    return oldDelegate.currentStep != currentStep || oldDelegate.width != width;
  }
}

