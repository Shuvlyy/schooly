import 'package:flutter/material.dart';

class Legend extends StatelessWidget {
  final String title;
  final Color color;

  const Legend({
    super.key,

    required this.title,
    required this.color
  });

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: <Widget>[
        Container(
          height: 16.0,
          width: 16.0,
          decoration: BoxDecoration(
            color: color,
            borderRadius: BorderRadius.circular(8.0),
          ),
        ),
        
        const SizedBox(width: 6.0),
    
        Text(
          title
        )
      ],
    );
  }
}