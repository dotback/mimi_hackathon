import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:hexcolor/hexcolor.dart';

class MyButton extends StatelessWidget {
  final String buttonText;
  final VoidCallback onPressed;
  final Color? buttonColor;
  final Color? textColor;

  const MyButton({
    super.key,
    required this.buttonText,
    required this.onPressed,
    this.buttonColor,
    this.textColor,
  });

  @override
  Widget build(BuildContext context) {
    return ElevatedButton(
      onPressed: onPressed,
      style: ButtonStyle(
        elevation: MaterialStateProperty.all(0),
        textStyle: MaterialStateProperty.all<TextStyle?>(
          GoogleFonts.poppins(
            fontSize: 18,
            color: textColor ?? Colors.white,
          ),
        ),
        padding: MaterialStateProperty.all<EdgeInsetsGeometry>(
            const EdgeInsets.fromLTRB(20, 15, 20, 15)),
        backgroundColor: MaterialStateProperty.all<Color>(HexColor("#4169E1")),
        shape: MaterialStateProperty.all<RoundedRectangleBorder>(
            RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(50),
        )),
      ),
      child: Text(
        buttonText,
        style: GoogleFonts.poppins(
          color: textColor ?? Colors.white,
          fontSize: 18,
        ),
      ),
    );
  }
}
