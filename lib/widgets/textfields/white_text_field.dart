import 'package:flutter/material.dart';
import 'package:schooly/common/utils.dart';

class SWhiteTextField extends StatefulWidget {
  final TextInputType keyboardType;
  final bool obscureText;
  final bool autofocus;
  final String labelText;
  final String hintText;
  final IconData icon;
  final Widget? trailing;
  final TextEditingController controller;
  final Function validator;
  final Function(String?)? onChanged;

  final bool showError;
  
  const SWhiteTextField({
    super.key, 

    this.keyboardType = TextInputType.name, 
    this.obscureText = false, 
    this.autofocus = false, 
    required this.labelText, 
    this.hintText = '',
    required this.icon, 
    this.trailing,
    required this.controller, 
    required this.validator, 
    this.onChanged,

    this.showError = false,
  });

  @override
  State<SWhiteTextField> createState() => _SWhiteTextFieldState();
}

class _SWhiteTextFieldState extends State<SWhiteTextField> {
  @override
  Widget build(BuildContext context) {
    TextFormField textField = TextFormField(
      onTapOutside: (_) => Utils.unfocus(context),

      onChanged: widget.onChanged,
  
      keyboardType: widget.keyboardType,
      cursorColor: Colors.white,
      autofocus: widget.autofocus,
      obscureText: widget.obscureText,
      autocorrect: false,
      
      style: Theme.of(context).textTheme.bodyLarge
        ?.copyWith(
          color: Colors.white,
        ),
  
      decoration: InputDecoration(
        isDense: true,

        labelText: widget.labelText,
        labelStyle: Theme.of(context).textTheme.bodyLarge
          ?.copyWith(
            color: Colors.white,
          ),

        floatingLabelStyle: Theme.of(context).textTheme.titleSmall
          ?.copyWith(
            height: 1,
            color: const Color.fromRGBO(206, 206, 206, 1)
          ),
        
        hintText: widget.hintText,
        hintStyle: TextStyle(
          color: Theme.of(context).textTheme.titleSmall?.color
        ),
  
        border: InputBorder.none,
        errorStyle: const TextStyle(fontSize: 0.0),
    
        fillColor: Colors.white.withOpacity(0.25)
      ),

      controller: widget.controller,
      validator: (String? value) => widget.validator(value),
    );

    String? error = textField.validator!(textField.controller!.value.text);

    BoxDecoration boxDecoration = BoxDecoration(
      color: const Color.fromRGBO(187, 128, 196, 1), // Colors.white.withOpacity(0.25)
      borderRadius: BorderRadius.circular(15.0)
    );

    if (error != null && widget.showError) {
      boxDecoration = BoxDecoration(
        color: boxDecoration.color,
        borderRadius: boxDecoration.borderRadius,
        border: Border.all(
          color: Colors.red, 
          style: BorderStyle.solid, 
          width: 2
        ),
        boxShadow: <BoxShadow>[
          BoxShadow(
            color: Colors.red.withOpacity(0.5),
            blurRadius: 4
          )
        ]
      );
    }

    return Column(
      children: <Widget>[
        Container(
          decoration: boxDecoration,
          padding: const EdgeInsets.symmetric(
            horizontal: 20.0, 
            vertical: 5.0
          ),
          child: Row(
            children: <Widget>[
              Icon(
                widget.icon,
                color: Colors.white,
                size: 26.0,
              ),

              const SizedBox(width: 20.0),

              Expanded(
                child: textField
              ),

              if (widget.trailing != null) ... {
                const SizedBox(width: 20.0),
                widget.trailing!
              }
            ],
          ),
        ),
        if (error != null && widget.showError) ... {
          const SizedBox(height: 5.0),
          Text(
            error,
            style: const TextStyle(
              color: Colors.red
            ),
            textAlign: TextAlign.center,
          )
        }
      ],
    );
  }
}