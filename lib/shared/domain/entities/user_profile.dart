import 'package:equatable/equatable.dart';

class UserProfile extends Equatable {
  const UserProfile({
    required this.id,
    required this.email,
    required this.displayName,
    this.avatarUrl,
    this.level = 1,
    this.xp = 0,
    this.credits = 100,
    this.streakDays = 0,
    this.isPremium = false,
    this.createdAt,
  });

  final String id;
  final String email;
  final String displayName;
  final String? avatarUrl;
  final int level;
  final int xp;
  final int credits;
  final int streakDays;
  final bool isPremium;
  final DateTime? createdAt;

  int get xpToNextLevel => 1000 - (xp % 1000);
  double get levelProgress => (xp % 1000) / 1000;

  UserProfile copyWith({
    String? email,
    String? displayName,
    String? avatarUrl,
    int? level,
    int? xp,
    int? credits,
    int? streakDays,
    bool? isPremium,
  }) {
    return UserProfile(
      id: id,
      email: email ?? this.email,
      displayName: displayName ?? this.displayName,
      avatarUrl: avatarUrl ?? this.avatarUrl,
      level: level ?? this.level,
      xp: xp ?? this.xp,
      credits: credits ?? this.credits,
      streakDays: streakDays ?? this.streakDays,
      isPremium: isPremium ?? this.isPremium,
      createdAt: createdAt,
    );
  }

  @override
  List<Object?> get props => [id, email, displayName, level, xp, credits, streakDays];
}
