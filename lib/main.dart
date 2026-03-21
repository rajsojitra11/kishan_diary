import 'package:flutter/material.dart';

import 'screens/home_screen.dart';
import 'screens/login_screen.dart';
import 'utils/app_session.dart';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'Kishan Diary',
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(seedColor: Colors.green),
      ),
      home: const _SessionBootstrapScreen(),
    );
  }
}

class _SessionBootstrapScreen extends StatefulWidget {
  const _SessionBootstrapScreen();

  @override
  State<_SessionBootstrapScreen> createState() =>
      _SessionBootstrapScreenState();
}

class _SessionBootstrapScreenState extends State<_SessionBootstrapScreen> {
  late final Future<_SessionBootstrapData> _bootstrapFuture =
      _loadBootstrapData();

  Future<_SessionBootstrapData> _loadBootstrapData() async {
    final token = await AppSession.getToken();
    final isLoggedIn = token != null && token.trim().isNotEmpty;

    if (!isLoggedIn) {
      return const _SessionBootstrapData(isLoggedIn: false);
    }

    final profile = await AppSession.getUserProfile();
    return _SessionBootstrapData(
      isLoggedIn: true,
      name: profile['name'],
      email: profile['email'],
      birthDate: profile['birth_date'],
    );
  }

  @override
  Widget build(BuildContext context) {
    return FutureBuilder<_SessionBootstrapData>(
      future: _bootstrapFuture,
      builder: (context, snapshot) {
        if (snapshot.connectionState != ConnectionState.done) {
          return const Scaffold(
            body: Center(child: CircularProgressIndicator()),
          );
        }

        final data = snapshot.data;
        if (data == null || !data.isLoggedIn) {
          return const LoginScreen();
        }

        return HomeScreen(
          initialUserName: data.name,
          initialUserEmail: data.email,
          initialUserBirthdate: data.birthDate,
        );
      },
    );
  }
}

class _SessionBootstrapData {
  final bool isLoggedIn;
  final String? name;
  final String? email;
  final String? birthDate;

  const _SessionBootstrapData({
    required this.isLoggedIn,
    this.name,
    this.email,
    this.birthDate,
  });
}
