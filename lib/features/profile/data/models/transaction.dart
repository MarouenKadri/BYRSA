import 'package:flutter/material.dart';
import '../../../../core/design/app_design_system.dart';

/// Types de transaction
enum TransactionType {
  income,      // Paiement reçu
  withdrawal,  // Retrait
  refund,      // Remboursement
  fee,         // Frais de service
  bonus,       // Bonus/Prime
}

extension TransactionTypeExtension on TransactionType {
  String get label {
    switch (this) {
      case TransactionType.income:
        return 'Paiement reçu';
      case TransactionType.withdrawal:
        return 'Retrait';
      case TransactionType.refund:
        return 'Remboursement';
      case TransactionType.fee:
        return 'Frais de service';
      case TransactionType.bonus:
        return 'Bonus';
    }
  }

  IconData get icon {
    switch (this) {
      case TransactionType.income:
        return Icons.arrow_downward_rounded;
      case TransactionType.withdrawal:
        return Icons.arrow_upward_rounded;
      case TransactionType.refund:
        return Icons.replay_rounded;
      case TransactionType.fee:
        return Icons.receipt_long_rounded;
      case TransactionType.bonus:
        return Icons.card_giftcard_rounded;
    }
  }

  Color get color {
    switch (this) {
      case TransactionType.income:
        return AppColors.success;
      case TransactionType.withdrawal:
        return AppColors.info;
      case TransactionType.refund:
        return Colors.orange;
      case TransactionType.fee:
        return Colors.red;
      case TransactionType.bonus:
        return Colors.purple;
    }
  }

  bool get isPositive {
    switch (this) {
      case TransactionType.income:
      case TransactionType.refund:
      case TransactionType.bonus:
        return true;
      case TransactionType.withdrawal:
      case TransactionType.fee:
        return false;
    }
  }
}

/// Statut de transaction
enum TransactionStatus {
  completed,
  pending,
  failed,
}

extension TransactionStatusExtension on TransactionStatus {
  String get label {
    switch (this) {
      case TransactionStatus.completed:
        return 'Effectué';
      case TransactionStatus.pending:
        return 'En cours';
      case TransactionStatus.failed:
        return 'Échoué';
    }
  }

  Color get color {
    switch (this) {
      case TransactionStatus.completed:
        return AppColors.success;
      case TransactionStatus.pending:
        return Colors.orange;
      case TransactionStatus.failed:
        return Colors.red;
    }
  }
}

/// Modèle de transaction
class Transaction {
  final String id;
  final TransactionType type;
  final TransactionStatus status;
  final double amount;
  final DateTime date;
  final String? description;
  final String? missionTitle;
  final String? clientName;
  final String? paymentMethod;

  Transaction({
    required this.id,
    required this.type,
    required this.status,
    required this.amount,
    required this.date,
    this.description,
    this.missionTitle,
    this.clientName,
    this.paymentMethod,
  });
}
