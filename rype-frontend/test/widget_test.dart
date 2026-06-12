import 'package:flutter_test/flutter_test.dart';
import 'package:provider/provider.dart';

import 'package:frontend/main.dart';
import 'package:frontend/theme/theme_controller.dart';

void main() {
  testWidgets('Rype starts on login screen', (WidgetTester tester) async {
    await tester.pumpWidget(
      ChangeNotifierProvider(
        create: (_) => ThemeController(),
        child: const MyApp(),
      ),
    );

    expect(find.text('Welcome back'), findsOneWidget);
    expect(find.text('Sign in to access your portfolio'), findsOneWidget);
  });
}
