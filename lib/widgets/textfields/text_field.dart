import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:schooly/common/utils.dart';

class STextField extends StatelessWidget {
  final TextInputType keyboardType;
  final bool obscureText;
  final bool autofocus;
  final String labelText;
  final String hintText;
  final IconData? icon;
  final Widget? leading;
  final Widget? trailing;
  final int? maxLength;
  final List<TextInputFormatter>? inputFormatters;
  final TextEditingController controller;
  final Function validator;
  final Function()? onTap;

  const STextField({
    super.key,
    
    this.keyboardType = TextInputType.name, 
    this.obscureText = false, 
    this.autofocus = false, 
    required this.labelText, 
    this.hintText = '',
    this.icon, 
    this.leading,
    this.trailing,
    this.maxLength,
    this.inputFormatters,
    required this.controller, 
    required this.validator, 
    this.onTap
  });

  @override
  Widget build(BuildContext context) {
    return TextFormField(
      onTapOutside: (_) => Utils.unfocus(context),

      keyboardType: keyboardType,
      cursorColor: Colors.grey.shade500,
      autofocus: autofocus,
      obscureText: obscureText,
      autocorrect: false,
      
      maxLength: maxLength,

      inputFormatters: inputFormatters,

      style: Theme.of(context).textTheme.bodyLarge,
        // ?.copyWith(
        //   color: Colors.white,
        // ),
  
      decoration: InputDecoration(
        isDense: true,
        prefixIcon: leading,
        suffixIcon: trailing,

        labelText: labelText,
        labelStyle: Theme.of(context).textTheme.bodyLarge,
          // ?.copyWith(
          //   color: Colors.white,
          // ),

        floatingLabelStyle: Theme.of(context).textTheme.titleSmall
          ?.copyWith(
            height: 1,
            color: const Color.fromRGBO(128, 128, 128, 1)
          ),
        
        hintText: hintText,
        hintStyle: TextStyle(
          color: Theme.of(context).textTheme.titleSmall?.color
        ),
  
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(15.0),
          borderSide: const BorderSide(
            width: 2,
            color: Color.fromRGBO(206, 206, 206, 1),
          ),
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(15.0),
          borderSide: const BorderSide(
            width: 2,
            color: Color.fromRGBO(206, 206, 206, 1),
          ),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(15.0),
          borderSide: const BorderSide(
            width: 2,
            color: Color.fromRGBO(206, 206, 206, 1),
          ),
        )
      ),

      controller: controller,
      validator: (String? value) => validator(value),

      onTap: onTap,
    );
  }
}