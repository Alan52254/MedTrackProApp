import 'package:flutter/material.dart';

import '../../core/services/local_demo_store.dart';
import '../../core/services/reminder_service.dart';
import '../../features/calendar/presentation/calendar_screen.dart';
import '../../features/google_calendar_sync/application/google_calendar_controller.dart';
import '../../features/google_calendar_sync/presentation/google_calendar_screen.dart';
import '../../features/home/application/home_controller.dart';
import '../../features/home/application/reminder_controller.dart';
import '../../features/home/presentation/home_screen.dart';
import '../../features/meds/application/meds_controller.dart';
import '../../features/meds/presentation/meds_screen.dart';
import '../../features/profile/application/profile_controller.dart';
import '../../features/profile/presentation/profile_screen.dart';

enum AppTab {
  home('Home', Icons.home_rounded, Icons.home_outlined),
  calendar(
    'Calendar',
    Icons.calendar_month_rounded,
    Icons.calendar_month_outlined,
  ),
  meds('Meds', Icons.medication_rounded, Icons.medication_outlined),
  profile('Profile', Icons.person_rounded, Icons.person_outline_rounded);

  const AppTab(this.label, this.selectedIcon, this.unselectedIcon);

  final String label;
  final IconData selectedIcon;
  final IconData unselectedIcon;
}

class AppShell extends StatefulWidget {
  const AppShell({super.key, this.reminderService});

  final ReminderService? reminderService;

  @override
  State<AppShell> createState() => _AppShellState();
}

class _AppShellState extends State<AppShell> {
  late final LocalDemoStore _localDemoStore;
  late final HomeController _homeController;
  late final MedsController _medsController;
  late final ProfileController _profileController;
  late final GoogleCalendarController _googleCalendarController;
  late final ReminderController _reminderController;
  int _selectedIndex = 0;

  late final List<Widget> _screens;

  @override
  void initState() {
    super.initState();
    _localDemoStore = LocalDemoStore();
    _homeController = HomeController(store: _localDemoStore);
    _medsController = MedsController(store: _localDemoStore);
    _profileController = ProfileController(store: _localDemoStore);
    _googleCalendarController = GoogleCalendarController(
      store: _localDemoStore,
    );
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _googleCalendarController.initialize();
    });
    _reminderController = ReminderController(
      store: _localDemoStore,
      reminderService: widget.reminderService,
    );
    _homeController.reminderController = _reminderController;

    _screens = <Widget>[
      HomeScreen(
        controller: _homeController,
        onDelayNavigateToCalendar: _navigateToCalendarDate,
      ),
      CalendarScreen(onGoogleCalendarTap: _openGoogleCalendar),
      MedsScreen(controller: _medsController),
      ProfileScreen(controller: _profileController),
    ];
  }

  @override
  void dispose() {
    _reminderController.dispose();
    _googleCalendarController.dispose();
    _homeController.dispose();
    _medsController.dispose();
    _profileController.dispose();
    _localDemoStore.dispose();
    super.dispose();
  }

  AppTab get _currentTab => AppTab.values[_selectedIndex];

  void _navigateToCalendarDate(DateTime date) {
    setState(() {
      _selectedIndex = AppTab.calendar.index;
    });
  }

  void _openGoogleCalendar() {
    Navigator.of(context).push<void>(
      MaterialPageRoute<void>(
        builder: (_) =>
            GoogleCalendarScreen(controller: _googleCalendarController),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(_currentTab.label),
        actions: const <Widget>[
          Padding(
            padding: EdgeInsets.only(right: 16),
            child: Center(
              child: Text(
                'Phase 2-lite',
                style: TextStyle(fontWeight: FontWeight.w600),
              ),
            ),
          ),
        ],
      ),
      body: IndexedStack(index: _selectedIndex, children: _screens),
      bottomNavigationBar: NavigationBar(
        selectedIndex: _selectedIndex,
        destinations: AppTab.values
            .map(
              (AppTab tab) => NavigationDestination(
                icon: Icon(tab.unselectedIcon),
                selectedIcon: Icon(tab.selectedIcon),
                label: tab.label,
              ),
            )
            .toList(growable: false),
        onDestinationSelected: (int index) {
          setState(() {
            _selectedIndex = index;
          });
        },
      ),
    );
  }
}
