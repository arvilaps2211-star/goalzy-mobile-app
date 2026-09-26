import '../../../../shared/domain/entities/focus_session.dart';
import '../../domain/repositories/focus_repository.dart';

class MockFocusRepository implements FocusRepository {
  final List<FocusSession> _sessions = [];

  @override
  Future<List<FocusSession>> getSessions() async => List.unmodifiable(_sessions);

  @override
  Future<FocusSession> logSession(FocusSession session) async {
    _sessions.add(session);
    return session;
  }
}
