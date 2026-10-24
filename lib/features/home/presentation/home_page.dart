import 'package:flutter/material.dart';

import '../../../core/config/app_config.dart';
import '../../../core/theme/app_theme.dart';

class HomePage extends StatefulWidget {
  const HomePage({super.key});

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  int _currentStep = 0;

  final List<Step> _bookingSteps = [
    const Step(
      title: Text('Select Doctor'),
      content: _StepContent(
        description:
            'Choose a qualified specialist and confirm your preferred doctor.',
        meta: 'Doctor profile, availability, and consultation type',
      ),
      isActive: true,
    ),
    const Step(
      title: Text('Select Date & Time'),
      content: _StepContent(
        description: 'Pick a time slot that works best for your consultation.',
        meta: 'Time slots, clinic, and visit type',
      ),
    ),
    const Step(
      title: Text('Review Appointment'),
      content: _StepContent(
        description: 'Double-check appointment details before proceeding.',
        meta: 'Review doctor, date, time, and visit notes',
      ),
    ),
    const Step(
      title: Text('Payment'),
      content: _StepContent(
        description: 'Complete the payment process to finalize your booking.',
        meta: 'Payment summary and confirmation status',
      ),
    ),
    const Step(
      title: Text('Confirmation'),
      content: _StepContent(
        description: 'Your appointment is booked and ready for confirmation.',
        meta: 'Confirmation details and support information',
      ),
    ),
  ];

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Scaffold(
      appBar: AppBar(
        title: const Text(AppConfig.appName),
        leading: Builder(
          builder: (context) => IconButton(
            icon: const Icon(Icons.menu_rounded),
            tooltip: 'Open menu',
            onPressed: () => Scaffold.of(context).openDrawer(),
          ),
        ),
        actions: [
          IconButton(
            icon: const Icon(Icons.notifications_none_rounded),
            tooltip: 'Notifications',
            onPressed: () {},
          ),
          IconButton(
            icon: const Icon(Icons.person_outline_rounded),
            tooltip: 'Profile',
            onPressed: () {},
          ),
        ],
      ),
      drawer: Drawer(
        child: ListView(
          padding: EdgeInsets.zero,
          children: [
            Container(
              height: 128,
              padding: const EdgeInsets.fromLTRB(20, 42, 20, 16),
              decoration: const BoxDecoration(color: AppTheme.primaryBlue),
              child: const Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisAlignment: MainAxisAlignment.end,
                children: [
                  Text(
                    AppConfig.appName,
                    style: TextStyle(
                      color: Colors.white,
                      fontSize: 26,
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                  SizedBox(height: 6),
                  Text(
                    AppConfig.appTagline,
                    style: TextStyle(color: Color(0xFFE0E7FF), fontSize: 13),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 8),
            const _DrawerItem(icon: Icons.home_rounded, title: 'Home'),
            const _DrawerItem(
              icon: Icons.medical_information_outlined,
              title: 'Doctors',
            ),
            const _DrawerItem(
              icon: Icons.smart_toy_outlined,
              title: 'AI Assistant',
            ),
            const _DrawerItem(icon: Icons.info_outline_rounded, title: 'About'),
            const _DrawerItem(
              icon: Icons.mail_outline_rounded,
              title: 'Contact',
            ),
          ],
        ),
      ),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(18),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              _HeroBanner(onBookAppointment: () {}),
              const SizedBox(height: 24),
              const Text(
                'Appointment flow',
                style: TextStyle(
                  fontSize: 28,
                  fontWeight: FontWeight.w700,
                  color: AppTheme.ink,
                ),
              ),
              const SizedBox(height: 8),
              Text(
                'Follow the booking journey to complete your consultation.',
                style: theme.textTheme.bodyLarge?.copyWith(
                  color: const Color(0xFF475569),
                ),
              ),
              const SizedBox(height: 20),
              Theme(
                data: theme.copyWith(
                  colorScheme: theme.colorScheme.copyWith(
                    primary: AppTheme.primaryBlue,
                    onPrimary: Colors.white,
                  ),
                  dividerColor: Colors.transparent,
                ),
                child: Stepper(
                  currentStep: _currentStep,
                  onStepTapped: (index) => setState(() => _currentStep = index),
                  controlsBuilder: (context, details) {
                    final isLastStep =
                        details.stepIndex == _bookingSteps.length - 1;
                    return Padding(
                      padding: const EdgeInsets.only(top: 16),
                      child: Row(
                        children: [
                          if (details.stepIndex > 0)
                            OutlinedButton(
                              onPressed: details.onStepCancel,
                              style: OutlinedButton.styleFrom(
                                foregroundColor: AppTheme.primaryBlue,
                                side: const BorderSide(
                                  color: Color(0xFFBFDBFE),
                                ),
                                shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(12),
                                ),
                              ),
                              child: const Text('Back'),
                            ),
                          const SizedBox(width: 12),
                          Expanded(
                            child: ElevatedButton(
                              onPressed: details.onStepContinue,
                              style: ElevatedButton.styleFrom(
                                backgroundColor: AppTheme.primaryBlue,
                                foregroundColor: Colors.white,
                                padding: const EdgeInsets.symmetric(
                                  vertical: 14,
                                ),
                                shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(12),
                                ),
                              ),
                              child: Text(isLastStep ? 'Finish' : 'Next'),
                            ),
                          ),
                        ],
                      ),
                    );
                  },
                  onStepContinue: () {
                    if (_currentStep < _bookingSteps.length - 1) {
                      setState(() => _currentStep++);
                    }
                  },
                  onStepCancel: () {
                    if (_currentStep > 0) {
                      setState(() => _currentStep--);
                    }
                  },
                  stepIconBuilder: (context, state) {
                    const grey = Color(0xFF94A3B8);
                    const white = Colors.white;

                    final iconData = switch (state) {
                      StepState.indexed => Icons.check_rounded,
                      StepState.editing => Icons.edit_rounded,
                      StepState.complete => Icons.check_circle_rounded,
                      StepState.disabled => Icons.circle_outlined,
                      StepState.error => Icons.error_rounded,
                    };

                    final color = switch (state) {
                      StepState.indexed => AppTheme.primaryBlue,
                      StepState.editing => AppTheme.primaryBlue,
                      StepState.complete => AppTheme.primaryBlue,
                      StepState.disabled => grey,
                      StepState.error => Colors.red,
                    };

                    return Container(
                      width: 28,
                      height: 28,
                      decoration: BoxDecoration(
                        color: state == StepState.disabled
                            ? Colors.white
                            : color,
                        border: Border.all(
                          color: state == StepState.disabled ? grey : color,
                          width: 1.5,
                        ),
                        shape: BoxShape.circle,
                      ),
                      child: Icon(
                        iconData,
                        size: 16,
                        color: state == StepState.disabled ? grey : white,
                      ),
                    );
                  },
                  steps: _bookingSteps,
                  type: StepperType.vertical,
                  physics: const BouncingScrollPhysics(),
                  margin: EdgeInsets.zero,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _HeroBanner extends StatelessWidget {
  const _HeroBanner({required this.onBookAppointment});

  final VoidCallback onBookAppointment;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        gradient: const LinearGradient(
          colors: [AppTheme.primaryBlue, Color(0xFF2563EB)],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(22),
        boxShadow: [
          BoxShadow(
            color: AppTheme.primaryBlue.withValues(alpha: 0.18),
            blurRadius: 16,
            offset: const Offset(0, 8),
          ),
        ],
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text(
                  'Your care, simplified',
                  style: TextStyle(
                    fontSize: 26,
                    fontWeight: FontWeight.w800,
                    color: Colors.white,
                  ),
                ),
                const SizedBox(height: 8),
                Text(
                  'Book trusted doctors, manage appointments, and stay on top of your health in one place.',
                  style: TextStyle(
                    fontSize: 14,
                    color: Colors.white.withValues(alpha: 0.9),
                    height: 1.5,
                  ),
                ),
                const SizedBox(height: 16),
                ElevatedButton(
                  onPressed: onBookAppointment,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.white,
                    foregroundColor: AppTheme.primaryBlue,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                    padding: const EdgeInsets.symmetric(
                      horizontal: 16,
                      vertical: 12,
                    ),
                  ),
                  child: const Text('Book Appointment'),
                ),
              ],
            ),
          ),
          const SizedBox(width: 12),
          Container(
            width: 72,
            height: 72,
            decoration: BoxDecoration(
              color: Colors.white.withValues(alpha: 0.18),
              shape: BoxShape.circle,
            ),
            child: const Icon(
              Icons.medical_services_outlined,
              color: Colors.white,
              size: 34,
            ),
          ),
        ],
      ),
    );
  }
}

class _StepContent extends StatelessWidget {
  const _StepContent({required this.description, required this.meta});

  final String description;
  final String meta;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(12),
      margin: const EdgeInsets.only(top: 8),
      decoration: BoxDecoration(
        color: const Color(0xFFF1F5F9),
        borderRadius: BorderRadius.circular(14),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            description,
            style: const TextStyle(
              fontSize: 14,
              fontWeight: FontWeight.w600,
              color: AppTheme.ink,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            meta,
            style: const TextStyle(fontSize: 12, color: Color(0xFF64748B)),
          ),
        ],
      ),
    );
  }
}

class _DrawerItem extends StatelessWidget {
  const _DrawerItem({required this.icon, required this.title});

  final IconData icon;
  final String title;

  @override
  Widget build(BuildContext context) {
    return ListTile(
      leading: Icon(icon, color: AppTheme.primaryBlue),
      title: Text(
        title,
        style: const TextStyle(
          fontSize: 16,
          fontWeight: FontWeight.w600,
          color: Color(0xFF1E293B),
        ),
      ),
      contentPadding: const EdgeInsets.symmetric(horizontal: 20, vertical: 2),
      onTap: () => Navigator.pop(context),
    );
  }
}
