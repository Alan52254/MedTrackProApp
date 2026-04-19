import 'package:flutter/foundation.dart';

import '../../../core/models/google_calendar_activity.dart';
import '../../../core/services/google_calendar_service.dart';
import '../../../core/services/local_demo_store.dart';
import 'google_calendar_state.dart';

/// Controller coordinating Google Calendar sign-in and event creation.
class GoogleCalendarController extends ChangeNotifier {
  GoogleCalendarController({
    required LocalDemoStore store,
    GoogleCalendarService? service,
  }) : _store = store,
       _service = service ?? GoogleCalendarService() {
    _store.addListener(_handleStoreChanged);
    _resetForm();
  }

  final LocalDemoStore _store;
  final GoogleCalendarService _service;

  GoogleCalendarConnectionState _connectionState =
      GoogleCalendarConnectionState.demoMode;
  GoogleCalendarSyncState _syncState = GoogleCalendarSyncState.idle;
  String _formTitle = '';
  late DateTime _formStartTime;
  late DateTime _formEndTime;
  String _syncMessage = '';
  String _connectionError = '';
  bool _isSyncing = false;

  GoogleCalendarState get state => GoogleCalendarState(
    connectionState: _connectionState,
    syncState: _syncState,
    isConnected: _connectionState == GoogleCalendarConnectionState.connected,
    isDemoMode: _connectionState == GoogleCalendarConnectionState.demoMode,
    configurationNeeded:
        _connectionState == GoogleCalendarConnectionState.configurationRequired,
    userEmail: _service.userEmail,
    connectionError: _connectionError,
    syncMessage: _syncMessage,
    activities: _store.activities,
    isSyncing: _isSyncing,
    formTitle: _formTitle,
    formStartTime: _formStartTime,
    formEndTime: _formEndTime,
  );

  Future<void> connectGoogle() async {
    _connectionState = GoogleCalendarConnectionState.connecting;
    _syncState = GoogleCalendarSyncState.idle;
    _syncMessage = '';
    _connectionError = '';
    notifyListeners();

    final GoogleCalendarSignInResult result = await _service.signIn();

    switch (result.status) {
      case GoogleCalendarSignInStatus.success:
        _connectionState = GoogleCalendarConnectionState.connected;
        _connectionError = '';
        _syncMessage = result.message;
      case GoogleCalendarSignInStatus.cancelled:
        _connectionState = GoogleCalendarConnectionState.demoMode;
        _connectionError = '';
        _syncMessage = result.message;
      case GoogleCalendarSignInStatus.configurationRequired:
        _connectionState = GoogleCalendarConnectionState.configurationRequired;
        _connectionError = result.message;
        _syncMessage =
            'Demo mode is active. Local activities can still be created.';
      case GoogleCalendarSignInStatus.failure:
        _connectionState = GoogleCalendarConnectionState.connectionFailed;
        _connectionError = result.message;
        _syncMessage =
            'Google Calendar is unavailable right now. Demo mode is still available.';
    }

    notifyListeners();
  }

  Future<void> disconnectGoogle() async {
    await _service.signOut();
    _connectionState = GoogleCalendarConnectionState.demoMode;
    _syncState = GoogleCalendarSyncState.idle;
    _connectionError = '';
    _syncMessage =
        'Disconnected from Google Calendar. Existing activities remain available locally.';
    notifyListeners();
  }

  void updateFormTitle(String value) {
    _formTitle = value;
    _clearNonBlockingMessage();
    notifyListeners();
  }

  void updateFormStartTime(DateTime value) {
    _formStartTime = value;
    _clearNonBlockingMessage();
    notifyListeners();
  }

  void updateFormEndTime(DateTime value) {
    _formEndTime = value;
    _clearNonBlockingMessage();
    notifyListeners();
  }

  void resetForm() {
    _resetForm();
    _clearNonBlockingMessage();
    notifyListeners();
  }

  Future<void> createActivity() async {
    if (_formTitle.trim().isEmpty) {
      _syncState = GoogleCalendarSyncState.syncFailed;
      _syncMessage = 'Activity title is required.';
      notifyListeners();
      return;
    }

    final String activityId =
        'activity-${DateTime.now().millisecondsSinceEpoch}';
    final GoogleCalendarActivity activity = GoogleCalendarActivity(
      id: activityId,
      title: _formTitle.trim(),
      startTime: _formStartTime,
      endTime: _formEndTime,
      googleCalendarEventId: '',
      syncStatus: 'pending',
      createdAt: DateTime.now(),
    );

    _store.addActivity(activity);

    if (_connectionState == GoogleCalendarConnectionState.connected) {
      _isSyncing = true;
      _syncState = GoogleCalendarSyncState.syncing;
      _syncMessage = '';
      _connectionError = '';
      notifyListeners();

      final GoogleCalendarCreateEventResult result = await _service.createEvent(
        title: activity.title,
        start: activity.startTime,
        end: activity.endTime,
      );

      _isSyncing = false;

      switch (result.status) {
        case GoogleCalendarCreateEventStatus.success:
          _store.updateActivity(
            activity.copyWith(
              googleCalendarEventId: result.eventId,
              syncStatus: 'synced',
            ),
          );
          _syncState = GoogleCalendarSyncState.syncSuccess;
          _syncMessage = result.message;
        case GoogleCalendarCreateEventStatus.notConnected:
          _store.updateActivity(activity.copyWith(syncStatus: 'local'));
          _connectionState = GoogleCalendarConnectionState.demoMode;
          _syncState = GoogleCalendarSyncState.syncFailed;
          _syncMessage =
              'Activity saved locally. Connect Google Calendar to sync.';
        case GoogleCalendarCreateEventStatus.configurationRequired:
          _store.updateActivity(activity.copyWith(syncStatus: 'local'));
          _connectionState =
              GoogleCalendarConnectionState.configurationRequired;
          _syncState = GoogleCalendarSyncState.syncFailed;
          _connectionError = result.message;
          _syncMessage =
              'Activity saved locally. Google Calendar setup is still required for sync.';
        case GoogleCalendarCreateEventStatus.failure:
          _store.updateActivity(activity.copyWith(syncStatus: 'error'));
          _connectionState = GoogleCalendarConnectionState.connectionFailed;
          _syncState = GoogleCalendarSyncState.syncFailed;
          _connectionError = result.message;
          _syncMessage = 'Activity saved locally. Google Calendar sync failed.';
      }
    } else {
      _store.updateActivity(activity.copyWith(syncStatus: 'local'));
      _syncState = GoogleCalendarSyncState.syncSuccess;
      _syncMessage =
          _connectionState ==
              GoogleCalendarConnectionState.configurationRequired
          ? 'Activity saved locally. Google Calendar setup is still required for sync.'
          : 'Activity saved locally. Connect Google Calendar to sync.';
    }

    _resetForm();
    notifyListeners();
  }

  @override
  void dispose() {
    _store.removeListener(_handleStoreChanged);
    super.dispose();
  }

  void _resetForm() {
    _formTitle = '';
    final DateTime now = DateTime.now();
    _formStartTime = DateTime(now.year, now.month, now.day, now.hour + 1);
    _formEndTime = DateTime(now.year, now.month, now.day, now.hour + 2);
  }

  void _clearNonBlockingMessage() {
    _syncMessage = '';
    if (_syncState != GoogleCalendarSyncState.syncing) {
      _syncState = GoogleCalendarSyncState.idle;
    }
  }

  void _handleStoreChanged() {
    notifyListeners();
  }
}
