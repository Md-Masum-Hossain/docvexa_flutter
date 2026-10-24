import 'package:flutter/material.dart';

import 'package:docvexa/features/doctors/data/doctor_models.dart';

import '../../../core/network/api_client.dart';
import '../../../core/theme/app_tokens.dart';
import '../../../shared/widgets/status_views.dart';
import '../data/appointment_models.dart';
import '../data/appointment_repository.dart';
import '../../payments/data/payment_repository.dart';
import '../../payments/presentation/payment_pages.dart';

final _appointmentRepository = AppointmentRepository(apiClient: ApiClient());

class BookingPage extends StatefulWidget {
  const BookingPage({super.key, required this.doctor, this.repository});

  final Doctor doctor;
  final AppointmentRepository? repository;

  @override
  State<BookingPage> createState() => _BookingPageState();
}

class _BookingPageState extends State<BookingPage> {
  final _reasonController = TextEditingController();
  final _notesController = TextEditingController();
  DateTime? _date;
  String? _slot;
  bool _isSubmitting = false;
  String? _error;

  AppointmentRepository get _repository =>
      widget.repository ?? _appointmentRepository;

  @override
  void dispose() {
    _reasonController.dispose();
    _notesController.dispose();
    super.dispose();
  }

  Future<void> _selectDate() async {
    final selected = await showDatePicker(
      context: context,
      firstDate: DateTime.now(),
      lastDate: DateTime.now().add(const Duration(days: 365)),
      initialDate: _date ?? DateTime.now(),
    );
    if (selected != null) setState(() => _date = selected);
  }

  Future<void> _submit() async {
    final reason = _reasonController.text.trim();
    if (_date == null || _slot == null || reason.length < 3) {
      setState(
        () => _error = 'Choose a date, time slot, and enter a reason of at least 3 characters.',
      );
      return;
    }
    setState(() {
      _isSubmitting = true;
      _error = null;
    });
    try {
      final appointment = await _repository.createAppointment(
        doctorId: widget.doctor.id,
        appointmentDate: _date!,
        timeSlot: _slot!,
        reason: reason,
        notes: _notesController.text.trim(),
      );
      if (!mounted) return;
      await Navigator.of(context).pushReplacement(
        MaterialPageRoute<void>(
          builder: (_) => AppointmentDetailsPage(appointmentId: appointment.id),
        ),
      );
    } catch (error) {
      if (mounted) setState(() => _error = error.toString());
    } finally {
      if (mounted) setState(() => _isSubmitting = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Book appointment')),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(AppTokens.spaceMd),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              widget.doctor.user.name.isEmpty
                  ? 'Doctor'
                  : widget.doctor.user.name,
              style: Theme.of(context).textTheme.headlineSmall,
            ),
            Text(widget.doctor.specialization),
            const SizedBox(height: AppTokens.spaceLg),
            OutlinedButton.icon(
              onPressed: _selectDate,
              icon: const Icon(Icons.event_outlined),
              label: Text(_date == null ? 'Choose date' : _formatDate(_date!)),
            ),
            const SizedBox(height: AppTokens.spaceMd),
            DropdownButtonFormField<String>(
              initialValue: _slot,
              decoration: const InputDecoration(labelText: 'Time slot'),
              items: widget.doctor.availableSlots
                  .map((slot) => '${slot.startTime} - ${slot.endTime}')
                  .map(
                    (slot) => DropdownMenuItem(value: slot, child: Text(slot)),
                  )
                  .toList(),
              onChanged: (value) => setState(() => _slot = value),
            ),
            if (widget.doctor.availableSlots.isEmpty)
              const Padding(
                padding: EdgeInsets.only(top: AppTokens.spaceSm),
                child: Text('This doctor has not provided time slots yet.'),
              ),
            const SizedBox(height: AppTokens.spaceMd),
            TextField(
              controller: _reasonController,
              maxLength: 500,
              maxLines: 3,
              decoration: const InputDecoration(
                labelText: 'Reason for visit',
                alignLabelWithHint: true,
              ),
            ),
            const SizedBox(height: AppTokens.spaceMd),
            TextField(
              controller: _notesController,
              maxLength: 1000,
              maxLines: 3,
              decoration: const InputDecoration(
                labelText: 'Notes (optional)',
                alignLabelWithHint: true,
              ),
            ),
            if (_error != null) ...[
              const SizedBox(height: AppTokens.spaceSm),
              Text(
                _error!,
                style: TextStyle(color: Theme.of(context).colorScheme.error),
              ),
            ],
            const SizedBox(height: AppTokens.spaceMd),
            SizedBox(
              width: double.infinity,
              child: ElevatedButton(
                onPressed: _isSubmitting ? null : _submit,
                child: _isSubmitting
                    ? const SizedBox(
                        width: 20,
                        height: 20,
                        child: CircularProgressIndicator(strokeWidth: 2),
                      )
                    : const Text('Request appointment'),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class AppointmentsPage extends StatefulWidget {
  const AppointmentsPage({super.key, this.repository});

  final AppointmentRepository? repository;

  @override
  State<AppointmentsPage> createState() => _AppointmentsPageState();
}

class _AppointmentsPageState extends State<AppointmentsPage> {
  late Future<AppointmentListResult> _future;
  int _page = 1;

  AppointmentRepository get _repository =>
      widget.repository ?? _appointmentRepository;

  @override
  void initState() {
    super.initState();
    _load();
  }

  void _load() {
    _future = _repository.getMyAppointments(page: _page);
  }

  void _retry() => setState(_load);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('My appointments')),
      body: FutureBuilder<AppointmentListResult>(
        future: _future,
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const AppLoadingView(label: 'Loading appointments');
          }
          if (snapshot.hasError) {
            return AppErrorView(
              message: snapshot.error.toString(),
              onRetry: _retry,
            );
          }
          final result = snapshot.data;
          if (result == null || result.items.isEmpty) {
            return const AppEmptyView(
              title: 'No appointments yet',
              message: 'Your appointment requests will appear here.',
              icon: Icons.calendar_month_outlined,
            );
          }
          return RefreshIndicator(
            onRefresh: () async => _retry(),
            child: ListView.separated(
              padding: const EdgeInsets.all(AppTokens.spaceMd),
              itemCount: result.items.length + 1,
              separatorBuilder: (_, _) =>
                  const SizedBox(height: AppTokens.spaceSm),
              itemBuilder: (context, index) {
                if (index == result.items.length) {
                  return _AppointmentPagination(
                    pagination: result.pagination,
                    onChanged: (page) => setState(() {
                      _page = page;
                      _load();
                    }),
                  );
                }
                final appointment = result.items[index];
                return _AppointmentTile(
                  appointment: appointment,
                  onTap: () => Navigator.of(context).push(
                    MaterialPageRoute<void>(
                      builder: (_) =>
                          AppointmentDetailsPage(appointmentId: appointment.id),
                    ),
                  ),
                );
              },
            ),
          );
        },
      ),
    );
  }
}

class AppointmentDetailsPage extends StatefulWidget {
  const AppointmentDetailsPage({
    super.key,
    required this.appointmentId,
    this.repository,
    this.paymentRepository,
  });

  final String appointmentId;
  final AppointmentRepository? repository;
  final PaymentRepository? paymentRepository;

  @override
  State<AppointmentDetailsPage> createState() => _AppointmentDetailsPageState();
}

class _AppointmentDetailsPageState extends State<AppointmentDetailsPage> {
  late Future<Appointment> _future;
  bool _isActionRunning = false;

  AppointmentRepository get _repository =>
      widget.repository ?? _appointmentRepository;

  @override
  void initState() {
    super.initState();
    _future = _repository.getAppointmentById(widget.appointmentId);
  }

  Future<void> _cancel(Appointment appointment) async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Cancel appointment?'),
        content: const Text(
          'This will ask the backend to cancel the appointment.',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: const Text('Keep'),
          ),
          FilledButton(
            onPressed: () => Navigator.pop(context, true),
            child: const Text('Cancel appointment'),
          ),
        ],
      ),
    );
    if (confirmed != true) return;
    setState(() => _isActionRunning = true);
    try {
      final updated = await _repository.cancelAppointment(appointment.id);
      if (mounted) setState(() => _future = Future.value(updated));
    } catch (error) {
      if (mounted) _showError(error.toString());
    } finally {
      if (mounted) setState(() => _isActionRunning = false);
    }
  }

  Future<void> _reschedule(Appointment appointment) async {
    final dateController = TextEditingController(
      text: _formatDate(appointment.appointmentDate),
    );
    final slotController = TextEditingController(text: appointment.timeSlot);
    final reasonController = TextEditingController(text: appointment.reason);
    final notesController = TextEditingController(text: appointment.notes);
    final formKey = GlobalKey<FormState>();

    final submitted = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Reschedule appointment'),
        content: SingleChildScrollView(
          child: Form(
            key: formKey,
            child: Column(
              children: [
                TextFormField(
                  controller: dateController,
                  decoration: const InputDecoration(
                    labelText: 'Date (YYYY-MM-DD)',
                  ),
                  validator: (value) => DateTime.tryParse(value ?? '') == null
                      ? 'Enter a valid date'
                      : null,
                ),
                TextFormField(
                  controller: slotController,
                  decoration: const InputDecoration(labelText: 'Time slot'),
                  validator: (value) => value == null || value.trim().isEmpty
                      ? 'Enter a time slot'
                      : null,
                ),
                TextFormField(
                  controller: reasonController,
                  decoration: const InputDecoration(labelText: 'Reason'),
                  validator: (value) => value == null || value.trim().length < 3
                      ? 'Enter at least 3 characters'
                      : null,
                ),
                TextFormField(
                  controller: notesController,
                  decoration: const InputDecoration(labelText: 'Notes'),
                  maxLines: 2,
                ),
              ],
            ),
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: const Text('Keep'),
          ),
          FilledButton(
            onPressed: () {
              if (formKey.currentState!.validate()) {
                Navigator.pop(context, true);
              }
            },
            child: const Text('Reschedule'),
          ),
        ],
      ),
    );

    final date = DateTime.tryParse(dateController.text);
    final timeSlot = slotController.text.trim();
    final reason = reasonController.text.trim();
    final notes = notesController.text.trim();
    dateController.dispose();
    slotController.dispose();
    reasonController.dispose();
    notesController.dispose();
    if (submitted != true || date == null) return;

    setState(() => _isActionRunning = true);
    try {
      final updated = await _repository.rescheduleAppointment(
        id: appointment.id,
        appointmentDate: date,
        timeSlot: timeSlot,
        reason: reason,
        notes: notes,
      );
      if (mounted) setState(() => _future = Future.value(updated));
    } catch (error) {
      if (mounted) _showError(error.toString());
    } finally {
      if (mounted) setState(() => _isActionRunning = false);
    }
  }

  void _showError(String message) =>
      ScaffoldMessenger.of(context)
          .showSnackBar(SnackBar(content: Text(message)));

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Appointment details')),
      body: FutureBuilder<Appointment>(
        future: _future,
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const AppLoadingView();
          }
          if (snapshot.hasError) {
            return AppErrorView(
              message: snapshot.error.toString(),
              onRetry: () => setState(
                () => _future = _repository.getAppointmentById(
                  widget.appointmentId,
                ),
              ),
            );
          }
          final appointment = snapshot.data;
          if (appointment == null) {
            return const AppEmptyView(
              title: 'Appointment unavailable',
              message: 'This appointment could not be found.',
            );
          }
          final canEdit = [
            'pending',
            'accepted',
            'rescheduled',
          ].contains(appointment.status);
          return SingleChildScrollView(
            padding: const EdgeInsets.all(AppTokens.spaceMd),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  _doctorName(appointment),
                  style: Theme.of(context).textTheme.headlineSmall,
                ),
                const SizedBox(height: AppTokens.spaceMd),
                _DetailLine(
                  label: 'Date',
                  value: _formatDate(appointment.appointmentDate),
                ),
                _DetailLine(label: 'Time', value: appointment.timeSlot),
                _DetailLine(
                  label: 'Appointment status',
                  value: appointment.status,
                ),
                _DetailLine(
                  label: 'Payment status',
                  value: appointment.paymentStatus,
                ),
                _DetailLine(label: 'Reason', value: appointment.reason),
                if (appointment.notes.isNotEmpty)
                  _DetailLine(label: 'Notes', value: appointment.notes),
                const SizedBox(height: AppTokens.spaceLg),
                if (_isActionRunning) const LinearProgressIndicator(),
                if (canEdit) ...[
                  Row(
                    children: [
                      Expanded(
                        child: OutlinedButton(
                          onPressed: _isActionRunning
                              ? null
                              : () => _reschedule(appointment),
                          child: const Text('Reschedule'),
                        ),
                      ),
                      const SizedBox(width: AppTokens.spaceSm),
                      Expanded(
                        child: OutlinedButton(
                          onPressed: _isActionRunning
                              ? null
                              : () => _cancel(appointment),
                          child: const Text('Cancel'),
                        ),
                      ),
                    ],
                  ),
                ],
                if (appointment.paymentStatus == 'unpaid' &&
                    appointment.status != 'cancelled') ...[
                  const SizedBox(height: AppTokens.spaceSm),
                  SizedBox(
                    width: double.infinity,
                    child: ElevatedButton.icon(
                      onPressed: _isActionRunning
                          ? null
                          : () => Navigator.of(context).push(
                              MaterialPageRoute<void>(
                                builder: (_) =>
                                    PaymentPage(appointment: appointment),
                              ),
                            ),
                      icon: const Icon(Icons.payments_outlined),
                      label: const Text('Continue to payment'),
                    ),
                  ),
                ],
              ],
            ),
          );
        },
      ),
    );
  }
}

class _AppointmentTile extends StatelessWidget {
  const _AppointmentTile({required this.appointment, required this.onTap});
  final Appointment appointment;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) => ListTile(
    contentPadding: const EdgeInsets.all(AppTokens.spaceMd),
    shape: RoundedRectangleBorder(
      side: const BorderSide(color: AppTokens.border),
      borderRadius: BorderRadius.circular(AppTokens.radiusMd),
    ),
    title: Text(
      _doctorName(appointment),
      style: const TextStyle(fontWeight: FontWeight.w700),
    ),
    subtitle: Text(
      '${_formatDate(appointment.appointmentDate)} · ${appointment.timeSlot}\n${appointment.status} · ${appointment.paymentStatus}',
    ),
    isThreeLine: true,
    trailing: const Icon(Icons.chevron_right_rounded),
    onTap: onTap,
  );
}

class _AppointmentPagination extends StatelessWidget {
  const _AppointmentPagination({
    required this.pagination,
    required this.onChanged,
  });
  final AppointmentPagination pagination;
  final ValueChanged<int> onChanged;
  @override
  Widget build(BuildContext context) => pagination.totalPages <= 1
      ? const SizedBox.shrink()
      : Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text('Page ${pagination.page} of ${pagination.totalPages}'),
            Row(
              children: [
                IconButton(
                  onPressed: pagination.page > 1
                      ? () => onChanged(pagination.page - 1)
                      : null,
                  icon: const Icon(Icons.chevron_left),
                ),
                IconButton(
                  onPressed: pagination.page < pagination.totalPages
                      ? () => onChanged(pagination.page + 1)
                      : null,
                  icon: const Icon(Icons.chevron_right),
                ),
              ],
            ),
          ],
        );
}

class _DetailLine extends StatelessWidget {
  const _DetailLine({required this.label, required this.value});
  final String label;
  final String value;
  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: AppTokens.spaceSm),
      child: Text.rich(
        TextSpan(
          children: [
            TextSpan(
              text: '$label: ',
              style: const TextStyle(fontWeight: FontWeight.w700),
            ),
            TextSpan(text: value),
          ],
        ),
      ),
    );
  }
}

String _doctorName(Appointment appointment) =>
    appointment.doctor.user.name.isEmpty
    ? 'Doctor'
    : appointment.doctor.user.name;
String _formatDate(DateTime? date) => date == null
    ? 'Not provided'
    : '${date.year}-${date.month.toString().padLeft(2, '0')}-${date.day.toString().padLeft(2, '0')}';
