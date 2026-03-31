import '../../../data/models/mission.dart';

enum MissionUiRole { client, freelancer }
enum MissionUiTab { published, applied, inProgress, archived }

class MissionStatusUi {
  static bool belongsToTab({
    required MissionStatus status,
    required MissionUiRole role,
    required MissionUiTab tab,
  }) {
    switch (role) {
      case MissionUiRole.client:
        switch (tab) {
          case MissionUiTab.published:
            return status == MissionStatus.waitingCandidates ||
                status == MissionStatus.candidateReceived;
          case MissionUiTab.inProgress:
            return status == MissionStatus.prestaChosen ||
                status == MissionStatus.confirmed ||
                status == MissionStatus.onTheWay ||
                status == MissionStatus.inProgress ||
                status == MissionStatus.completionRequested ||
                status == MissionStatus.completed ||
                status == MissionStatus.waitingPayment;
          case MissionUiTab.archived:
            return status == MissionStatus.closed ||
                status == MissionStatus.cancelled ||
                status == MissionStatus.expired ||
                status == MissionStatus.dispute;
          case MissionUiTab.applied:
            return false;
        }
      case MissionUiRole.freelancer:
        switch (tab) {
          case MissionUiTab.applied:
            return status == MissionStatus.candidateReceived ||
                status == MissionStatus.prestaChosen;
          case MissionUiTab.inProgress:
            return status == MissionStatus.confirmed ||
                status == MissionStatus.onTheWay ||
                status == MissionStatus.inProgress ||
                status == MissionStatus.completionRequested ||
                status == MissionStatus.completed ||
                status == MissionStatus.waitingPayment;
          case MissionUiTab.archived:
            return status == MissionStatus.closed ||
                status == MissionStatus.cancelled ||
                status == MissionStatus.expired ||
                status == MissionStatus.dispute;
          case MissionUiTab.published:
            return false;
        }
    }
  }

  static String badgeLabel({
    required MissionStatus status,
    required MissionUiRole role,
  }) {
    switch (role) {
      case MissionUiRole.client:
        return switch (status) {
          MissionStatus.draft => 'Publiee',
          MissionStatus.waitingCandidates => 'Publiee',
          MissionStatus.candidateReceived => 'Publiee',
          MissionStatus.prestaChosen => 'Confirmee',
          MissionStatus.confirmed => 'Confirmee',
          MissionStatus.onTheWay => 'En cours',
          MissionStatus.inProgress => 'En cours',
          MissionStatus.completionRequested => 'Validation requise',
          MissionStatus.completed => 'Terminee',
          MissionStatus.waitingPayment => 'Terminee',
          MissionStatus.closed => 'Terminee',
          MissionStatus.cancelled => 'Annulee',
          MissionStatus.dispute => 'Annulee',
          MissionStatus.expired => 'Annulee',
        };
      case MissionUiRole.freelancer:
        return switch (status) {
          MissionStatus.draft => 'Postulee',
          MissionStatus.waitingCandidates => 'Postulee',
          MissionStatus.candidateReceived => 'Postulee',
          MissionStatus.prestaChosen => 'Postulee',
          MissionStatus.confirmed => 'Confirmee',
          MissionStatus.onTheWay => 'En cours',
          MissionStatus.inProgress => 'En cours',
          MissionStatus.completionRequested => 'Validation client',
          MissionStatus.completed => 'Paiement en attente',
          MissionStatus.waitingPayment => 'Paiement en attente',
          MissionStatus.closed => 'Terminee',
          MissionStatus.cancelled => 'Annulee',
          MissionStatus.dispute => 'Annulee',
          MissionStatus.expired => 'Annulee',
        };
    }
  }
}
