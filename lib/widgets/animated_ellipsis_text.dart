import 'package:flutter/material.dart';
import 'package:timer_builder/timer_builder.dart';

const Duration dotsPeriodicity = Duration(milliseconds: 500);

class AnimatedEllipsisText extends StatefulWidget {
  const AnimatedEllipsisText(
    String this.data, {
    super.key,
    this.style,
    this.textAlign
  });

  final String? data;
  final TextStyle? style;
  final TextAlign? textAlign;

  @override
  State<AnimatedEllipsisText> createState() => _AnimatedEllipsisTextState();
}

class _AnimatedEllipsisTextState extends State<AnimatedEllipsisText> {
  int dots = 1;

  @override
  Widget build(BuildContext context) {
    if (widget.data == null) return Container();

    return TimerBuilder.periodic(
      dotsPeriodicity,
      builder: (BuildContext context) {
        if (dots == 3) {
          dots = 1;
        } else {
          dots++;
        }
        
        return Text(
          "${widget.data!}${"." * dots}",
          style: widget.style,
          textAlign: widget.textAlign,
        );
      },
    );
  }
}