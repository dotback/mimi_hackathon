import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:hexcolor/hexcolor.dart';

class MyTextField extends StatelessWidget {
  final TextEditingController controller;
  final String hintText;
  final bool obscureText;
  final Icon? prefixIcon;
  final void Function(String)? onChanged;
  final TextInputType? keyboardType;
  final List<FilteringTextInputFormatter>? inputFormatters;

  const MyTextField({
    super.key,
    required this.controller,
    required this.hintText,
    required this.obscureText,
    this.prefixIcon,
    this.onChanged,
    this.keyboardType,
    this.inputFormatters,
  });

  @override
  Widget build(BuildContext context) {
    return TextField(
      onChanged: onChanged,
      controller: controller,
      obscureText: obscureText,
      keyboardType: keyboardType,
      inputFormatters: inputFormatters,
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
