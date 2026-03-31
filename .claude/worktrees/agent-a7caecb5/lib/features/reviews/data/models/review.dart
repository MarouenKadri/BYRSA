import 'package:flutter/material.dart';

enum Satisfaction {
  insatisfait,
  correct,
  satisfait,
  tresSatisfait;

  String get label => switch (this) {
        Satisfaction.insatisfait  => 'Insatisfait',
        Satisfaction.correct      => 'Correct',
        Satisfaction.satisfait    => 'Satisfait',
        Satisfaction.tresSatisfait => 'Très satisfait',
      };

  IconData get icon => switch (this) {
        Satisfaction.insatisfait  => Icons.sentiment_very_dissatisfied_rounded,
        Satisfaction.correct      => Icons.sentiment_neutral_rounded,
        Satisfaction.satisfait    => Icons.sentiment_satisfied_rounded,
        Satisfaction.tresSatisfait => Icons.sentiment_very_satisfied_rounded,
      };

  int get stars => switch (this) {
        Satisfaction.insatisfait   => 2,
        Satisfaction.correct       => 3,
        Satisfaction.satisfait     => 4,
        Satisfaction.tresSatisfait => 5,
      };

  Color get color => switch (this) {
        Satisfaction.insatisfait  => const Color(0xFFEF4444),
        Satisfaction.correct      => const Color(0xFFF59E0B),
        Satisfaction.satisfait    => const Color(0xFF10B981),
        Satisfaction.tresSatisfait => const Color(0xFF6366F1),
      };

  static Satisfaction fromInt(int v) => switch (v) {
        1 => Satisfaction.insatisfait,
        2 => Satisfaction.correct,
        3 => Satisfaction.satisfait,
        _ => Satisfaction.tresSatisfait,
      };

  int toInt() => index + 1;
}

/// Modèle pour un avis utilisateur
class Review {
  final String id;
  final String revieweeId;
  final String reviewerId;
  final String reviewerName;
  final String reviewerAvatar;
  final Satisfaction satisfaction;
  final String comment;
  final String missionId;
  final String missionTitle;
  final DateTime createdAt;

  const Review({
    required this.id,
    required this.revieweeId,
    required this.reviewerId,
    required this.reviewerName,
    required this.reviewerAvatar,
    required this.satisfaction,
    required this.comment,
    required this.missionId,
    required this.missionTitle,
    required this.createdAt,
  });

  factory Review.fromJson(Map<String, dynamic> json) => Review(
        id: json['id'] as String,
        revieweeId: json['reviewee_id'] as String,
        reviewerId: json['reviewer_id'] as String,
        reviewerName: json['reviewer_name'] as String? ?? 'Anonyme',
        reviewerAvatar: json['reviewer_avatar'] as String? ?? '',
        satisfaction: Satisfaction.fromInt((json['rating'] as num).toInt()),
        comment: json['comment'] as String? ?? '',
        missionId: json['mission_id'] as String? ?? '',
        missionTitle: json['mission_title'] as String? ?? 'Mission',
        createdAt: DateTime.parse(json['created_at'] as String),
      );
}
