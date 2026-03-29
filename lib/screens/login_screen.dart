import 'dart:ui';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import 'agro_owner_screen.dart';
import 'forgot_password_screen.dart';
import 'home_screen.dart';
import 'register_screen.dart';
import '../utils/api_service.dart';
import '../utils/app_session.dart';

class LoginScreen extends StatefulWidget {
  const LoginScreen({super.key});

  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  final _formKey = GlobalKey<FormState>();
  final _mobileController = TextEditingController();
  final _passwordController = TextEditingController();
  static const String _loginLogoPath =
      'android/app/src/main/res/mipmap-xxxhdpi/ic_launcher.png';
  static const String _loginBackgroundPath = 'lib/assets/images/download.jpg';
  bool _showPasswordField = false;
  bool _obscurePassword = true;
  bool _isSubmitting = false;
  String _selectedLoginRole = 'farmer';

  @override
  void dispose() {
    _mobileController.dispose();
    _passwordController.dispose();
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

  String? _validatePassword(String? value) {
    if (!_showPasswordField) {
      return null;
    }
    if ((value ?? '').trim().isEmpty) {
      return 'Please enter password';
    }
    return null;
  }

  void _openForgotPassword() {
    Navigator.of(
      context,
    ).push(MaterialPageRoute(builder: (_) => const ForgotPasswordScreen()));
  }

  String _toDisplayDate(String? serverDate) {
    if (serverDate == null || serverDate.trim().isEmpty) {
      return '';
    }
    final parts = serverDate.split('-');
    if (parts.length != 3) {
      return serverDate;
    }
    return '${parts[2]}/${parts[1]}/${parts[0]}';
  }

  Future<void> _handleLogin() async {
    if (_isSubmitting) {
      return;
    }

    if (!(_formKey.currentState?.validate() ?? false)) {
      return;
    }

    final mobile = _mobileController.text.trim();

    try {
      setState(() {
        _isSubmitting = true;
      });

      final check = await ApiService.instance.mobileCheck(mobile);
      final exists = check['exists'] == true;

      if (!mounted) {
        return;
      }

      if (!exists) {
        await AppSession.savePendingRegistrationMobile(mobile);

        if (!mounted) {
          return;
        }

        Navigator.of(context).push(
          MaterialPageRoute(
            builder: (_) => RegisterScreen(
              mobileNumber: mobile,
              userRole: _selectedLoginRole,
            ),
          ),
        );
        return;
      }

      if (!_showPasswordField) {
        setState(() {
          _showPasswordField = true;
          _isSubmitting = false;
        });
        return;
      }

      final password = _passwordController.text.trim();
      if (password.isEmpty) {
        if (mounted) {
          setState(() {
            _isSubmitting = false;
          });
        }
        return;
      }

      final loginData = await ApiService.instance.login(
        mobile: mobile,
        password: password,
        userRole: _selectedLoginRole,
      );

      final token = loginData['token']?.toString();
      final user = (loginData['user'] as Map?)?.cast<String, dynamic>();
      if (token == null || token.isEmpty || user == null) {
        throw ApiException('Invalid login response');
      }

      await AppSession.saveToken(token);
      await AppSession.saveUserProfile(
        name: user['name']?.toString(),
        email: user['email']?.toString(),
        birthDate: _toDisplayDate(user['birth_date']?.toString()),
        preferredLanguage: user['preferred_language']?.toString(),
        userRole: user['user_role']?.toString(),
      );
      await AppSession.clearPendingRegistrationMobile();

      if (!mounted) {
        return;
      }

      final loggedInRole = user['user_role']?.toString() ?? _selectedLoginRole;

      if (loggedInRole == 'agro_center') {
        Navigator.of(context).pushAndRemoveUntil(
          MaterialPageRoute(
            builder: (_) => AgroOwnerScreen(
              initialUserName: user['name']?.toString(),
              initialUserEmail: user['email']?.toString(),
              initialUserBirthdate: _toDisplayDate(
                user['birth_date']?.toString(),
              ),
            ),
          ),
          (route) => false,
        );
        return;
      }

      Navigator.of(context).pushAndRemoveUntil(
        MaterialPageRoute(
          builder: (_) => HomeScreen(
            initialUserName: user['name']?.toString(),
            initialUserEmail: user['email']?.toString(),
            initialUserBirthdate: _toDisplayDate(
              user['birth_date']?.toString(),
            ),
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
        const SnackBar(content: Text('Login failed, please try again.')),
      );
    } finally {
      if (mounted) {
        setState(() {
          _isSubmitting = false;
        });
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      resizeToAvoidBottomInset: true,
      body: SizedBox.expand(
        child: Stack(
          fit: StackFit.expand,
          children: [
            Positioned.fill(
              child: ColoredBox(
                color: const Color(0xFF4E6F4A),
                child: Image.asset(
                  _loginBackgroundPath,
                  fit: BoxFit.cover,
                  alignment: Alignment.topCenter,
                ),
              ),
            ),
            Positioned.fill(
              child: ClipRect(
                child: BackdropFilter(
                  filter: ImageFilter.blur(sigmaX: 8, sigmaY: 8),
                  child: Container(color: Colors.white.withValues(alpha: 0.20)),
                ),
              ),
            ),
            SafeArea(
              bottom: false,
              child: SingleChildScrollView(
                padding: const EdgeInsets.fromLTRB(18, 18, 18, 0),
                child: Form(
                  key: _formKey,
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                    children: [
                      Text(
                        'Login',
                        style: Theme.of(context).textTheme.headlineSmall,
                      ),
                      const SizedBox(height: 18),
                      Center(
                        child: ClipRRect(
                          borderRadius: BorderRadius.circular(40),
                          child: SizedBox(
                            width: 220,
                            height: 220,
                            child: Image.asset(
                              _loginLogoPath,
                              fit: BoxFit.cover,
                              errorBuilder: (_, __, ___) => const SizedBox(
                                height: 220,
                                child: Center(
                                  child: Icon(
                                    Icons.agriculture,
                                    size: 120,
                                    color: Colors.green,
                                  ),
                                ),
                              ),
                            ),
                          ),
                        ),
                      ),
                      const SizedBox(height: 54),
                      Text(
                        'Welcome to Kishan Diary',
                        textAlign: TextAlign.center,
                        style: Theme.of(context).textTheme.headlineMedium
                            ?.copyWith(fontWeight: FontWeight.w500),
                      ),
                      const SizedBox(height: 36),
                      Text(
                        'Login Type',
                        style: Theme.of(context).textTheme.titleMedium
                            ?.copyWith(color: Colors.green.shade900),
                      ),
                      const SizedBox(height: 8),
                      DropdownButtonFormField<String>(
                        value: _selectedLoginRole,
                        decoration: InputDecoration(
                          hintText: 'Select Role',
                          filled: true,
                          fillColor: Colors.white.withValues(alpha: 0.72),
                          border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(14),
                          ),
                          enabledBorder: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(14),
                            borderSide: BorderSide(
                              color: Colors.green.shade700,
                              width: 2,
                            ),
                          ),
                          focusedBorder: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(14),
                            borderSide: BorderSide(
                              color: Colors.green.shade900,
                              width: 2,
                            ),
                          ),
                        ),
                        items: const [
                          DropdownMenuItem(
                            value: 'farmer',
                            child: Text('Farmer'),
                          ),
                          DropdownMenuItem(
                            value: 'agro_center',
                            child: Text('Agro Center'),
                          ),
                        ],
                        onChanged: (value) {
                          if (value == null) {
                            return;
                          }
                          setState(() {
                            _selectedLoginRole = value;
                          });
                        },
                      ),
                      const SizedBox(height: 14),
                      Text(
                        'Mobile Number',
                        style: Theme.of(context).textTheme.titleMedium
                            ?.copyWith(color: Colors.green.shade900),
                      ),
                      const SizedBox(height: 8),
                      TextFormField(
                        controller: _mobileController,
                        onChanged: (_) {
                          if (_showPasswordField) {
                            setState(() {
                              _showPasswordField = false;
                              _passwordController.clear();
                            });
                          }
                        },
                        keyboardType: TextInputType.phone,
                        inputFormatters: [
                          FilteringTextInputFormatter.digitsOnly,
                        ],
                        maxLength: 10,
                        decoration: InputDecoration(
                          counterText: '',
                          hintText: 'Mobile Number',
                          filled: true,
                          fillColor: Colors.white.withValues(alpha: 0.72),
                          contentPadding: const EdgeInsets.symmetric(
                            horizontal: 14,
                            vertical: 18,
                          ),
                          prefixIconConstraints: const BoxConstraints(
                            minWidth: 112,
                          ),
                          prefixIcon: Row(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              const SizedBox(width: 12),
                              const Text(
                                '🇮🇳',
                                style: TextStyle(fontSize: 18),
                              ),
                              const SizedBox(width: 6),
                              Text(
                                '+91',
                                style: Theme.of(context).textTheme.titleMedium,
                              ),
                              Icon(
                                Icons.arrow_drop_down,
                                color: Colors.grey.shade700,
                              ),
                              VerticalDivider(
                                color: Colors.green.shade200,
                                thickness: 1,
                                width: 12,
                              ),
                            ],
                          ),
                          enabledBorder: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(14),
                            borderSide: BorderSide(
                              color: Colors.green.shade700,
                              width: 2,
                            ),
                          ),
                          focusedBorder: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(14),
                            borderSide: BorderSide(
                              color: Colors.green.shade900,
                              width: 2,
                            ),
                          ),
                        ),
                        validator: _validateMobile,
                      ),
                      if (_showPasswordField) ...[
                        const SizedBox(height: 12),
                        Text(
                          'Password',
                          style: Theme.of(context).textTheme.titleMedium
                              ?.copyWith(color: Colors.green.shade900),
                        ),
                        const SizedBox(height: 8),
                        TextFormField(
                          controller: _passwordController,
                          obscureText: _obscurePassword,
                          decoration: InputDecoration(
                            hintText: 'Password',
                            filled: true,
                            fillColor: Colors.white.withValues(alpha: 0.72),
                            contentPadding: const EdgeInsets.symmetric(
                              horizontal: 14,
                              vertical: 18,
                            ),
                            suffixIcon: IconButton(
                              onPressed: () {
                                setState(() {
                                  _obscurePassword = !_obscurePassword;
                                });
                              },
                              icon: Icon(
                                _obscurePassword
                                    ? Icons.visibility_off
                                    : Icons.visibility,
                              ),
                            ),
                            enabledBorder: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(14),
                              borderSide: BorderSide(
                                color: Colors.green.shade700,
                                width: 2,
                              ),
                            ),
                            focusedBorder: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(14),
                              borderSide: BorderSide(
                                color: Colors.green.shade900,
                                width: 2,
                              ),
                            ),
                          ),
                          validator: _validatePassword,
                        ),
                      ],
                      const SizedBox(height: 18),
                      SizedBox(
                        height: 56,
                        child: DecoratedBox(
                          decoration: BoxDecoration(
                            gradient: const LinearGradient(
                              colors: [Color(0xFF2E8B57), Color(0xFFCFB45A)],
                            ),
                            borderRadius: BorderRadius.circular(28),
                            boxShadow: [
                              BoxShadow(
                                color: Colors.black.withValues(alpha: 0.2),
                                blurRadius: 10,
                                offset: const Offset(0, 6),
                              ),
                            ],
                          ),
                          child: ElevatedButton(
                            onPressed: _isSubmitting ? null : _handleLogin,
                            style: ElevatedButton.styleFrom(
                              backgroundColor: Colors.transparent,
                              foregroundColor: Colors.white,
                              shadowColor: Colors.transparent,
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(28),
                              ),
                            ),
                            child: Text(
                              _showPasswordField ? 'Login' : 'Continue',
                              style: TextStyle(
                                fontSize: 22,
                                fontWeight: FontWeight.w600,
                              ),
                            ),
                          ),
                        ),
                      ),
                      const SizedBox(height: 20),
                      TextButton(
                        onPressed: _openForgotPassword,
                        child: const Text(
                          'Forgot Password?',
                          style: TextStyle(fontSize: 17, color: Colors.white),
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
