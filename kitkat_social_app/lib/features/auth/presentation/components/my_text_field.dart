import 'package:flutter/material.dart';

class MyTextField extends StatelessWidget {
  final TextEditingController controller;
  final String hintText;
  final bool obsureText;

  const MyTextField({
    super.key,
    required this.controller,
    required this.hintText,
    required this.obsureText,
  });

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;

    return Container(
      margin: const EdgeInsets.symmetric(vertical: 10),
      decoration: BoxDecoration(
        boxShadow: [
          BoxShadow(
            color: Colors.blueGrey.withOpacity(0.07),
            blurRadius: 12,
            offset: Offset(0, 4),
          ),
        ],
        borderRadius: BorderRadius.circular(18),
      ),
      child: TextField(
        controller: controller,
        obscureText: obsureText,
        style: TextStyle(fontSize: 17, fontWeight: FontWeight.w500),
        cursorColor: colorScheme.primary,
        decoration: InputDecoration(
          contentPadding: const EdgeInsets.symmetric(
            vertical: 20,
            horizontal: 20,
          ),
          enabledBorder: OutlineInputBorder(
            borderSide: BorderSide(
              color: colorScheme.primary.withOpacity(0.55),
              width: 1.3,
            ),
            borderRadius: BorderRadius.circular(18),
          ),
          focusedBorder: OutlineInputBorder(
            borderSide: BorderSide(color: colorScheme.primary, width: 2),
            borderRadius: BorderRadius.circular(18),
          ),
          filled: true,
          fillColor: colorScheme.surface.withOpacity(0.96),
          hintText: hintText,
          hintStyle: TextStyle(
            color: colorScheme.primary.withOpacity(0.45),
            fontSize: 16,
            fontWeight: FontWeight.w400,
          ),
        ),
      ),
    );
  }
}
