import 'package:flutter/material.dart';

import '../../../core/network/api_client.dart';
import '../../../core/theme/app_tokens.dart';
import '../../../core/theme/app_theme.dart';
import '../../../shared/widgets/status_views.dart';
import '../../appointments/presentation/appointment_pages.dart';
import '../data/doctor_models.dart';
import '../data/doctor_repository.dart';

final _doctorRepository = DoctorRepository(apiClient: ApiClient());

class DoctorsPage extends StatefulWidget {
  const DoctorsPage({super.key, this.repository});

  final DoctorRepository? repository;

  @override
  State<DoctorsPage> createState() => _DoctorsPageState();
}

class _DoctorsPageState extends State<DoctorsPage> {
  final _searchController = TextEditingController();
  String? _specialization;
  String? _location;
  String _sortBy = 'createdAt';
  String _sortOrder = 'desc';
  int _page = 1;
  bool _isLoading = true;
  String? _error;
  DoctorListResult? _result;

  DoctorRepository get _repository => widget.repository ?? _doctorRepository;

  @override
  void initState() {
    super.initState();
    _loadDoctors();
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  Future<void> _loadDoctors() async {
    setState(() {
      _isLoading = true;
      _error = null;
    });

    try {
      final result = await _repository.getDoctors(
        specialization: _emptyToNull(_specialization),
        location: _emptyToNull(_location),
        page: _page,
        sortBy: _sortBy,
        sortOrder: _sortOrder,
      );
      if (!mounted) return;
      setState(() {
        _result = result;
        _isLoading = false;
      });
    } catch (error) {
      if (!mounted) return;
      setState(() {
        _error = error.toString();
        _isLoading = false;
      });
    }
  }

  void _applySearch() {
    setState(() {
      _specialization = _searchController.text.trim();
      _page = 1;
    });
    _loadDoctors();
  }

  void _changePage(int page) {
    setState(() => _page = page);
    _loadDoctors();
  }

  @override
  Widget build(BuildContext context) {
    final result = _result;

    return Scaffold(
      appBar: AppBar(title: const Text('Find a doctor')),
      body: SafeArea(
        child: RefreshIndicator(
          onRefresh: _loadDoctors,
          child: ListView(
            padding: const EdgeInsets.all(AppTokens.spaceMd),
            children: [
              Text(
                'Care that fits your needs',
                style: Theme.of(context).textTheme.headlineSmall
                    ?.copyWith(fontWeight: FontWeight.w700),
              ),
              const SizedBox(height: AppTokens.spaceSm),
              Text(
                'Search verified doctor profiles by specialty or location.',
                style: Theme.of(context).textTheme.bodyMedium
                    ?.copyWith(color: AppTokens.mutedInk),
              ),
              const SizedBox(height: AppTokens.spaceLg),
              _SearchBar(
                controller: _searchController,
                onSubmitted: (_) => _applySearch(),
                onSearch: _applySearch,
              ),
              const SizedBox(height: AppTokens.spaceMd),
              _FilterRow(
                location: _location,
                sortBy: _sortBy,
                sortOrder: _sortOrder,
                onLocationChanged: (value) {
                  setState(() {
                    _location = value;
                    _page = 1;
                  });
                  _loadDoctors();
                },
                onSortChanged: (value) {
                  setState(() {
                    _sortBy = value;
                    _page = 1;
                  });
                  _loadDoctors();
                },
                onOrderChanged: (value) {
                  setState(() {
                    _sortOrder = value;
                    _page = 1;
                  });
                  _loadDoctors();
                },
              ),
              const SizedBox(height: AppTokens.spaceLg),
              if (_isLoading && result == null)
                const SizedBox(
                  height: 300,
                  child: AppLoadingView(label: 'Loading doctors'),
                )
              else if (_error != null && result == null)
                SizedBox(
                  height: 300,
                  child: AppErrorView(message: _error!, onRetry: _loadDoctors),
                )
              else if (result == null || result.items.isEmpty)
                const SizedBox(
                  height: 300,
                  child: AppEmptyView(
                    title: 'No doctors found',
                    message: 'Try a different specialty or location.',
                    icon: Icons.medical_information_outlined,
                  ),
                )
              else ...[
                if (_isLoading) const LinearProgressIndicator(),
                for (final doctor in result.items) ...[
                  DoctorListTile(
                    doctor: doctor,
                    onTap: () => Navigator.of(context).push(
                      MaterialPageRoute<void>(
                        builder: (_) => DoctorDetailsPage(
                          doctorId: doctor.id,
                          repository: _repository,
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(height: AppTokens.spaceSm),
                ],
                _Pagination(
                  pagination: result.pagination,
                  onPageChanged: _changePage,
                ),
              ],
            ],
          ),
        ),
      ),
    );
  }
}

class DoctorDetailsPage extends StatefulWidget {
  const DoctorDetailsPage({
    super.key,
    required this.doctorId,
    required this.repository,
  });

  final String doctorId;
  final DoctorRepository repository;

  @override
  State<DoctorDetailsPage> createState() => _DoctorDetailsPageState();
}

class _DoctorDetailsPageState extends State<DoctorDetailsPage> {
  bool _isLoading = true;
  String? _error;
  Doctor? _doctor;

  @override
  void initState() {
    super.initState();
    _loadDoctor();
  }

  Future<void> _loadDoctor() async {
    setState(() {
      _isLoading = true;
      _error = null;
    });
    try {
      final doctor = await widget.repository.getDoctorById(widget.doctorId);
      if (!mounted) return;
      setState(() {
        _doctor = doctor;
        _isLoading = false;
      });
    } catch (error) {
      if (!mounted) return;
      setState(() {
        _error = error.toString();
        _isLoading = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    final doctor = _doctor;
    return Scaffold(
      appBar: AppBar(title: const Text('Doctor profile')),
      body: SafeArea(
        child: _isLoading
            ? const AppLoadingView(label: 'Loading profile')
            : _error != null
            ? AppErrorView(message: _error!, onRetry: _loadDoctor)
            : doctor == null
            ? const AppEmptyView(
                title: 'Profile unavailable',
                message: 'This doctor profile could not be found.',
                icon: Icons.person_search_outlined,
              )
            : _DoctorDetails(doctor: doctor),
      ),
    );
  }
}

class _DoctorDetails extends StatelessWidget {
  const _DoctorDetails({required this.doctor});

  final Doctor doctor;

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(AppTokens.spaceMd),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _DoctorHeader(doctor: doctor),
          const SizedBox(height: AppTokens.spaceLg),
          _InfoSection(
            title: 'Professional details',
            children: [
              _InfoLine(label: 'Specialization', value: doctor.specialization),
              _InfoLine(
                label: 'Qualifications',
                value: _joinOrFallback(doctor.qualifications),
              ),
              _InfoLine(
                label: 'Experience',
                value: '${doctor.experienceYears} years',
              ),
              _InfoLine(
                label: 'Consultation fee',
                value: 'BDT ${doctor.consultationFee}',
              ),
            ],
          ),
          if (doctor.bio.isNotEmpty) ...[
            const SizedBox(height: AppTokens.spaceLg),
            _InfoSection(title: 'About', children: [Text(doctor.bio)]),
          ],
          const SizedBox(height: AppTokens.spaceLg),
          _InfoSection(
            title: 'Practice',
            children: [
              _InfoLine(
                label: 'Hospital',
                value: _fallback(doctor.hospitalName),
              ),
              _InfoLine(
                label: 'Chamber',
                value: _fallback(doctor.chamberAddress),
              ),
            ],
          ),
          const SizedBox(height: AppTokens.spaceLg),
          _InfoSection(
            title: 'Availability',
            children: [
              _InfoLine(
                label: 'Days',
                value: _joinOrFallback(doctor.availableDays),
              ),
              _InfoLine(
                label: 'Slots',
                value: doctor.availableSlots.isEmpty
                    ? 'Not provided'
                    : doctor.availableSlots
                          .map((slot) => '${slot.startTime} - ${slot.endTime}')
                          .join(', '),
              ),
            ],
          ),
          const SizedBox(height: AppTokens.spaceLg),
          SizedBox(
            width: double.infinity,
            child: ElevatedButton.icon(
              onPressed: () {
                Navigator.of(context).push(
                  MaterialPageRoute<void>(
                    builder: (_) => BookingPage(doctor: doctor),
                  ),
                );
              },
              icon: const Icon(Icons.calendar_month_outlined),
              label: const Text('Book appointment'),
            ),
          ),
        ],
      ),
    );
  }
}

class DoctorListTile extends StatelessWidget {
  const DoctorListTile({super.key, required this.doctor, required this.onTap});

  final Doctor doctor;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return ListTile(
      contentPadding: const EdgeInsets.all(AppTokens.spaceSm),
      tileColor: AppTokens.surface,
      shape: RoundedRectangleBorder(
        side: const BorderSide(color: AppTokens.border),
        borderRadius: BorderRadius.circular(AppTokens.radiusMd),
      ),
      leading: _DoctorAvatar(url: doctor.photoUrl, size: 56),
      title: Text(
        doctor.user.name.isEmpty ? 'Doctor' : doctor.user.name,
        maxLines: 1,
        overflow: TextOverflow.ellipsis,
        style: const TextStyle(fontWeight: FontWeight.w700),
      ),
      subtitle: Padding(
        padding: const EdgeInsets.only(top: 4),
        child: Text(
          '${_fallback(doctor.specialization)}\n${_fallback(doctor.hospitalName)}',
          maxLines: 2,
          overflow: TextOverflow.ellipsis,
        ),
      ),
      trailing: const Icon(Icons.chevron_right_rounded),
      onTap: onTap,
    );
  }
}

class _DoctorHeader extends StatelessWidget {
  const _DoctorHeader({required this.doctor});

  final Doctor doctor;

  @override
  Widget build(BuildContext context) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _DoctorAvatar(url: doctor.photoUrl, size: 88),
        const SizedBox(width: AppTokens.spaceMd),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                doctor.user.name.isEmpty ? 'Doctor' : doctor.user.name,
                style: Theme.of(context).textTheme.headlineSmall
                    ?.copyWith(fontWeight: FontWeight.w700),
              ),
              const SizedBox(height: AppTokens.spaceXs),
              Text(
                _fallback(doctor.specialization),
                style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                  color: AppTheme.primaryBlue,
                  fontWeight: FontWeight.w600,
                ),
              ),
              const SizedBox(height: AppTokens.spaceSm),
              Row(
                children: [
                  const Icon(
                    Icons.star_rounded,
                    color: Color(0xFFD97706),
                    size: 18,
                  ),
                  const SizedBox(width: 4),
                  Text(
                    '${doctor.ratingAverage.toStringAsFixed(1)} (${doctor.ratingCount.toInt()})',
                  ),
                  if (doctor.isVerified) ...[
                    const SizedBox(width: AppTokens.spaceSm),
                    const Icon(
                      Icons.verified_outlined,
                      color: AppTheme.accentTeal,
                      size: 18,
                    ),
                  ],
                ],
              ),
            ],
          ),
        ),
      ],
    );
  }
}

class _DoctorAvatar extends StatelessWidget {
  const _DoctorAvatar({required this.url, required this.size});

  final String url;
  final double size;

  @override
  Widget build(BuildContext context) {
    if (url.isEmpty) {
      return CircleAvatar(
        radius: size / 2,
        backgroundColor: AppTheme.primaryBlue.withValues(alpha: 0.1),
        child: Icon(
          Icons.person_outline_rounded,
          size: size / 2,
          color: AppTheme.primaryBlue,
        ),
      );
    }
    return CircleAvatar(
      radius: size / 2,
      backgroundColor: AppTokens.border,
      backgroundImage: NetworkImage(url),
      onBackgroundImageError: (_, _) {},
    );
  }
}

class _SearchBar extends StatelessWidget {
  const _SearchBar({
    required this.controller,
    required this.onSubmitted,
    required this.onSearch,
  });

  final TextEditingController controller;
  final ValueChanged<String> onSubmitted;
  final VoidCallback onSearch;

  @override
  Widget build(BuildContext context) {
    return TextField(
      controller: controller,
      textInputAction: TextInputAction.search,
      onSubmitted: onSubmitted,
      decoration: InputDecoration(
        hintText: 'Search by specialty',
        prefixIcon: const Icon(Icons.search_rounded),
        suffixIcon: IconButton(
          onPressed: onSearch,
          tooltip: 'Search doctors',
          icon: const Icon(Icons.arrow_forward_rounded),
        ),
      ),
    );
  }
}

class _FilterRow extends StatelessWidget {
  const _FilterRow({
    required this.location,
    required this.sortBy,
    required this.sortOrder,
    required this.onLocationChanged,
    required this.onSortChanged,
    required this.onOrderChanged,
  });

  final String? location;
  final String sortBy;
  final String sortOrder;
  final ValueChanged<String?> onLocationChanged;
  final ValueChanged<String> onSortChanged;
  final ValueChanged<String> onOrderChanged;

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        TextFormField(
          initialValue: location,
          decoration: const InputDecoration(
            labelText: 'Location',
            prefixIcon: Icon(Icons.location_on_outlined),
          ),
          onFieldSubmitted: onLocationChanged,
        ),
        const SizedBox(height: AppTokens.spaceSm),
        Row(
          children: [
            Expanded(
              child: DropdownButtonFormField<String>(
                initialValue: sortBy,
                decoration: const InputDecoration(labelText: 'Sort by'),
                items: const [
                  DropdownMenuItem(value: 'createdAt', child: Text('Newest')),
                  DropdownMenuItem(
                    value: 'ratingAverage',
                    child: Text('Rating'),
                  ),
                  DropdownMenuItem(
                    value: 'experienceYears',
                    child: Text('Experience'),
                  ),
                  DropdownMenuItem(
                    value: 'consultationFee',
                    child: Text('Fee'),
                  ),
                ],
                onChanged: (value) {
                  if (value != null) onSortChanged(value);
                },
              ),
            ),
            const SizedBox(width: AppTokens.spaceSm),
            Expanded(
              child: DropdownButtonFormField<String>(
                initialValue: sortOrder,
                decoration: const InputDecoration(labelText: 'Order'),
                items: const [
                  DropdownMenuItem(value: 'desc', child: Text('Descending')),
                  DropdownMenuItem(value: 'asc', child: Text('Ascending')),
                ],
                onChanged: (value) {
                  if (value != null) onOrderChanged(value);
                },
              ),
            ),
          ],
        ),
      ],
    );
  }
}

class _Pagination extends StatelessWidget {
  const _Pagination({required this.pagination, required this.onPageChanged});

  final DoctorPagination pagination;
  final ValueChanged<int> onPageChanged;

  @override
  Widget build(BuildContext context) {
    if (pagination.totalPages <= 1) return const SizedBox.shrink();
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text('Page ${pagination.page} of ${pagination.totalPages}'),
        Row(
          children: [
            IconButton(
              onPressed: pagination.page > 1
                  ? () => onPageChanged(pagination.page - 1)
                  : null,
              tooltip: 'Previous page',
              icon: const Icon(Icons.chevron_left_rounded),
            ),
            IconButton(
              onPressed: pagination.page < pagination.totalPages
                  ? () => onPageChanged(pagination.page + 1)
                  : null,
              tooltip: 'Next page',
              icon: const Icon(Icons.chevron_right_rounded),
            ),
          ],
        ),
      ],
    );
  }
}

class _InfoSection extends StatelessWidget {
  const _InfoSection({required this.title, required this.children});

  final String title;
  final List<Widget> children;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(title, style: Theme.of(context).textTheme.titleLarge),
        const SizedBox(height: AppTokens.spaceSm),
        ...children,
      ],
    );
  }
}

class _InfoLine extends StatelessWidget {
  const _InfoLine({required this.label, required this.value});

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

String _fallback(String value) => value.isEmpty ? 'Not provided' : value;

String _joinOrFallback(List<String> values) {
  return values.isEmpty ? 'Not provided' : values.join(', ');
}

String? _emptyToNull(String? value) {
  return value == null || value.trim().isEmpty ? null : value.trim();
}
