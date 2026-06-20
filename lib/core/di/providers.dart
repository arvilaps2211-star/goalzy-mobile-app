import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../core/network/ai_service_stub.dart';
import '../../core/network/supabase_client_stub.dart';

final supabaseClientProvider = Provider<SupabaseClientStub>((ref) => MockSupabaseClient());
final aiServiceProvider = Provider<AiServiceStub>((ref) => MockAiService());
