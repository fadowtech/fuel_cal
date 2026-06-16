import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:fuel_cal/services/theme_service.dart';

class AuthTextField extends StatelessWidget {
  final String hintText;
  final IconData prefixIcon;
  final bool obscureText;
  final Widget? suffixIcon;
  final TextEditingController? controller;
  final TextInputType keyboardType;
  final List<TextInputFormatter>? inputFormatters;
  final TextCapitalization textCapitalization;
  final ValueChanged<String>? onChanged;

  const AuthTextField({
    Key? key,
    required this.hintText,
    required this.prefixIcon,
    this.obscureText = false,
    this.suffixIcon,
    this.controller,
    this.keyboardType = TextInputType.text,
    this.inputFormatters,
    this.textCapitalization = TextCapitalization.none,
    this.onChanged,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return TextField(
      controller: controller,
      obscureText: obscureText,
      keyboardType: keyboardType,
      inputFormatters: inputFormatters,
      textCapitalization: textCapitalization,
      onChanged: onChanged,
      style: TextStyle(
        color: ThemeService.textColor,
        fontSize: 14,
      ),
      decoration: InputDecoration(
        hintText: hintText,
        hintStyle: TextStyle(
          color: ThemeService.mutedColor,
          fontSize: 14,
        ),
        prefixIcon: Padding(
          padding: const EdgeInsets.all(8.0),
          child: Container(
            width: 36,
            height: 36,
            decoration: BoxDecoration(
              color: ThemeService.isDarkMode ? Colors.black26 : const Color(0xFFF0F4F8),
              shape: BoxShape.circle,
            ),
            child: Icon(prefixIcon, color: ThemeService.textColor, size: 18),
          ),
        ),
        suffixIcon: suffixIcon != null
            ? Padding(
                padding: const EdgeInsets.all(8.0),
                child: suffixIcon,
              )
            : null,
        filled: true,
        fillColor: ThemeService.isDarkMode ? ThemeService.surfaceColor : Colors.white,
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: BorderSide(color: ThemeService.isDarkMode ? ThemeService.surfaceColor : Colors.grey.shade300),
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: BorderSide(color: ThemeService.isDarkMode ? ThemeService.surfaceColor : Colors.grey.shade300),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: const BorderSide(color: Color(0xFF3B82F6), width: 1.5),
        ),
        contentPadding: const EdgeInsets.symmetric(vertical: 16),
      ),
    );
  }
}
