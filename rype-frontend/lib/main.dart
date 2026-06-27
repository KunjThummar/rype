import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:provider/provider.dart';

import 'screens/add_mutual_fund_screen.dart';
import 'screens/add_stock_screen.dart';
import 'screens/dashboard_screen.dart';
import 'screens/holdings_screen.dart';
import 'screens/intro_screen.dart';
import 'screens/import_history_screen.dart';
import 'screens/import_portfolio_screen.dart';
import 'screens/login_screen.dart';
import 'screens/mutual_funds_screen.dart';
import 'screens/register_screen.dart';
import 'screens/settings_screen.dart';
import 'screens/stocks_screen.dart';
import 'screens/tax_dashboard_screen.dart';
import 'screens/transactions_screen.dart';
import 'screens/what_if_screen.dart';
import 'core/providers/market_provider.dart';
import 'theme/app_theme.dart';
import 'theme/theme_controller.dart';
import 'core/services/storage_service.dart';

void main() {
  WidgetsFlutterBinding.ensureInitialized();
  SystemChrome.setSystemUIOverlayStyle(
    const SystemUiOverlayStyle(statusBarColor: Colors.transparent),
  );
  runApp(
    MultiProvider(
      providers: [
        ChangeNotifierProvider(create: (_) => ThemeController()),
        ChangeNotifierProvider(
          create: (_) => MarketProvider()..startAutoRefresh(),
        ),
      ],
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
  late Future<_StartupState> _startupCheck;

  @override
  void initState() {
    super.initState();
    _startupCheck = _loadStartupState();
  }

  Future<_StartupState> _loadStartupState() async {
    final token = await StorageService.getToken();
    final hasCompletedIntro = await StorageService.hasCompletedIntro();
    return _StartupState(
      hasToken: token != null,
      hasCompletedIntro: hasCompletedIntro,
    );
  }

  @override
  Widget build(BuildContext context) {
    final themeController = context.watch<ThemeController>();

    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'Rype',
      theme: AppTheme.light(),
      darkTheme: AppTheme.dark(),
      themeMode: themeController.mode,
      home: FutureBuilder<_StartupState>(
        future: _startupCheck,
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Scaffold(
              body: Center(child: CircularProgressIndicator()),
            );
          }

          final state = snapshot.data;
          if (state?.hasToken ?? false) return const DashboardScreen();
          if (state?.hasCompletedIntro ?? false) return const LoginScreen();
          return const IntroScreen();
        },
      ),
      routes: {
        '/intro': (context) => const IntroScreen(),
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
        '/imports': (context) => const ImportPortfolioScreen(),
        '/imports/history': (context) => const ImportHistoryScreen(),
        '/tax-dashboard': (context) => const TaxDashboardScreen(),
        '/what-if': (context) => const WhatIfScreen(),
      },
    );
  }
}

class _StartupState {
  const _StartupState({
    required this.hasToken,
    required this.hasCompletedIntro,
  });

  final bool hasToken;
  final bool hasCompletedIntro;
}
