import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:venturelink/features/auth/presentation/login_screen.dart';
import 'package:venturelink/core/theme/app_theme.dart';

void main() {
  Widget buildApp() => ProviderScope(
        child: MaterialApp(
          theme: AppTheme.lightTheme,
          home: const LoginScreen(),
        ),
      );

  testWidgets('LoginScreen renders email and password fields', (tester) async {
    await tester.pumpWidget(buildApp());
    expect(find.byType(TextFormField), findsNWidgets(2));
  });

  testWidgets('LoginScreen shows validation error for empty fields', (tester) async {
    await tester.pumpWidget(buildApp());
    final loginButton = find.widgetWithText(ElevatedButton, 'Login');
    await tester.tap(loginButton);
    await tester.pumpAndSettle();
    expect(find.text('Email is required'), findsOneWidget);
  });

  testWidgets('LoginScreen shows forgot password link', (tester) async {
    await tester.pumpWidget(buildApp());
    expect(find.text('Forgot Password?'), findsOneWidget);
  });

  testWidgets('LoginScreen shows register link', (tester) async {
    await tester.pumpWidget(buildApp());
    expect(find.text('Register'), findsOneWidget);
  });
}