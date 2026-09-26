import 'package:flutter/material.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:supabase_flutter/supabase_flutter.dart' as sb;
import 'core/config/backend_config.dart';
import 'core/di/providers.dart';
import 'core/network/real_supabase_client.dart';
import 'core/routing/app_router.dart';
import 'core/theme/app_theme.dart';
import 'features/settings/presentation/providers/appearance_provider.dart';
import 'features/settings/presentation/screens/settings_screen.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();

  // Only attempted when SUPABASE_URL/SUPABASE_ANON_KEY were actually
  // supplied at build time (see core/config/backend_config.dart) — most
  // people running this project won't have set that up, and the app must
  // keep working perfectly on its existing mock backend in that case.
  // `backendReady` (not just "was configured") tracks whether
  // Supabase.initialize() genuinely succeeded, so a wrong URL/key or no
  // network never blocks startup or crashes the app — it just quietly
  // falls back to mock, the same as not configuring a backend at all.
  var backendReady = false;
  if (BackendConfig.isConfigured) {
    try {
      await sb.Supabase.initialize(
        url: BackendConfig.supabaseUrl,
        anonKey: BackendConfig.supabaseAnonKey,
      );
      backendReady = true;
    } catch (e) {
      debugPrint('Supabase.initialize failed — continuing on the mock backend: $e');
    }
  }

  runApp(
    ProviderScope(
      overrides: [
        if (backendReady) supabaseClientProvider.overrideWith((ref) => RealSupabaseClient()),
      ],
      child: const GoalzyApp(),
    ),
  );
}

class GoalzyApp extends ConsumerWidget {
  const GoalzyApp({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final router = ref.watch(routerProvider);
    final settings = ref.watch(settingsProvider);
    final appearance = ref.watch(appearanceProvider);
    final themeMode = switch (settings.themeMode) {
      AppThemeMode.light => ThemeMode.light,
      AppThemeMode.dark => ThemeMode.dark,
      AppThemeMode.system => ThemeMode.system,
    };

    return MaterialApp.router(
      title: 'GOALZY',
      debugShowCheckedModeBanner: false,
      theme: AppTheme.lightTheme(
        accentOverride: accentColorFor(appearance.accent, Brightness.light),
        fontBuilder: (base) => applyFont(appearance.font, base),
      ),
      darkTheme: AppTheme.darkTheme(
        accentOverride: accentColorFor(appearance.accent, Brightness.dark),
        fontBuilder: (base) => applyFont(appearance.font, base),
      ),
      themeMode: themeMode,
      routerConfig: router,
      builder: (context, child) {
        final brightness = Theme.of(context).brightness;
        SystemChrome.setSystemUIOverlayStyle(
          SystemUiOverlayStyle(
            statusBarColor: Colors.transparent,
            statusBarIconBrightness: brightness == Brightness.dark ? Brightness.light : Brightness.dark,
            systemNavigationBarColor: brightness == Brightness.dark ? const Color(0xFF0F1117) : const Color(0xFFF6F7FB),
            systemNavigationBarIconBrightness: brightness == Brightness.dark ? Brightness.light : Brightness.dark,
          ),
        );
        return child ?? const SizedBox.shrink();
      },
    );
  }
}
