import 'package:flutter/material.dart';

class TextInputConfig {
  final TextEditingController controller;
  final String label;
  final IconData icon;
  final bool number;
  final bool isInt;
  final bool readOnly;
  final int maxLines;
  final Widget? suffixIcon;
  final VoidCallback? onTap;
  final String? Function(String?)? validator;
  final AutovalidateMode autovalidateMode;

  TextInputConfig(
    this.controller,
    this.label,
    this.icon, {
    this.number = false,
    this.isInt = false,
    this.readOnly = false,
    this.maxLines = 1,
    this.suffixIcon,
    this.onTap,
    this.validator,
    this.autovalidateMode = AutovalidateMode.onUserInteraction,
  });
}
