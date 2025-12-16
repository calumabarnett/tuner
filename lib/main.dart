import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:tuner/src/features/home/presentation/home_screen.dart';
import 'package:tuner/src/features/settings/presentation/theme_provider.dart';
import 'package:tuner/src/theme/koda_theme.dart';

void main() {
  runApp(const ProviderScope(child: MainApp()));
}

class MainApp extends ConsumerWidget {
  const MainApp({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final themeMode = ref.watch(themeModeProvider);

    return MaterialApp(
      title: 'Koda',
      theme: KodaTheme.light,
      darkTheme: KodaTheme.dark,
      themeMode: themeMode,
      home: const HomeScreen(),
      debugShowCheckedModeBanner: false,
    );
  }
}
