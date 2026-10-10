import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:fiamas_app/features/auth/presentation/screens/welcome_screen.dart';

void main() {
  testWidgets('La pantalla de bienvenida muestra el saludo', (tester) async {
    await tester.pumpWidget(const MaterialApp(home: WelcomeScreen()));

    expect(find.text('BIENVENIDO'), findsOneWidget);
    expect(find.text('Inicia sesión'), findsOneWidget);
  });
}