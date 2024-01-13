import 'package:flutter/material.dart';
import 'package:flutter_application_bookstore/shared/style/btn_style.dart';

class NormalButton extends StatelessWidget {
  final VoidCallback onPressed;
  final String title;

  NormalButton({required this.onPressed, required this.title});

  @override
  Widget build(BuildContext context) {
    return TextButton(
      onPressed: onPressed,
      style: ButtonStyle(
        padding: MaterialStatePropertyAll(
          EdgeInsets.only(
            left: 60,
            right: 60,
          ),
        ),
        backgroundColor: MaterialStatePropertyAll(Colors.yellow),
      ),
      child: Text(
        title,
        style: BtnStyle.normal(),
      ),
    );
  }
}
