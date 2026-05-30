import 'package:flutter/material.dart';
import 'package:petcare_mobile/providers/auth_provider.dart';
import 'package:petcare_mobile/screens/main_screen.dart'; // <-- IMPORTAMOS MAINSCREEN
import 'package:petcare_mobile/screens/welcome/welcome_screen.dart';
import 'package:provider/provider.dart';

class AuthWrapper extends StatelessWidget {
  const AuthWrapper({super.key});

  @override
  Widget build(BuildContext context) {
    return Consumer<AuthProvider>(
      builder: (context, auth, child) {
        switch (auth.status) {
          case AuthStatus.uninitialized:
          case AuthStatus.authenticating:
            return const Scaffold(
              body: Center(
                child: CircularProgressIndicator(),
              ),
            );
          case AuthStatus.authenticated:
            // Si está autenticado, muestra la pantalla principal con navegación
            return const MainScreen(); // <-- CAMBIO AQUÍ
          case AuthStatus.unauthenticated:
            return const WelcomeScreen();
        }
      },
    );
  }
}