/// Stub for future FastAPI + Gemini integration.
abstract class AiServiceStub {
  Future<String> chat({
    required String message,
    required Map<String, dynamic> context,
  });

  Future<List<String>> getSuggestions({required Map<String, dynamic> context});
  Future<Map<String, dynamic>> analyzeProductivity({required Map<String, dynamic> context});
}

class MockAiService implements AiServiceStub {
  @override
  Future<String> chat({
    required String message,
    required Map<String, dynamic> context,
  }) async {
    await Future<void>.delayed(const Duration(milliseconds: 1200));
    return 'Based on your current goals and habits, I recommend focusing on your top priority task first. '
        'Your energy levels are highest in the morning — schedule deep work then.';
  }

  @override
  Future<List<String>> getSuggestions({required Map<String, dynamic> context}) async {
    await Future<void>.delayed(const Duration(milliseconds: 600));
    return [
      'Complete your morning workout before 9 AM',
      'Review Q2 goal milestones this afternoon',
      'Schedule a 25-min focus block for coding',
    ];
  }

  @override
  Future<Map<String, dynamic>> analyzeProductivity({
    required Map<String, dynamic> context,
  }) async {
    await Future<void>.delayed(const Duration(milliseconds: 800));
    return {
      'score': 78,
      'trend': 'up',
      'insights': ['Strong habit consistency', 'Task completion up 12%'],
    };
  }
}
