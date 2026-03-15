import 'dart:ui';

import 'package:flutter/material.dart';

import 'home_screen.dart';
import '../utils/api_service.dart';
import '../utils/app_session.dart';

class RegisterScreen extends StatefulWidget {
  const RegisterScreen({super.key, required this.mobileNumber});

  final String mobileNumber;

  @override
  State<RegisterScreen> createState() => _RegisterScreenState();
}

class _RegisterScreenState extends State<RegisterScreen> {
  static const String _backgroundImagePath = 'lib/assets/images/download.jpg';
  static const String _registerLogoPath = 'lib/assets/images/register.png';
  final _formKey = GlobalKey<FormState>();
  final _nameController = TextEditingController();
  final _mobileController = TextEditingController();
  final _emailController = TextEditingController();
  final _birthdateController = TextEditingController();
  final _passwordController = TextEditingController();
  final _confirmPasswordController = TextEditingController();

  DateTime? _selectedBirthdate;

  @override
  void initState() {
    super.initState();
    _mobileController.text = widget.mobileNumber;
    _loadPendingMobile();
  }

  @override
  void dispose() {
    _nameController.dispose();
    _mobileController.dispose();
    _emailController.dispose();
    _birthdateController.dispose();
    _passwordController.dispose();
    _confirmPasswordController.dispose();
    super.dispose();
  }

  Future<void> _loadPendingMobile() async {
    final pendingMobile = await AppSession.getPendingRegistrationMobile();
    if (!mounted) {
      return;
    }
    if (pendingMobile == null || pendingMobile.trim().isEmpty) {
      return;
    }

    if (widget.mobileNumber.trim().isEmpty) {
      setState(() {
        _mobileController.text = pendingMobile.trim();
      });
    }
  }

  String? _requiredValidator(String? value) {
    if ((value ?? '').trim().isEmpty) {
      return 'This field is required';
    }
    return null;
  }

  String? _confirmPasswordValidator(String? value) {
    if ((value ?? '').isEmpty) {
      return 'Please confirm password';
    }
    if (value != _passwordController.text) {
      return 'Passwords do not match';
    }
    return null;
  }

  String? _mobileValidator(String? value) {
    final mobile = (value ?? '').trim();
    if (mobile.isEmpty) {
      return 'Please enter mobile number';
    }
    if (!RegExp(r'^\d{10}$').hasMatch(mobile)) {
      return 'Enter valid 10 digit mobile number';
    }
    return null;
  }

  String? _emailValidator(String? value) {
    final email = (value ?? '').trim();
    if (email.isEmpty) {
      return 'Please enter email';
    }
    if (!RegExp(r'^[\w.\-]+@([\w\-]+\.)+[A-Za-z]{2,}$').hasMatch(email)) {
      return 'Enter valid email';
    }
    return null;
  }

  InputDecoration _darkInputDecoration(String label, {Widget? suffixIcon}) {
    return InputDecoration(
      labelText: label,
      labelStyle: TextStyle(color: Colors.white.withValues(alpha: 0.92)),
      filled: true,
      fillColor: Colors.black.withValues(alpha: 0.42),
      suffixIcon: suffixIcon,
      suffixIconColor: Colors.white.withValues(alpha: 0.85),
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

  void _submit() {
    _register();
  }

  Future<void> _register() async {
    if (!(_formKey.currentState?.validate() ?? false)) {
      return;
    }

    if (_selectedBirthdate == null) {
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(const SnackBar(content: Text('Please select birthdate')));
      return;
    }

    try {
      final registerData = await ApiService.instance.register(
        name: _nameController.text.trim(),
        email: _emailController.text.trim(),
        mobile: _mobileController.text.trim(),
        birthDate: _birthdateController.text.trim(),
        password: _passwordController.text,
        passwordConfirmation: _confirmPasswordController.text,
      );

      final token = registerData['token']?.toString();
      final user = (registerData['user'] as Map?)?.cast<String, dynamic>();

      if (token == null || token.isEmpty || user == null) {
        throw ApiException('Invalid register response');
      }

      await AppSession.saveToken(token);
      await AppSession.saveUserProfile(
        name: user['name']?.toString(),
        email: user['email']?.toString(),
        birthDate: _birthdateController.text.trim(),
        preferredLanguage: user['preferred_language']?.toString(),
      );
      await AppSession.clearPendingRegistrationMobile();

      if (!mounted) {
        return;
      }

      Navigator.of(context).pushAndRemoveUntil(
        MaterialPageRoute(
          builder: (_) => HomeScreen(
            initialUserName:
                user['name']?.toString() ?? _nameController.text.trim(),
            initialUserEmail:
                user['email']?.toString() ?? _emailController.text.trim(),
            initialUserBirthdate: _birthdateController.text.trim(),
            initialUserPassword: _passwordController.text,
          ),
        ),
        (route) => false,
      );
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
        const SnackBar(content: Text('Registration failed, please try again.')),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Register')),
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
                        readOnly: widget.mobileNumber.trim().isNotEmpty,
                        style: const TextStyle(color: Colors.white),
                        cursorColor: Colors.white,
                        decoration: _darkInputDecoration('Mobile Number'),
                        validator: _mobileValidator,
                      ),
                      const SizedBox(height: 12),
                      TextFormField(
                        controller: _nameController,
                        style: const TextStyle(color: Colors.white),
                        cursorColor: Colors.white,
                        decoration: _darkInputDecoration('Name'),
                        validator: _requiredValidator,
                      ),
                      const SizedBox(height: 12),
                      TextFormField(
                        controller: _emailController,
                        keyboardType: TextInputType.emailAddress,
                        style: const TextStyle(color: Colors.white),
                        cursorColor: Colors.white,
                        decoration: _darkInputDecoration('Email'),
                        validator: _emailValidator,
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
                        validator: _requiredValidator,
                      ),
                      const SizedBox(height: 12),
                      TextFormField(
                        controller: _passwordController,
                        obscureText: true,
                        style: const TextStyle(color: Colors.white),
                        cursorColor: Colors.white,
                        decoration: _darkInputDecoration('Password'),
                        validator: _requiredValidator,
                      ),
                      const SizedBox(height: 12),
                      TextFormField(
                        controller: _confirmPasswordController,
                        obscureText: true,
                        style: const TextStyle(color: Colors.white),
                        cursorColor: Colors.white,
                        decoration: _darkInputDecoration('Confirm Password'),
                        validator: _confirmPasswordValidator,
                      ),
                      const SizedBox(height: 16),
                      ElevatedButton(
                        onPressed: _submit,
                        child: const Text('Submit'),
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
