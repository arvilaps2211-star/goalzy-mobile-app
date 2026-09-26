import '../../../../shared/domain/entities/focus_session.dart';

abstract class FocusRepository {
  Future<List<FocusSession>> getSessions();
  Future<FocusSession> logSession(FocusSession session);
}
