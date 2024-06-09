import 'package:flutter/material.dart';

import 'dart:math' as math;

class SLogo extends StatefulWidget {
  const SLogo({
    super.key,
    this.rotate = false,
    this.size = 60.0
  });

  final bool rotate;
  final double size;

  @override
  State<SLogo> createState() => _SLogoState();
}

class _SLogoState extends State<SLogo> with TickerProviderStateMixin {
  late final AnimationController _controller = AnimationController(
    vsync: this,
    duration: const Duration(seconds: 1)
  )..repeat();

  late final Animation<double> _animation = CurvedAnimation(
    parent: _controller, 
    curve: Curves.easeInOutCirc
  );

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    if (!widget.rotate) {
      if (!_controller.isCompleted) {
        _controller.animateTo(1).then((_) => _controller.stop()); // End animation
      }
    } else {
      _controller.repeat();
    }

    return RotationTransition(
      turns: _animation,
      child: Transform.rotate(
        angle: math.pi / 6,
        child: SizedBox(
          width: widget.size,
          child: Container(
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(15.0),
              color: const Color.fromARGB(255, 62, 17, 97)
            ),
            child: Center(
              child: Padding(
                padding: const EdgeInsets.all(5.0),
                child: Transform.rotate(
                  angle: -math.pi / 6,
                  child: Image.asset('assets/images/logo.png'),
                )
              )
            )
          )
        )
      )
    );
  }
}