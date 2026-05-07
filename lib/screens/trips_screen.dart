import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:intl/intl.dart';
import '../providers/trip_provider.dart';
import '../models/trip.dart';
import '../theme/app_theme.dart';

class TripsScreen extends StatefulWidget {
  const TripsScreen({super.key});

  @override
  State<TripsScreen> createState() => _TripsScreenState();
}

class _TripsScreenState extends State<TripsScreen> {
  final _nameCtrl = TextEditingController();
  final _destCtrl = TextEditingController();
  final _partCtrl = TextEditingController();
  final _formKey = GlobalKey<FormState>();
  DateTime? _startDate;
  DateTime? _endDate;
  final List<String> _participants = [];
  bool _formOpen = false;

  @override
  void dispose() {
    _nameCtrl.dispose();
    _destCtrl.dispose();
    _partCtrl.dispose();
    super.dispose();
  }

  Future<void> _pickDate(bool isStart) async {
    final picked = await showDatePicker(
      context: context,
      initialDate: DateTime.now(),
      firstDate: DateTime(2020),
      lastDate: DateTime(2030),
    );
    if (picked != null) {
      setState(() {
        if (isStart) {
          _startDate = picked;
        } else {
          _endDate = picked;
        }
      });
    }
  }

  void _addParticipant() {
    final v = _partCtrl.text.trim();
    if (v.isEmpty) {
      _showError('Enter a participant name');
      return;
    }
    if (v.length < 2) {
      _showError('Name must be at least 2 characters');
      return;
    }
    if (_participants.contains(v)) {
      _showError('"$v" is already added');
      return;
    }
    setState(() {
      _participants.add(v);
      _partCtrl.clear();
    });
  }

  void _showError(String msg) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Row(children: [
          const Icon(Icons.warning_amber_rounded, color: Colors.white, size: 18),
          const SizedBox(width: 8),
          Expanded(child: Text(msg, style: AppText.body(size: 13, color: Colors.white))),
        ]),
        backgroundColor: AppColors.danger,
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
        margin: const EdgeInsets.all(12),
      ),
    );
  }

  void _showSuccess(String msg) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Row(children: [
          const Icon(Icons.check_circle, color: Colors.white, size: 18),
          const SizedBox(width: 8),
          Expanded(child: Text(msg, style: AppText.body(size: 13, color: Colors.white))),
        ]),
        backgroundColor: AppColors.success,
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
        margin: const EdgeInsets.all(12),
      ),
    );
  }

  Future<void> _createTrip() async {
    if (!_formKey.currentState!.validate()) return;

    if (_startDate == null || _endDate == null) {
      _showError('Please select both start and end dates');
      return;
    }
    if (_endDate!.isBefore(_startDate!)) {
      _showError('End date must be after start date');
      return;
    }
    if (_participants.isEmpty) {
      _showError('Add at least one participant');
      return;
    }
    await context.read<TripProvider>().createTrip(
          name: _nameCtrl.text.trim(),
          destination: _destCtrl.text.trim(),
          startDate: _startDate!,
          endDate: _endDate!,
          participants: List.from(_participants),
        );
    setState(() {
      _nameCtrl.clear();
      _destCtrl.clear();
      _participants.clear();
      _startDate = null;
      _endDate = null;
      _formOpen = false;
    });
    if (mounted) _showSuccess('Trip created! 🎉');
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            AppText.appLogo(size: 28),
            const SizedBox(width: 10),
            const Text('My Trips'),
          ],
        ),
        actions: [
          IconButton(
            icon: AnimatedSwitcher(
              duration: const Duration(milliseconds: 200),
              child: Icon(_formOpen ? Icons.close : Icons.add_circle_outline,
                  key: ValueKey(_formOpen)),
            ),
            onPressed: () => setState(() => _formOpen = !_formOpen),
          ),
        ],
      ),
      body: Consumer<TripProvider>(
        builder: (context, provider, _) {
          provider.loadTrips();
          return Column(
            children: [
              if (_formOpen) _buildForm(),
              _buildSearchBar(provider),
              Expanded(child: _buildTripList(provider)),
            ],
          );
        },
      ),
    );
  }

  Widget _buildForm() {
    return Container(
      margin: const EdgeInsets.all(14),
      padding: const EdgeInsets.all(18),
      decoration: AppDecor.softCard,
      child: Form(
        key: _formKey,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('✏️ Plan a New Trip', style: AppText.cursive(size: 20)),
            const SizedBox(height: 14),
            Row(children: [
              Expanded(
                child: TextFormField(
                  controller: _nameCtrl,
                  decoration: AppDecor.inputDecoration('Trip Name',
                      icon: Icons.flight_takeoff),
                  validator: (v) {
                    if (v == null || v.trim().isEmpty) {
                      return 'Required';
                    }
                    if (v.trim().length < 3) {
                      return 'Min 3 chars';
                    }
                    return null;
                  },
                ),
              ),
              const SizedBox(width: 10),
              Expanded(
                child: TextFormField(
                  controller: _destCtrl,
                  decoration: AppDecor.inputDecoration('Destination',
                      icon: Icons.place),
                  validator: (v) {
                    if (v == null || v.trim().isEmpty) {
                      return 'Required';
                    }
                    return null;
                  },
                ),
              ),
            ]),
            const SizedBox(height: 12),
            Row(children: [
              Expanded(child: _dateTile('📅 Start Date', _startDate, () => _pickDate(true))),
              const SizedBox(width: 10),
              Expanded(child: _dateTile('📅 End Date', _endDate, () => _pickDate(false))),
            ]),
            const SizedBox(height: 12),
            Row(children: [
              Expanded(
                child: TextFormField(
                  controller: _partCtrl,
                  decoration: AppDecor.inputDecoration('Add Participant',
                      icon: Icons.person_add_alt_1),
                  onFieldSubmitted: (_) => _addParticipant(),
                ),
              ),
              const SizedBox(width: 8),
              ElevatedButton(
                onPressed: _addParticipant,
                style: AppDecor.mintButton,
                child: const Text('Add'),
              ),
            ]),
            if (_participants.isNotEmpty) ...[
              const SizedBox(height: 10),
              Wrap(
                spacing: 6,
                runSpacing: 4,
                children: _participants
                    .map((p) => Chip(
                          label: Text(p, style: AppText.body(size: 13)),
                          backgroundColor: AppColors.mintLight,
                          deleteIconColor: AppColors.coral,
                          onDeleted: () =>
                              setState(() => _participants.remove(p)),
                        ))
                    .toList(),
              ),
            ],
            const SizedBox(height: 14),
            SizedBox(
              width: double.infinity,
              child: ElevatedButton.icon(
                onPressed: _createTrip,
                icon: const Icon(Icons.add_circle),
                label: const Text('Create Trip'),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _dateTile(String label, DateTime? date, VoidCallback onTap) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 14),
        decoration: BoxDecoration(
          color: Colors.white,
          border: Border.all(
              color: date != null
                  ? AppColors.mint
                  : AppColors.peach.withOpacity(0.4)),
          borderRadius: BorderRadius.circular(12),
        ),
        child: Text(
          date == null ? label : DateFormat('dd MMM yyyy').format(date),
          style: AppText.body(
              size: 13,
              color: date == null ? AppColors.textMuted : AppColors.textDark),
        ),
      ),
    );
  }

  Widget _buildSearchBar(TripProvider provider) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 6),
      child: TextField(
        decoration: AppDecor.inputDecoration('Search trips...', icon: Icons.search),
        onChanged: provider.setSearch,
        style: AppText.body(size: 14),
      ),
    );
  }

  Widget _buildTripList(TripProvider provider) {
    final trips = provider.filteredTrips;
    if (trips.isEmpty) {
      return Center(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Icon(Icons.flight, size: 56, color: AppColors.peach),
            const SizedBox(height: 12),
            Text('No trips yet!', style: AppText.cursive(size: 22, color: AppColors.textMuted)),
            const SizedBox(height: 4),
            Text('Tap + to create your first adventure',
                style: AppText.body(size: 13, color: AppColors.textMuted)),
          ],
        ),
      );
    }
    return ListView.builder(
      padding: const EdgeInsets.all(14),
      itemCount: trips.length,
      itemBuilder: (context, i) => _buildTripCard(trips[i], provider),
    );
  }

  Widget _buildTripCard(Trip trip, TripProvider provider) {
    final isSelected = provider.selectedTrip?.id == trip.id;
    return Container(
      margin: const EdgeInsets.only(bottom: 10),
      decoration: BoxDecoration(
        color: isSelected ? AppColors.mintLight : AppColors.cardWhite,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: isSelected ? AppColors.mint : Colors.transparent,
          width: 2,
        ),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.04),
            blurRadius: 10,
            offset: const Offset(0, 3),
          ),
        ],
      ),
      child: ListTile(
        contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
        onTap: () {
          provider.selectTrip(trip);
          _showSuccess('Selected: ${trip.name} ✈️');
        },
        leading: CircleAvatar(
          backgroundColor:
              isSelected ? AppColors.mint : AppColors.coral.withOpacity(0.15),
          child: Icon(Icons.flight,
              color: isSelected ? Colors.white : AppColors.coral, size: 20),
        ),
        title: Row(children: [
          Expanded(
              child: Text(trip.name,
                  style: AppText.body(size: 15, weight: FontWeight.w600))),
          if (isSelected)
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
              decoration: BoxDecoration(
                  color: AppColors.success,
                  borderRadius: BorderRadius.circular(8)),
              child: Text('Active',
                  style: AppText.body(size: 11, color: Colors.white)),
            ),
        ]),
        subtitle: Padding(
          padding: const EdgeInsets.only(top: 4),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                  '📍 ${trip.destination}  •  📅 ${DateFormat('dd/MM').format(trip.startDate)} – ${DateFormat('dd/MM').format(trip.endDate)}',
                  style: AppText.label(size: 12)),
              Text('👥 ${trip.participants.join(', ')}',
                  style: AppText.label(size: 12)),
            ],
          ),
        ),
        trailing: IconButton(
          icon: const Icon(Icons.delete_outline, color: AppColors.danger),
          onPressed: () async {
            final confirm = await showDialog<bool>(
              context: context,
              builder: (_) => AlertDialog(
                shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(16)),
                title: Text('Delete Trip?', style: AppText.cursive(size: 20)),
                content: Text(
                    'This will delete all itinerary and expenses for "${trip.name}".',
                    style: AppText.body(size: 14)),
                actions: [
                  TextButton(
                      onPressed: () => Navigator.pop(context, false),
                      child: Text('Cancel', style: AppText.body(size: 14))),
                  ElevatedButton(
                      onPressed: () => Navigator.pop(context, true),
                      style: AppDecor.dangerButton,
                      child: const Text('Delete')),
                ],
              ),
            );
            if (confirm == true) {
              await provider.deleteTrip(trip.id);
            }
          },
        ),
      ),
    );
  }
}
