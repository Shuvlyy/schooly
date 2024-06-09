import 'package:flutter/material.dart';
import 'package:schooly/common/scolors.dart';

class VerticalSwitchListTile extends StatefulWidget {
  final bool value;
  final String title;
  final Color? color;
  final bool showBackground;
  final Function(bool) onChanged;
  
  const VerticalSwitchListTile({
    super.key,

    required this.value,
    required this.title,
    this.color,
    this.showBackground = true,
    required this.onChanged
  });

  @override
  State<VerticalSwitchListTile> createState() => _VerticalSwitchListTileState();
}

class _VerticalSwitchListTileState extends State<VerticalSwitchListTile> {
  bool v = false;

  @override
  void initState() {
    v = widget.value;

    super.initState();
  }

  void toggle() {
    setState(() {
      v = !v;
      widget.onChanged(v);
    });
  }

  @override
  Widget build(BuildContext context) {
    return Material(
      color: widget.showBackground ? SColors.getBackgroundColor(context) : Colors.transparent,
      borderRadius: BorderRadius.circular(10.0),
      child: InkWell(
        onTap: () {
          setState(() {
            toggle();
          });
        },
        borderRadius: BorderRadius.circular(10.0),
        child: Padding(
          padding: const EdgeInsets.all(8.0),
          child: Column(
            children: <Widget>[
              Text(
                widget.title
              ),
              Switch.adaptive(
                value: v, 
                activeColor: widget.color,
                onChanged: (_) {
                  toggle();
                }
              )
            ],
          ),
        ),
      ),
    );
  }
}