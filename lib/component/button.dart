import 'package:flutter/material.dart';

class Button extends StatelessWidget {
  final String? label;
  final VoidCallback? onPressed;
  final Color? labelColor;
  final Color? backgroundColor;

  const Button({super.key, required this.label, this.onPressed, this.labelColor, this.backgroundColor});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: EdgeInsets.symmetric(horizontal: 20, vertical: 10),
      child: MaterialButton(
        height: 50,
        minWidth: double.infinity,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(50)),
        color: backgroundColor ?? Colors.blue,
        onPressed: onPressed ?? () {},
        child: Text(
          label!,
          style: Theme.of(
            context,
          ).textTheme.bodyLarge!.copyWith(color: labelColor ?? Colors.white),
        ),
      ),
    );
  }
}
