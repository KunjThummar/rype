import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:provider/provider.dart';

import 'screens/add_mutual_fund_screen.dart';
import 'screens/add_stock_screen.dart';
import 'screens/dashboard_screen.dart';
import 'screens/holdings_screen.dart';
import 'screens/login_screen.dart';
import 'screens/mutual_funds_screen.dart';
import 'screens/register_screen.dart';
import 'screens/settings_screen.dart';
import 'screens/stocks_screen.dart';
import 'screens/tax_dashboard_screen.dart';
import 'screens/transactions_screen.dart';
import 'screens/what_if_screen.dart';
import 'theme/app_theme.dart';
import 'theme/theme_controller.dart';
import 'core/services/storage_service.dart';

void main() {
  WidgetsFlutterBinding.ensureInitialized();
  SystemChrome.setSystemUIOverlayStyle(
    const SystemUiOverlayStyle(statusBarColor: Colors.transparent),
  );
  runApp(
    ChangeNotifierProvider(
      create: (_) => ThemeController(),
      child: const MyApp(),
    ),
  );
}

class MyApp extends StatefulWidget {
  const MyApp({super.key});

  @override
  State<MyApp> createState() => _MyAppState();
}

class _MyAppState extends State<MyApp> {
  late Future<String?> _tokenCheck;

  @override
  void initState() {
    super.initState();
    _tokenCheck = StorageService.getToken();
  }

  @override
  Widget build(BuildContext context) {
    final themeController = context.watch<ThemeController>();

    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'Rype - Investment Tracker',
      theme: AppTheme.light(),
      darkTheme: AppTheme.dark(),
      themeMode: themeController.mode,
      home: FutureBuilder<String?>(
        future: _tokenCheck,
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Scaffold(
              body: Center(child: CircularProgressIndicator()),
            );
          }
          
          // Route to dashboard if token exists, else to login
          final hasToken = snapshot.data != null;
          return hasToken ? const DashboardScreen() : const LoginScreen();
        },
      ),
      routes: {
        '/login': (context) => const LoginScreen(),
        '/register': (context) => const RegisterScreen(),
        '/dashboard': (context) => const DashboardScreen(),
        '/settings': (context) => const SettingsScreen(),
        '/stocks': (context) => const StocksScreen(),
        '/add-stock': (context) => const AddStockScreen(),
        '/mutual-funds': (context) => const MutualFundsScreen(),
        '/add-mutual-fund': (context) => const AddMutualFundScreen(),
        '/transactions': (context) => const TransactionsScreen(),
        '/holdings': (context) => const HoldingsScreen(),
        '/tax-dashboard': (context) => const TaxDashboardScreen(),
        '/what-if': (context) => const WhatIfScreen(),
      },
    );
  }
}
