import 'package:flutter/material.dart';

import '../../features/doctors/presentation/doctor_pages.dart';
import '../../features/appointments/presentation/appointment_pages.dart';
import '../../features/home/presentation/home_page.dart';
import '../../features/payments/presentation/payment_pages.dart';
import '../../shared/widgets/design_placeholder_page.dart';
import 'user_role.dart';

class AppShell extends StatefulWidget {
  const AppShell({super.key, required this.role});

  final UserRole role;

  @override
  State<AppShell> createState() => _AppShellState();
}

class _AppShellState extends State<AppShell> {
  int _selectedIndex = 0;

  List<_ShellDestination> get _destinations {
    return switch (widget.role) {
      UserRole.patient => const [
        _ShellDestination('Home', Icons.home_outlined, HomePage()),
        _ShellDestination(
          'Doctors',
          Icons.medical_information_outlined,
          DoctorsPage(),
        ),
        _ShellDestination(
          'Appointments',
          Icons.calendar_month_outlined,
          AppointmentsPage(),
        ),
        _ShellDestination('Payments', Icons.payments_outlined, PaymentsPage()),
        _ShellDestination(
          'Messages',
          Icons.chat_bubble_outline_rounded,
          DesignPlaceholderPage(
            title: 'Messages',
            message: 'Secure care-team messaging will be available here.',
            icon: Icons.chat_bubble_outline_rounded,
          ),
        ),
      ],
      UserRole.doctor => const [
        _ShellDestination(
          'Dashboard',
          Icons.dashboard_outlined,
          DesignPlaceholderPage(
            title: 'Doctor dashboard',
            message: 'Your schedule and patient queue will appear here.',
            icon: Icons.dashboard_outlined,
          ),
        ),
        _ShellDestination(
          'Schedule',
          Icons.calendar_month_outlined,
          DesignPlaceholderPage(
            title: 'Schedule',
            message:
                'Availability management will be connected in a later phase.',
            icon: Icons.calendar_month_outlined,
          ),
        ),
      ],
      UserRole.admin => const [
        _ShellDestination(
          'Overview',
          Icons.analytics_outlined,
          DesignPlaceholderPage(
            title: 'Admin overview',
            message: 'Platform metrics will appear here after authorization is connected.',
            icon: Icons.analytics_outlined,
          ),
        ),
        _ShellDestination(
          'Users',
          Icons.people_outline_rounded,
          DesignPlaceholderPage(
            title: 'User management',
            message: 'User administration will be connected in a later phase.',
            icon: Icons.people_outline_rounded,
          ),
        ),
      ],
    };
  }

  @override
  Widget build(BuildContext context) {
    final destinations = _destinations;

    return Scaffold(
      body: IndexedStack(
        index: _selectedIndex,
        children: [for (final destination in destinations) destination.page],
      ),
      bottomNavigationBar: NavigationBar(
        selectedIndex: _selectedIndex,
        onDestinationSelected: (index) {
          setState(() => _selectedIndex = index);
        },
        destinations: [
          for (final destination in destinations)
            NavigationDestination(
              icon: Icon(destination.icon),
              selectedIcon: Icon(destination.icon),
              label: destination.label,
            ),
        ],
      ),
    );
  }
}

class _ShellDestination {
  const _ShellDestination(this.label, this.icon, this.page);

  final String label;
  final IconData icon;
  final Widget page;
}
