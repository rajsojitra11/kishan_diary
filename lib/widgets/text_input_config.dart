import 'package:flutter/material.dart';

class TextInputConfig {
  final TextEditingController controller;
  final String label;
  final IconData icon;
  final bool number;
  final bool isInt;

  TextInputConfig(
    this.controller,
    this.label,
    this.icon, {
    this.number = false,
    this.isInt = false,
  });
}
