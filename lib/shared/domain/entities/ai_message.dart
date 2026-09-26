import 'package:equatable/equatable.dart';

enum AiMessageRole { user, assistant, system }

class AiMessage extends Equatable {
  const AiMessage({
    required this.id,
    required this.content,
    required this.role,
    required this.timestamp,
    this.contextCards = const [],
  });

  final String id;
  final String content;
  final AiMessageRole role;
  final DateTime timestamp;
  final List<String> contextCards;

  @override
  List<Object?> get props => [id, content, role];
}

class AiContextCard extends Equatable {
  const AiContextCard({
    required this.id,
    required this.title,
    required this.subtitle,
    required this.type,
  });

  final String id;
  final String title;
  final String subtitle;
  final String type;

  @override
  List<Object?> get props => [id, title];
}
