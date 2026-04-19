import 'package:google_sign_in/google_sign_in.dart';
import 'package:googleapis/calendar/v3.dart' as gcal;
import 'package:http/http.dart' as http;

/// Authenticated HTTP client that injects the Google Sign-In access token.
class _GoogleAuthClient extends http.BaseClient {
  _GoogleAuthClient(this._headers);

  final Map<String, String> _headers;
  final http.Client _inner = http.Client();

  @override
  Future<http.StreamedResponse> send(http.BaseRequest request) {
    request.headers.addAll(_headers);
    return _inner.send(request);
  }
}

enum GoogleCalendarSignInStatus {
  success,
  cancelled,
  configurationRequired,
  failure,
}

class GoogleCalendarSignInResult {
  const GoogleCalendarSignInResult({
    required this.status,
    required this.message,
    this.userEmail = '',
  });

  final GoogleCalendarSignInStatus status;
  final String message;
  final String userEmail;
}

enum GoogleCalendarCreateEventStatus {
  success,
  notConnected,
  configurationRequired,
  failure,
}

class GoogleCalendarCreateEventResult {
  const GoogleCalendarCreateEventResult({
    required this.status,
    required this.message,
    this.eventId = '',
  });

  final GoogleCalendarCreateEventStatus status;
  final String message;
  final String eventId;
}

/// Write-only Google Calendar integration service.
///
/// Handles OAuth sign-in via `google_sign_in` and event creation via
/// the Google Calendar v3 REST API. No sync-back, no recurrence,
/// no multi-account.
class GoogleCalendarService {
  GoogleCalendarService();

  static const List<String> _scopes = <String>[
    gcal.CalendarApi.calendarEventsScope,
  ];

  final GoogleSignIn _googleSignIn = GoogleSignIn(scopes: _scopes);

  GoogleSignInAccount? _currentUser;

  bool get isSignedIn => _currentUser != null;
  String get userEmail => _currentUser?.email ?? '';

  /// Trigger the Google OAuth sign-in flow.
  Future<GoogleCalendarSignInResult> signIn() async {
    try {
      final GoogleSignInAccount? account = await _googleSignIn.signIn();

      if (account == null) {
        return const GoogleCalendarSignInResult(
          status: GoogleCalendarSignInStatus.cancelled,
          message:
              'Google sign-in was cancelled. Demo mode is still available.',
        );
      }

      _currentUser = account;
      return GoogleCalendarSignInResult(
        status: GoogleCalendarSignInStatus.success,
        message: 'Connected to Google Calendar.',
        userEmail: account.email,
      );
    } catch (e) {
      _currentUser = null;
      final String message = e.toString();

      if (_looksLikeConfigurationIssue(message)) {
        return const GoogleCalendarSignInResult(
          status: GoogleCalendarSignInStatus.configurationRequired,
          message:
              'Google Calendar setup required. OAuth credentials are missing or invalid for this build.',
        );
      }

      return GoogleCalendarSignInResult(
        status: GoogleCalendarSignInStatus.failure,
        message:
            'Google Calendar connection failed. You can continue in demo mode. Details: $message',
      );
    }
  }

  /// Sign out and clear the cached user.
  Future<void> signOut() async {
    try {
      await _googleSignIn.signOut();
    } catch (_) {
      // Best-effort sign-out.
    }
    _currentUser = null;
  }

  /// Create a calendar event on the user's primary Google Calendar.
  Future<GoogleCalendarCreateEventResult> createEvent({
    required String title,
    required DateTime start,
    required DateTime end,
  }) async {
    if (_currentUser == null) {
      return const GoogleCalendarCreateEventResult(
        status: GoogleCalendarCreateEventStatus.notConnected,
        message: 'Not connected to Google Calendar.',
      );
    }

    try {
      final GoogleSignInAuthentication auth =
          await _currentUser!.authentication;
      final String? accessToken = auth.accessToken;

      if (accessToken == null) {
        return const GoogleCalendarCreateEventResult(
          status: GoogleCalendarCreateEventStatus.configurationRequired,
          message:
              'Google Calendar setup required. Access token could not be retrieved.',
        );
      }

      final _GoogleAuthClient httpClient = _GoogleAuthClient(<String, String>{
        'Authorization': 'Bearer $accessToken',
      });

      final gcal.CalendarApi calendarApi = gcal.CalendarApi(httpClient);
      final gcal.Event event = gcal.Event(
        summary: title,
        start: gcal.EventDateTime(dateTime: start.toLocal()),
        end: gcal.EventDateTime(dateTime: end.toLocal()),
      );

      final gcal.Event createdEvent = await calendarApi.events.insert(
        event,
        'primary',
      );

      return GoogleCalendarCreateEventResult(
        status: GoogleCalendarCreateEventStatus.success,
        message: 'Activity created and synced to Google Calendar.',
        eventId: createdEvent.id ?? '',
      );
    } catch (e) {
      final String message = e.toString();

      if (_looksLikeConfigurationIssue(message)) {
        return const GoogleCalendarCreateEventResult(
          status: GoogleCalendarCreateEventStatus.configurationRequired,
          message:
              'Google Calendar setup required. This build cannot write events yet.',
        );
      }

      return GoogleCalendarCreateEventResult(
        status: GoogleCalendarCreateEventStatus.failure,
        message: 'Failed to write to Google Calendar: $message',
      );
    }
  }

  bool _looksLikeConfigurationIssue(String rawMessage) {
    final String normalized = rawMessage.toLowerCase();
    const List<String> indicators = <String>[
      'developer_error',
      'api exception: 10',
      'apiexception: 10',
      '12500',
      'oauth',
      'client id',
      'client_id',
      'sign_in_failed',
      'configuration',
      'not configured',
      'google-services',
      'certificate',
      'sha1',
    ];
    return indicators.any(normalized.contains);
  }
}
