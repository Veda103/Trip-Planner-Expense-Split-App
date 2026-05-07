import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:intl/intl.dart';
import '../providers/trip_provider.dart';
import '../providers/itinerary_provider.dart';
import '../models/itinerary_item.dart';
import '../theme/app_theme.dart';

class ItineraryScreen extends StatefulWidget {
  const ItineraryScreen({super.key});

  @override
  State<ItineraryScreen> createState() => _ItineraryScreenState();
}

class _ItineraryScreenState extends State<ItineraryScreen> {
  final _descCtrl = TextEditingController();
  final _formKey = GlobalKey<FormState>();
  DateTime? _selectedDate;
  TimeOfDay? _selectedTime;

  @override
  void dispose() {
    _descCtrl.dispose();
    super.dispose();
  }

  Future<void> _pickDate() async {
    final picked = await showDatePicker(
      context: context,
      initialDate: DateTime.now(),
      firstDate: DateTime(2020),
      lastDate: DateTime(2030),
    );
    if (picked != null) setState(() => _selectedDate = picked);
  }

  Future<void> _pickTime() async {
    final picked =
        await showTimePicker(context: context, initialTime: TimeOfDay.now());
    if (picked != null) setState(() => _selectedTime = picked);
  }

  void _showMsg(String msg, bool isError) {
    ScaffoldMessenger.of(context).showSnackBar(SnackBar(
      content: Row(children: [
        Icon(isError ? Icons.warning_amber_rounded : Icons.check_circle,
            color: Colors.white, size: 18),
        const SizedBox(width: 8),
        Expanded(
            child:
                Text(msg, style: AppText.body(size: 13, color: Colors.white))),
      ]),
      backgroundColor: isError ? AppColors.danger : AppColors.success,
      behavior: SnackBarBehavior.floating,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      margin: const EdgeInsets.all(12),
    ));
  }

  Future<void> _addItem(String tripId, ItineraryProvider provider) async {
    if (_selectedDate == null) {
      _showMsg('Please pick a date', true);
      return;
    }
    if (!_formKey.currentState!.validate()) return;
    final timeStr = _selectedTime != null
        ? '${_selectedTime!.hour.toString().padLeft(2, '0')}:${_selectedTime!.minute.toString().padLeft(2, '0')}'
        : null;
    await provider.addItem(
      tripId: tripId,
      date: _selectedDate!,
      time: timeStr,
      description: _descCtrl.text.trim(),
    );
    setState(() {
      _descCtrl.clear();
      _selectedDate = null;
      _selectedTime = null;
    });
    _showMsg('Activity added! 🗓️', false);
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
            const Text('Itinerary'),
          ],
        ),
      ),
      body: Consumer2<TripProvider, ItineraryProvider>(
        builder: (context, tripProv, itinProv, _) {
          final trip = tripProv.selectedTrip;
          if (trip == null) return _noTrip();
          itinProv.loadForTrip(trip.id);
          return Column(children: [
            _buildForm(trip.id, itinProv),
            Expanded(child: _buildList(itinProv, trip.id)),
          ]);
        },
      ),
    );
  }

  Widget _noTrip() {
    return Center(
      child: Column(mainAxisSize: MainAxisSize.min, children: [
        const Icon(Icons.map_outlined, size: 56, color: AppColors.peach),
        const SizedBox(height: 12),
        Text('Pick a trip first!',
            style: AppText.cursive(size: 22, color: AppColors.textMuted)),
        const SizedBox(height: 4),
        Text('Go to the Trips tab and select one',
            style: AppText.body(size: 13, color: AppColors.textMuted)),
      ]),
    );
  }

  Widget _buildForm(String tripId, ItineraryProvider provider) {
    return Container(
      margin: const EdgeInsets.all(14),
      padding: const EdgeInsets.all(18),
      decoration: AppDecor.softCard,
      child: Form(
        key: _formKey,
        child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
          Text('✨ Add Activity', style: AppText.cursive(size: 18)),
          const SizedBox(height: 12),
          Row(children: [
            Expanded(
                child: _tapTile(
              label: _selectedDate == null
                  ? '📅 Pick Date'
                  : DateFormat('dd MMM yyyy').format(_selectedDate!),
              onTap: _pickDate,
              active: _selectedDate != null,
            )),
            const SizedBox(width: 10),
            Expanded(
                child: _tapTile(
              label: _selectedTime == null
                  ? '🕐 Time (opt.)'
                  : _selectedTime!.format(context),
              onTap: _pickTime,
              active: _selectedTime != null,
            )),
          ]),
          const SizedBox(height: 12),
          TextFormField(
            controller: _descCtrl,
            maxLines: 2,
            decoration:
                AppDecor.inputDecoration('Activity description', icon: Icons.edit_note),
            validator: (v) {
              if (v == null || v.trim().isEmpty) return 'Required';
              if (v.trim().length < 3) return 'Min 3 characters';
              return null;
            },
          ),
          const SizedBox(height: 12),
          SizedBox(
            width: double.infinity,
            child: ElevatedButton.icon(
              onPressed: () => _addItem(tripId, provider),
              icon: const Icon(Icons.add),
              label: const Text('Add to Itinerary'),
            ),
          ),
        ]),
      ),
    );
  }

  Widget _tapTile(
      {required String label, required VoidCallback onTap, bool active = false}) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 14),
        decoration: BoxDecoration(
          color: Colors.white,
          border: Border.all(
              color: active ? AppColors.mint : AppColors.peach.withOpacity(0.4)),
          borderRadius: BorderRadius.circular(12),
        ),
        child: Text(label,
            style: AppText.body(
                size: 13,
                color: active ? AppColors.textDark : AppColors.textMuted),
            overflow: TextOverflow.ellipsis),
      ),
    );
  }

  Widget _buildList(ItineraryProvider provider, String tripId) {
    final grouped = provider.groupedByDay;
    if (grouped.isEmpty) {
      return Center(
        child: Text('No activities yet 🏖️',
            style: AppText.body(size: 14, color: AppColors.textMuted)),
      );
    }
    return ListView(
      padding: const EdgeInsets.symmetric(horizontal: 14),
      children: grouped.entries.map((entry) {
        final date = DateTime.parse(entry.key);
        return Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
          Container(
            width: double.infinity,
            padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
            margin: const EdgeInsets.only(bottom: 8),
            decoration: BoxDecoration(
              gradient: const LinearGradient(
                  colors: [AppColors.coral, AppColors.peach]),
              borderRadius: BorderRadius.circular(12),
            ),
            child: Text('📅 ${DateFormat('dd MMM yyyy (EEEE)').format(date)}',
                style: AppText.body(
                    size: 14, color: Colors.white, weight: FontWeight.w600)),
          ),
          ...entry.value
              .map((item) => _buildItemRow(item, provider, tripId)),
          const SizedBox(height: 12),
        ]);
      }).toList(),
    );
  }

  Widget _buildItemRow(
      ItineraryItem item, ItineraryProvider provider, String tripId) {
    return Container(
      margin: const EdgeInsets.only(bottom: 6),
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
      decoration: AppDecor.softCard,
      child: Row(children: [
        Container(
          width: 52,
          alignment: Alignment.center,
          padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 4),
          decoration: BoxDecoration(
              color: AppColors.skyBlue.withOpacity(0.3),
              borderRadius: BorderRadius.circular(8)),
          child: Text(item.time ?? '–',
              style: AppText.label(size: 12, color: AppColors.textDark)),
        ),
        const SizedBox(width: 12),
        Expanded(child: Text(item.description, style: AppText.body(size: 13))),
        IconButton(
          icon: const Icon(Icons.close, color: AppColors.danger, size: 18),
          padding: EdgeInsets.zero,
          constraints: const BoxConstraints(),
          onPressed: () => provider.deleteItem(item.id, tripId),
        ),
      ]),
    );
  }
}
