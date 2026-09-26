/// Backend connection configuration, supplied at build/run time via
/// --dart-define — never hardcoded, never committed. See
/// /supabase/BACKEND_SETUP.md for the full connection walkthrough.
///
/// Example:
///   flutter run \
///     --dart-define=SUPABASE_URL=https://your-project.supabase.co \
///     --dart-define=SUPABASE_ANON_KEY=your-anon-key
///
/// Only the anon/publishable key ever belongs here — never a service-role
/// or secret key, which must never exist inside a Flutter client at all.
abstract final class BackendConfig {
  static const supabaseUrl = String.fromEnvironment('SUPABASE_URL');
  static const supabaseAnonKey = String.fromEnvironment('SUPABASE_ANON_KEY');

  /// True only when both values were actually supplied at build time. The
  /// app falls back to its existing mock backend whenever this is false
  /// (see core/di/providers.dart), so it keeps working exactly as before
  /// for anyone who hasn't connected a real project yet — connecting a
  /// backend is opt-in, not a requirement to run the app.
  static bool get isConfigured => supabaseUrl.isNotEmpty && supabaseAnonKey.isNotEmpty;
}
