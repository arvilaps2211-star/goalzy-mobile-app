// Minimal smoke test — confirms GoalzyApp actually boots and renders its
// own branding, rather than the stock `flutter create` counter-app test
// that was here before (which checked for a '+' icon and '0'/'1' counter
// text — neither of which exist anywhere in this app; it would have
// failed on the very first assertion regardless of anything else here).

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'package:goalzy/main.dart';

void main() {
  testWidgets('GoalzyApp boots and shows the splash screen', (WidgetTester tester) async {
    // SharedPreferences is read during startup (auth session restoration
    // in AuthNotifier, and appearance preferences in AppearanceNotifier)
    // — mock it so those calls don't hit a real platform channel here.
    SharedPreferences.setMockInitialValues({});

    await tester.pumpWidget(const ProviderScope(child: GoalzyApp()));
    // One pump is enough to confirm the app boots without throwing and
    // renders its own branding — not waiting out the full session-restore
    // + minimum-delay sequence Splash uses before it navigates away.
    await tester.pump();

    expect(find.text('GOALZY'), findsOneWidget);
  });
}
