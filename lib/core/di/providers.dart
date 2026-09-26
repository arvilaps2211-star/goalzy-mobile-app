import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../core/network/ai_service_stub.dart';
import '../../core/network/supabase_client_stub.dart';

/// Defaults to the mock backend. main.dart's bootstrap overrides this at
/// the ProviderScope level with a [RealSupabaseClient] — but only once
/// `Supabase.initialize()` has actually succeeded, not merely once
/// credentials were supplied (a configured-but-unreachable backend should
/// never make the whole app throw; see main.dart). Everything above this
/// layer only ever depends on the [SupabaseClientStub] interface, so
/// nothing else needs to change either way — see /supabase/BACKEND_SETUP.md.
final supabaseClientProvider = Provider<SupabaseClientStub>((ref) => MockSupabaseClient());

final aiServiceProvider = Provider<AiServiceStub>((ref) => MockAiService());
