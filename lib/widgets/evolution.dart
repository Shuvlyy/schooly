import 'package:flutter/material.dart';
import 'package:schooly/common/smath.dart';

///////////////////////////////
/// ⤮ ±(B-A) points (A → B) ///
///////////////////////////////

class Evolution extends StatelessWidget {
  final double a;
  final double? b;
  final bool showBackground;
  final bool isNotSignificative;
  final bool onlySymbol;
  final EvolutionSize size;

  const Evolution({
    super.key,
    required this.a,
    this.b,
    this.showBackground = false,
    this.isNotSignificative = false,
    this.onlySymbol = false,
    this.size = EvolutionSize.normal
  });

  Color _getColor() {
    if (b == null || a < 0) return Colors.grey;

    if (b! > a) return Colors.green;
    if (b! < a) return Colors.red;

    return Colors.grey;
  }

  @override
  Widget build(BuildContext context) {
    IconData symbol = Icons.horizontal_rule_rounded;

    if (a >= 0 && b != null) {
      if (b! > a) symbol = Icons.arrow_upward_rounded;
      if (b! < a) symbol = Icons.arrow_downward_rounded;
    }

    TextStyle textStyle = 
      size == EvolutionSize.normal
      ? Theme.of(context).textTheme.bodyMedium!
      : Theme.of(context).textTheme.bodyLarge!;

    Widget evolutionWidget = Row(
      mainAxisSize: MainAxisSize.min,
      children: <Widget>[
        Container(
          height: 16.0,
          width: 16.0,
          decoration: BoxDecoration(
            color: _getColor(),
            borderRadius: BorderRadius.circular(8.0)
          ),
          child: Icon(
            symbol,
            size: 12.0,
            color: Colors.white,
          ),
        ),
        if (!onlySymbol) ... {
          if (isNotSignificative) ... {
            Text(
              '  Note non significative',
              style: textStyle.copyWith(
                color: showBackground ? Colors.white : null,
              ),
            )
          } else if (a >= 0.0 && b != null && b! >= 0.0) ... {
            Text(
              " ${b!-a > 0 ? '+' : ''}${SMath.formatSignificantFigures(b!-a)} points ",
              style: textStyle.copyWith(
                color: _getColor(),
                fontWeight: FontWeight.w500
              ),
            ),
          
            Text(
              "(${SMath.formatSignificantFigures(a)} → ${SMath.formatSignificantFigures(b!)})",
              style: textStyle.copyWith(
                color: showBackground ? Colors.white : null
              ),
            )
          }
        }
      ],
    );

    if (showBackground) {
      return Container(
        decoration: BoxDecoration(
          color: Colors.black.withOpacity(0.5),
          borderRadius: BorderRadius.circular(10.0)
        ),
        padding: EdgeInsets.symmetric(horizontal: (a >= 0.0 && b != null && b! >= 0.0) ? 10.0 : 5.0, vertical: 5.0),
        child: evolutionWidget
      );
    }

    return evolutionWidget;
  }
}

enum EvolutionSize {
  normal,
  big
}