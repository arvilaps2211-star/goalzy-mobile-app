/// Supabase credentials, supplied at build/run time via `--dart-define` —
/// never hardcoded in source, never committed anywhere.
///
/// Example:
///   flutter run \
///     --dart-define=SUPABASE_URL=https://your-project.supabase.co \
///     --dart-define=SUPABASE_ANON_KEY=your-anon-key
///
/// For a persistent local setup, create a `dart_defines.json` (gitignored)
/// and pass `--dart-define-from-file=dart_defines.json` instead of typing
/// both flags every time.
///
/// If either value is left unset, [isConfigured] is false and the app
/// automatically falls back to the mock backend (see core/di/providers
/// .dart) — GOALZY is fully usable with zero backend configuration; real
/// credentials only need to exist once you actually want live data.
abstract final class SupabaseConfig {
  static const String url = String.fromEnvironment('SUPABASE_URL');
  static const String anonKey = String.fromEnvironment('SUPABASE_ANON_KEY');

  static bool get isConfigured => url.isNotEmpty && anonKey.isNotEmpty;
}
