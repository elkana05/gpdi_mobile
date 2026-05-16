import 'dart:io';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:intl/date_symbol_data_local.dart';
import 'package:flutter_localizations/flutter_localizations.dart';

import 'core/router/app_router.dart';
import 'features/auth/providers/auth_provider.dart';
import 'features/auth/providers/user_provider.dart';
import 'features/jemaataktif/providers/admin_provider.dart';
import 'features/jemaatpublik/providers/content_provider.dart';
import 'features/jemaatpublik/providers/event_provider.dart';

class MyHttpOverrides extends HttpOverrides {
  @override
  HttpClient createHttpClient(SecurityContext? context) {
    return super.createHttpClient(context)
      ..badCertificateCallback =
          (X509Certificate cert, String host, int port) => true;
  }
}

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await initializeDateFormatting('id_ID', null);
  HttpOverrides.global = MyHttpOverrides();

  final authProvider = AuthProvider();
  await authProvider.checkAuth();

  runApp(
    MultiProvider(
      providers: [
        ChangeNotifierProvider.value(value: authProvider),
        ChangeNotifierProvider(create: (_) => UserProvider()),
        ChangeNotifierProvider(create: (_) => ContentProvider()),
        ChangeNotifierProvider(create: (_) => EventProvider()),
        ChangeNotifierProvider(create: (_) => AdminProvider()),
      ],
      child: const GPdISibuleleApp(),
    ),
  );
}

class GPdISibuleleApp extends StatelessWidget {
  const GPdISibuleleApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp.router(
      title: 'GPdI Sibulele',
      debugShowCheckedModeBanner: false,
      routerConfig: appRouter,
      localizationsDelegates: const [
        GlobalMaterialLocalizations.delegate,
        GlobalWidgetsLocalizations.delegate,
        GlobalCupertinoLocalizations.delegate,
      ],
      supportedLocales: const [
        Locale('id', 'ID'),
        Locale('en', 'US'),
      ],
      locale: const Locale('id', 'ID'),
      theme: ThemeData(
        useMaterial3: true,
        colorScheme: ColorScheme.fromSeed(
          seedColor: const Color(0xFF05066F),
          primary: const Color(0xFF05066F),
          secondary: const Color(0xFFC5A327),
        ),
        textTheme: GoogleFonts.montserratTextTheme(Theme.of(context).textTheme),
        elevatedButtonTheme: ElevatedButtonThemeData(
          style: ElevatedButton.styleFrom(
            backgroundColor: const Color(0xFF05066F),
            foregroundColor: Colors.white,
            // Perbaikan: Jangan gunakan double.infinity di sini karena merusak tombol di dalam Row
            minimumSize: const Size(88, 54),
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
            elevation: 2,
          ),
        ),
      ),
    );
  }
}
