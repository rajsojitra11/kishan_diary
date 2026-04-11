import 'dart:ui';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter/services.dart';
import 'package:http/http.dart' as http;

import '../providers/app_providers.dart';
import '../utils/api_service.dart';

class ForgotPasswordScreen extends ConsumerStatefulWidget {
  const ForgotPasswordScreen({super.key});

  @override
  ConsumerState<ForgotPasswordScreen> createState() => _ForgotPasswordScreenState();
}

class _ForgotPasswordScreenState extends ConsumerState<ForgotPasswordScreen> {
  static const String _backgroundImagePath = 'lib/assets/images/download.jpg';
  static const String _registerLogoPath = 'lib/assets/images/register.png';
  final _formKey = GlobalKey<FormState>();
  final _mobileController = TextEditingController();
  final _birthdateController = TextEditingController();
  final _newPasswordController = TextEditingController();
  final _confirmPasswordController = TextEditingController();
  DateTime? _selectedBirthdate;

  @override
  void initState() {
    super.initState();
    final today = DateTime.now();
    _selectedBirthdate = today;
    _birthdateController.text =
        '${today.day.toString().padLeft(2, '0')}/${today.month.toString().padLeft(2, '0')}/${today.year}';
  }

  @override
  void dispose() {
    _mobileController.dispose();
    _birthdateController.dispose();
    _newPasswordController.dispose();
    _confirmPasswordController.dispose();
    super.dispose();
  }

  String? _validateMobile(String? value) {
    final mobile = value?.trim() ?? '';
    if (mobile.isEmpty) {
      return 'Please enter mobile number';
    }
    if (!RegExp(r'^\d{10}$').hasMatch(mobile)) {
      return 'Enter valid 10 digit mobile number';
    }
    return null;
  }

  String? _requiredValidator(String? value, String message) {
    if ((value ?? '').trim().isEmpty) {
      return message;
    }
    return null;
  }

  String? _confirmPasswordValidator(String? value) {
    if ((value ?? '').isEmpty) {
      return 'Please confirm password';
    }
    if (value != _newPasswordController.text) {
      return 'Passwords do not match';
    }
    return null;
  }

  Future<bool> _hasInternetConnection() async {
    try {
      final response = await http
          .get(Uri.parse('https://clients3.google.com/generate_204'))
          .timeout(const Duration(seconds: 5));
      return response.statusCode == 204;
    } catch (_) {
      return false;
    }
  }

  Future<void> _showNoInternetPopup() async {
    await showDialog<void>(
      context: context,
      builder: (dialogContext) => AlertDialog(
        title: const Text('No Internet Connection'),
        content: const Text(
          'Please turn on your mobile internet or Wi-Fi and try again.',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(dialogContext).pop(),
            child: const Text('OK'),
          ),
        ],
      ),
    );
  }

  InputDecoration _darkInputDecoration(
    String label, {
    Widget? suffixIcon,
    String? counterText,
  }) {
    return InputDecoration(
      labelText: label,
      labelStyle: TextStyle(color: Colors.white.withValues(alpha: 0.92)),
      filled: true,
      fillColor: Colors.black.withValues(alpha: 0.42),
      suffixIcon: suffixIcon,
      suffixIconColor: Colors.white.withValues(alpha: 0.85),
      counterText: counterText,
      border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
      enabledBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(12),
        borderSide: BorderSide(
          color: Colors.green.shade200.withValues(alpha: 0.95),
          width: 1.6,
        ),
      ),
      focusedBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(12),
        borderSide: const BorderSide(color: Color(0xFFFFE082), width: 2.2),
      ),
    );
  }

  Future<void> _pickBirthdate() async {
    final now = DateTime.now();
    final pickedDate = await showDatePicker(
      context: context,
      initialDate: DateTime(now.year - 18, now.month, now.day),
      firstDate: DateTime(1900),
      lastDate: now,
    );

    if (pickedDate == null) {
      return;
    }

    setState(() {
      _selectedBirthdate = pickedDate;
      _birthdateController.text =
          '${pickedDate.day.toString().padLeft(2, '0')}/${pickedDate.month.toString().padLeft(2, '0')}/${pickedDate.year}';
    });
  }

  Future<void> _resetPassword() async {
    if (!(_formKey.currentState?.validate() ?? false)) {
      return;
    }

    final hasInternet = await _hasInternetConnection();
    if (!hasInternet) {
      if (!mounted) {
        return;
      }
      await _showNoInternetPopup();
      return;
    }

    if (!mounted) {
      return;
    }

    if (_selectedBirthdate == null) {
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(const SnackBar(content: Text('Please select birthdate')));
      return;
    }

    try {
      await ref.read(apiServiceProvider).resetForgotPassword(
        mobile: _mobileController.text.trim(),
        birthDate: _birthdateController.text.trim(),
        newPassword: _newPasswordController.text,
        newPasswordConfirmation: _confirmPasswordController.text,
      );

      if (!mounted) {
        return;
      }

      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Password updated successfully')),
      );
      Navigator.of(context).pop();
    } on ApiException catch (error) {
      if (!mounted) {
        return;
      }
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text(error.message)));
    } catch (_) {
      if (!mounted) {
        return;
      }
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Password reset failed, please try again.'),
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Forgot Password')),
      body: SizedBox.expand(
        child: Stack(
          fit: StackFit.expand,
          children: [
            Positioned.fill(
              child: ColoredBox(
                color: const Color(0xFF4E6F4A),
                child: Image.asset(_backgroundImagePath, fit: BoxFit.cover),
              ),
            ),
            Positioned.fill(
              child: ClipRect(
                child: BackdropFilter(
                  filter: ImageFilter.blur(sigmaX: 8, sigmaY: 8),
                  child: Container(color: Colors.white.withValues(alpha: 0.22)),
                ),
              ),
            ),
            SafeArea(
              child: SingleChildScrollView(
                padding: const EdgeInsets.all(16),
                child: Form(
                  key: _formKey,
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                    children: [
                      Center(
                        child: ClipRRect(
                          borderRadius: BorderRadius.circular(20),
                          child: Image.asset(
                            _registerLogoPath,
                            width: 170,
                            height: 170,
                            fit: BoxFit.cover,
                          ),
                        ),
                      ),
                      const SizedBox(height: 14),
                      TextFormField(
                        controller: _mobileController,
                        keyboardType: TextInputType.phone,
                        maxLength: 10,
                        inputFormatters: [
                          FilteringTextInputFormatter.digitsOnly,
                        ],
                        style: const TextStyle(color: Colors.white),
                        cursorColor: Colors.white,
                        decoration: _darkInputDecoration(
                          'Mobile Number',
                          counterText: '',
                        ),
                        validator: _validateMobile,
                      ),
                      const SizedBox(height: 12),
                      TextFormField(
                        controller: _birthdateController,
                        readOnly: true,
                        onTap: _pickBirthdate,
                        style: const TextStyle(color: Colors.white),
                        cursorColor: Colors.white,
                        decoration: _darkInputDecoration(
                          'Birthdate',
                          suffixIcon: const Icon(Icons.calendar_today),
                        ),
                        validator: (value) => _requiredValidator(
                          value,
                          'Please select birthdate',
                        ),
                      ),
                      const SizedBox(height: 12),
                      TextFormField(
                        controller: _newPasswordController,
                        obscureText: true,
                        style: const TextStyle(color: Colors.white),
                        cursorColor: Colors.white,
                        decoration: _darkInputDecoration('New Password'),
                        validator: (value) => _requiredValidator(
                          value,
                          'Please enter new password',
                        ),
                      ),
                      const SizedBox(height: 12),
                      TextFormField(
                        controller: _confirmPasswordController,
                        obscureText: true,
                        style: const TextStyle(color: Colors.white),
                        cursorColor: Colors.white,
                        decoration: _darkInputDecoration(
                          'Confirm New Password',
                        ),
                        validator: _confirmPasswordValidator,
                      ),
                      const SizedBox(height: 16),
                      ElevatedButton(
                        onPressed: _resetPassword,
                        child: const Text('Update Password'),
                      ),
                      const SizedBox(height: 14),
                      Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 12,
                          vertical: 10,
                        ),
                        decoration: BoxDecoration(
                          color: Colors.black.withValues(alpha: 0.36),
                          borderRadius: BorderRadius.circular(12),
                          border: Border.all(
                            color: Colors.white.withValues(alpha: 0.35),
                          ),
                        ),
                        child: const Row(
                          children: [
                            Icon(Icons.support_agent, color: Colors.white),
                            SizedBox(width: 10),
                            Expanded(
                              child: Text(
                                'Help line no.: 8469283448',
                                style: TextStyle(
                                  color: Colors.white,
                                  fontWeight: FontWeight.w600,
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
