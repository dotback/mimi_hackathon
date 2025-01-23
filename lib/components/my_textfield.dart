import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:hexcolor/hexcolor.dart';

class MyTextField extends StatelessWidget {
  final TextEditingController controller;
  final String hintText;
  final bool obscureText;
  final Icon? prefixIcon;
  final Function()? onChanged;
  final TextInputType? keyboardType;

  const MyTextField({
    super.key,
    required this.controller,
    required this.hintText,
    required this.obscureText,
    this.prefixIcon,
    this.onChanged,
    this.keyboardType,
  });

  @override
  Widget build(BuildContext context) {
    return TextField(
      onChanged: (value) {
        if (onChanged != null) {
          onChanged!();
        }
      },
      controller: controller,
      obscureText: obscureText,
      keyboardType: keyboardType,
      decoration: InputDecoration(
        prefixIcon: prefixIcon,
        hintText: hintText,
        hintStyle: GoogleFonts.poppins(
          fontSize: 15,
          color: HexColor("#8d8d8d"),
        ),
        enabledBorder: OutlineInputBorder(
          borderSide: BorderSide(color: HexColor("#e8e8e8")),
          borderRadius: BorderRadius.circular(10),
        ),
        focusedBorder: OutlineInputBorder(
          borderSide: BorderSide(color: HexColor("#44564a")),
          borderRadius: BorderRadius.circular(10),
        ),
      ),
    );
  }
}
