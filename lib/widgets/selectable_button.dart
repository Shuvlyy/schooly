import 'package:flutter/material.dart';

class SelectableButton extends StatefulWidget {
  const SelectableButton({
    super.key,

    required this.title,
    this.subtitle,
    required this.value,
    required this.groupValue,
    this.crossAxisAlignment = CrossAxisAlignment.start,
    required this.onTap
  });

  final String title;
  final String? subtitle;
  final Object value;
  final Object groupValue;
  final CrossAxisAlignment crossAxisAlignment;
  final Function(Object) onTap;

  @override
  State<SelectableButton> createState() => _SelectableButtonState();
}

class _SelectableButtonState extends State<SelectableButton> {
  double _scale = 1;

  @override
  Widget build(BuildContext context) {
    bool isSelected = widget.value == widget.groupValue;
    
    return AnimatedScale(
      scale: _scale, 
      duration: const Duration(milliseconds: 50),
      curve: Curves.linear,
      child: InkWell(
        onTapDown: (_) {
          setState(() => _scale = 0.95);
        },
        onTapUp: (_) {
          setState(() => _scale = 1);
          widget.onTap(widget.value);
        },
        onTapCancel: () {
          setState(() => _scale = 1);
        },
        borderRadius: BorderRadius.circular(15.0),
        child: Container(
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(15.0),
            color: const Color.fromRGBO(123, 56, 131, 1),
            border: 
              isSelected 
              ? Border.all(
                color: const Color.fromRGBO(75, 0, 84, 1)
              )
              : null,
            boxShadow: 
              isSelected
              ? <BoxShadow>[
                const BoxShadow(
                  blurRadius: 4.0,
                  color: Color.fromRGBO(75, 0, 84, 1),
                )
              ]
              : null
          ),
          padding: const EdgeInsets.all(15.0),
          child: Column(
            crossAxisAlignment: widget.crossAxisAlignment,
            children: <Text>[
              Text(
                widget.title,
                style: Theme.of(context).textTheme.titleMedium
                  ?.copyWith(
                    color: Colors.white
                  )
              ),
      
              if (widget.subtitle != null) ... {
                Text(
                  widget.subtitle!,
                  style: Theme.of(context).textTheme.titleSmall
                    ?.copyWith(
                      fontWeight: FontWeight.normal,
                      color: Colors.grey[400]
                    )
                )
              }
            ],
          ),
        ),
      ),
    );
  }
}