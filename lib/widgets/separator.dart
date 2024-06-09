import 'package:flutter/material.dart';

class Separator extends StatelessWidget {
  const Separator({
    super.key,
    this.width = 75,
    this.color = const Color.fromRGBO(206, 206, 206, 1),
    this.text
  });

  final double width;
  final Color color;
  final String? text;

  @override
  Widget build(BuildContext context) {
    if (text == null) {
      return Padding(
        padding: const EdgeInsets.all(5.0),
        child: Container(
          height: 2,
          width: width,
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(width / 2),
            color: color
          ),
        ),
      );
    }

    final textSize = TextPainter(
      text: TextSpan(
        text: text, 
        style: Theme.of(context).textTheme.bodySmall,
      ),
      maxLines: 1,
      textDirection: TextDirection.ltr
    )..layout(minWidth: 0, maxWidth: double.infinity);

    final Text shownText = Text(
      text!,
      style: Theme.of(context).textTheme.bodyLarge?.copyWith(
        color: color,
        fontWeight: FontWeight.w500,
      )
    );

    if (textSize.width + 40 > width) {
      return shownText;
    }

    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: <Widget>[
        Container(
          height: 2,
          width: width - textSize.width - 10,
          decoration: BoxDecoration(
            color: color,
            borderRadius: BorderRadius.only(
              topRight: Radius.circular(width / 2),
              bottomRight: Radius.circular(width / 2)
            )
          ),
        ),

        const SizedBox(width: 10.0),

        shownText,

        const SizedBox(width: 10.0),

        Container(
          height: 2,
          width: width - textSize.width - 10,
          decoration: BoxDecoration(
            color: color,
            borderRadius: BorderRadius.only(
              topLeft: Radius.circular(width / 2),
              bottomLeft: Radius.circular(width / 2)
            )
          ),
        ),
      ],
    );
  }
}