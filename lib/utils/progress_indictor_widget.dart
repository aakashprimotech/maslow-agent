import 'dart:async';
import 'package:flutter/material.dart';
import 'colors.dart';

class ProgressIndicatorWidget extends StatefulWidget {
  final List<String> steps;

  ProgressIndicatorWidget({required this.steps});

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
    final double width = MediaQuery.of(context).size.width / 1.5;
    const double circleDiameter = 15.0; // Diameter of each circle
    final int numSteps = widget.steps.length;
    final double spacing = (width - circleDiameter) / (numSteps - 1);
    final double totalWidth = (numSteps - 1) * spacing;

    return SizedBox(
      width: width,
      child: StreamBuilder<int>(
        stream: _streamController.stream,
        builder: (context, snapshot) {
          final currentStep = snapshot.data ?? _currentStep;
          return Stack(
            clipBehavior: Clip.none,
            children: [
              // Draw the progress line first
              Positioned(
                top: 30,
                left: 0,
                right: 0,
                child: CustomPaint(
                  painter: LinePainter(currentStep, totalWidth, spacing),
                ),
              ),
              // Draw the circles on top
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
                            width: currentStep >= index
                                ? circleDiameter
                                : circleDiameter * 0.8,
                            height: currentStep >= index
                                ? circleDiameter
                                : circleDiameter * 0.8,
                            decoration: BoxDecoration(
                              color: currentStep >= index
                                  ? AppColors.primaryColor
                                  : Colors.grey,
                              shape: BoxShape.circle,
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                );
              }).toList(),
            ],
          );
        },
      ),
    );
  }

  void _onCircleTapped(int index) {
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
      ..color = AppColors.primaryColor.withAlpha(50)
      ..strokeWidth = 3.0
      ..style = PaintingStyle.stroke;

    final Paint completedPaint = Paint()
      ..color = AppColors.primaryColor.withAlpha(150)
      ..strokeWidth = 3.0
      ..style = PaintingStyle.stroke;

    const double startX = 0;
    final double endX = width;

    // Draw the base line
    canvas.drawLine(
        Offset(startX, size.height / 2), Offset(endX, size.height / 2), paint);

    // Draw completed line
    if (currentStep > 0) {
      canvas.drawLine(Offset(startX, size.height / 2),
          Offset(currentStep * spacing, size.height / 2), completedPaint);
    }
  }

  @override
  bool shouldRepaint(CustomPainter oldDelegate) => false;
}

/*
import 'dart:async';
import 'package:flutter/material.dart';

import 'colors.dart';

class ProgressIndicatorWidget extends StatefulWidget {
  final List<String> steps;

  ProgressIndicatorWidget({required this.steps});

  @override
  _ProgressIndicatorWidgetState createState() => _ProgressIndicatorWidgetState();
}

class _ProgressIndicatorWidgetState extends State<ProgressIndicatorWidget>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _animation;
  int _currentStep = 0;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      duration: const Duration(milliseconds: 500),
      vsync: this,
    )..addListener(() {
      setState(() {});
    });

    _animation = Tween<double>(begin: 0.0, end: 1.0).animate(_controller);
    _startProgress();
  }

  void _startProgress() {
    Timer.periodic(const Duration(seconds: 2), (Timer timer) {
      if (_currentStep < widget.steps.length - 1) {
        _controller.forward().then((_) {
          _controller.reset();
          setState(() {
            _currentStep++;
          });
        });
      } else {
        timer.cancel();
      }
    });
  }

  void updateProgress(int newStep) {
    setState(() {
      if (newStep < widget.steps.length) {
        _currentStep = newStep;
        _controller.forward(from: 0.0); // Start the animation from the beginning
      }
    });
  }


  @override
  Widget build(BuildContext context) {
    final double width = MediaQuery.of(context).size.width / 1.5;
    const double circleDiameter = 15.0; // Diameter of each circle
    final int numSteps = widget.steps.length;
    final double spacing = (width - circleDiameter) / (numSteps - 1);
    final double totalWidth = (numSteps - 1) * spacing;

    return SizedBox(
      width: width,
      child: Stack(
        children: [
          Positioned(
            top: 30,
            left: 0,
            right: 0,
            child: CustomPaint(
              painter: LinePainter(_currentStep, totalWidth, spacing),
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
                              ? AppColors.primaryColor
                              : Colors.grey,
                          shape: BoxShape.circle,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            );
          }).toList(),
        ],
      ),
    );
  }

  void _onCircleTapped(int index) {
    print('Circle $index tapped: ${widget.steps[index]}');
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
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
      ..color = AppColors.primaryColor.withAlpha(50)
      ..strokeWidth = 3.0
      ..style = PaintingStyle.stroke;

    final Paint completedPaint = Paint()
      ..color = AppColors.primaryColor.withAlpha(150)
      ..strokeWidth = 3.0
      ..style = PaintingStyle.stroke;

    const double startX = 0;
    final double endX = width;

    // Draw the base line
    canvas.drawLine(
        Offset(startX, size.height / 2), Offset(endX, size.height / 2), paint);

    // Draw completed line
    if (currentStep > 0) {
      canvas.drawLine(Offset(startX, size.height / 2),
          Offset(currentStep * spacing, size.height / 2), completedPaint);
    }
  }

  @override
  bool shouldRepaint(CustomPainter oldDelegate) => false;
}*/
