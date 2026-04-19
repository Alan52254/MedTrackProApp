import '../../../core/models/google_calendar_activity.dart';

enum GoogleCalendarConnectionState {
  connected,
  connecting,
  demoMode,
  configurationRequired,
  connectionFailed,
}

enum GoogleCalendarSyncState { idle, syncing, syncSuccess, syncFailed }

class GoogleCalendarState {
  const GoogleCalendarState({
    required this.connectionState,
    required this.syncState,
    required this.isConnected,
    required this.isDemoMode,
    required this.configurationNeeded,
    required this.userEmail,
    required this.connectionError,
    required this.syncMessage,
    required this.activities,
    required this.isSyncing,
    required this.formTitle,
    required this.formStartTime,
    required this.formEndTime,
  });

  final GoogleCalendarConnectionState connectionState;
  final GoogleCalendarSyncState syncState;
  final bool isConnected;
  final bool isDemoMode;
  final bool configurationNeeded;
  final String userEmail;
  final String connectionError;
  final String syncMessage;
  final List<GoogleCalendarActivity> activities;
  final bool isSyncing;

  final String formTitle;
  final DateTime formStartTime;
  final DateTime formEndTime;

  GoogleCalendarState copyWith({
    GoogleCalendarConnectionState? connectionState,
    GoogleCalendarSyncState? syncState,
    bool? isConnected,
    bool? isDemoMode,
    bool? configurationNeeded,
    String? userEmail,
    String? connectionError,
    String? syncMessage,
    List<GoogleCalendarActivity>? activities,
    bool? isSyncing,
    String? formTitle,
    DateTime? formStartTime,
    DateTime? formEndTime,
  }) {
    return GoogleCalendarState(
      connectionState: connectionState ?? this.connectionState,
      syncState: syncState ?? this.syncState,
      isConnected: isConnected ?? this.isConnected,
      isDemoMode: isDemoMode ?? this.isDemoMode,
      configurationNeeded: configurationNeeded ?? this.configurationNeeded,
      userEmail: userEmail ?? this.userEmail,
      connectionError: connectionError ?? this.connectionError,
      syncMessage: syncMessage ?? this.syncMessage,
      activities: activities ?? this.activities,
      isSyncing: isSyncing ?? this.isSyncing,
      formTitle: formTitle ?? this.formTitle,
      formStartTime: formStartTime ?? this.formStartTime,
      formEndTime: formEndTime ?? this.formEndTime,
    );
  }
}
