import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:family_connect_stable/src/core/router/app_router.dart';

class FamilyConnectApp extends ConsumerWidget {
  const FamilyConnectApp({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final router = ref.watch(appRouterProvider);
    return MaterialApp.router(
      title: 'Family Connect',
      theme: ThemeData(
        primaryColor: const Color(0xFF0A2F44),
        colorScheme: const ColorScheme.light(
          primary: Color(0xFF0A2F44),
          secondary: Color(0xFFD4AF37),
        ),
        scaffoldBackgroundColor: const Color(0xFF0A2F44),
      ),
      debugShowCheckedModeBanner: false, // <-- Add this line
      routerConfig: router,
    );
  }
}