import 'package:flutter/material.dart';
import 'package:gradient_borders/gradient_borders.dart';
import 'package:schooly/common/scolors.dart';

class DefaultPageLayout extends StatelessWidget {
  final Widget? leading;
  final List<Widget>? body;
  final Widget? trailing;
  final bool expandedBody;
  final bool autoSpacing;
  final double spacing;
  final double padding;
  final Color? color;
  final List<Color>? gradient;

  const DefaultPageLayout({
    super.key,
    this.leading,
    this.body,
    this.trailing,
    this.expandedBody = true,
    this.autoSpacing = true,
    this.spacing = 20.0,
    this.padding = 20.0,
    this.color,
    this.gradient
  }) : assert(
    (color != null && gradient == null) || 
    (color == null && gradient != null) || 
    (color == null && gradient == null)
  );

  @override
  Widget build(BuildContext context) {
    List<Widget> widgets = body ?? [];

    if (autoSpacing && body != null) {
      for (int k = 0; k < widgets.length; k += 2) {
        widgets.insert(
          k + 1,
          SizedBox(height: spacing)
        );
      }
    }

    // BorderSide borderSide = BorderSide(
    //   color: color ?? Colors.transparent,
    //   width: 3
    // );

    final Widget leadingWidget =
      Padding(
        padding: EdgeInsets.symmetric(vertical: padding),
        child: leading,
      );

    final Widget bodyWidget =
      Container(
        decoration: BoxDecoration(
          color: SColors.getBackgroundColor(context),
          border: 
          gradient != null ? 
          GradientBoxBorder(
            gradient: LinearGradient(
              begin: Alignment.topCenter,
              end: Alignment.bottomCenter,
              colors: gradient!
            ),
            width: 3
          )
          : Border.all(
            color: color ?? Colors.transparent,
            width: 3.0
          ),
          // : Border(
          //   // top: borderSide,
          //   // left: borderSide,
          //   // right: borderSide
          // ),
          borderRadius: const BorderRadius.only(
            topLeft: Radius.circular(40.0),
            topRight: Radius.circular(40.0)
          ),
        ),
        padding: EdgeInsets.all(padding),
        child: SingleChildScrollView(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: widgets,
          )
        )
      );
    
    Widget? trailingWidget;

    if (trailing != null) {
      trailingWidget = Container(
        color: SColors.getBackgroundColor(context),
        padding: EdgeInsets.all(padding),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: <Widget>[
            trailing!
          ],
        )
      );
    }

    return Column(
      mainAxisSize: MainAxisSize.max,
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: <Widget>[
        if (leading != null) ... {
          if (!expandedBody) ... {
            Expanded(
              child: leadingWidget
            )
          } else ... {
            leadingWidget
          }
        },
        const SizedBox(height: 10.0),
        if (expandedBody) ... {
          Expanded(
            child: bodyWidget
          )
        } else ... {
          bodyWidget
        },

        if (trailingWidget != null) ... {
          trailingWidget
        }
      ]
    );
  }
}