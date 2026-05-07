import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:intl/intl.dart';
import '../providers/trip_provider.dart';
import '../providers/expense_provider.dart';
import '../models/expense.dart';
import '../theme/app_theme.dart';

class ExpensesScreen extends StatefulWidget {
  const ExpensesScreen({super.key});

  @override
  State<ExpensesScreen> createState() => _ExpensesScreenState();
}

class _ExpensesScreenState extends State<ExpensesScreen> {
  final _amtCtrl = TextEditingController();
  final _descCtrl = TextEditingController();
  final _formKey = GlobalKey<FormState>();
  String? _paidBy;
  DateTime _expDate = DateTime.now();

  @override
  void dispose() {
    _amtCtrl.dispose();
    _descCtrl.dispose();
    super.dispose();
  }

  Future<void> _pickDate() async {
    final picked = await showDatePicker(
      context: context,
      initialDate: _expDate,
      firstDate: DateTime(2020),
      lastDate: DateTime(2030),
    );
    if (picked != null) setState(() => _expDate = picked);
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

  Future<void> _addExpense(
      String tripId, List<String> participants, ExpenseProvider provider) async {
    if (!_formKey.currentState!.validate()) return;

    final amt = double.tryParse(_amtCtrl.text.trim()) ?? 0;
    if (amt <= 0) {
      _showMsg('Amount must be greater than zero', true);
      return;
    }
    if (amt > 10000000) {
      _showMsg('Amount seems too large — check again', true);
      return;
    }
    final paidBy = _paidBy ?? participants.first;
    if (!participants.contains(paidBy)) {
      _showMsg('Invalid participant selected', true);
      return;
    }
    await provider.addExpense(
      tripId: tripId,
      amount: amt,
      paidBy: paidBy,
      description: _descCtrl.text.trim(),
      date: _expDate,
    );
    setState(() {
      _amtCtrl.clear();
      _descCtrl.clear();
      _expDate = DateTime.now();
    });
    _showMsg('Expense added! 💸', false);
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
            const Text('Expenses'),
          ],
        ),
      ),
      body: Consumer2<TripProvider, ExpenseProvider>(
        builder: (context, tripProv, expProv, _) {
          final trip = tripProv.selectedTrip;
          if (trip == null) {
            return Center(
              child: Column(mainAxisSize: MainAxisSize.min, children: [
                const Icon(Icons.receipt_long, size: 56, color: AppColors.peach),
                const SizedBox(height: 12),
                Text('Pick a trip first!',
                    style: AppText.cursive(
                        size: 22, color: AppColors.textMuted)),
                const SizedBox(height: 4),
                Text('Go to the Trips tab and select one',
                    style:
                        AppText.body(size: 13, color: AppColors.textMuted)),
              ]),
            );
          }
          expProv.loadForTrip(trip.id);
          _paidBy ??=
              trip.participants.isNotEmpty ? trip.participants.first : null;
          return Column(children: [
            _buildForm(trip.id, trip.participants, expProv),
            _buildFilters(trip.participants, expProv),
            Expanded(child: _buildList(expProv, trip.id)),
          ]);
        },
      ),
    );
  }

  Widget _buildForm(
      String tripId, List<String> participants, ExpenseProvider provider) {
    return Container(
      margin: const EdgeInsets.all(14),
      padding: const EdgeInsets.all(18),
      decoration: AppDecor.softCard,
      child: Form(
        key: _formKey,
        child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
          Text('💰 Add Expense', style: AppText.cursive(size: 18)),
          const SizedBox(height: 12),
          Row(children: [
            Expanded(
              child: TextFormField(
                controller: _amtCtrl,
                keyboardType: TextInputType.number,
                decoration:
                    AppDecor.inputDecoration('Amount (₹)', icon: Icons.currency_rupee),
                validator: (v) {
                  if (v == null || v.trim().isEmpty) return 'Required';
                  final n = double.tryParse(v.trim());
                  if (n == null || n <= 0) return 'Invalid amount';
                  return null;
                },
              ),
            ),
            const SizedBox(width: 10),
            Expanded(
              child: DropdownButtonFormField<String>(
                value: _paidBy,
                decoration: AppDecor.inputDecoration('Paid By', icon: Icons.person),
                items: participants
                    .map((p) => DropdownMenuItem(value: p, child: Text(p)))
                    .toList(),
                onChanged: (v) => setState(() => _paidBy = v),
                validator: (v) {
                  if (v == null || v.isEmpty) return 'Select person';
                  return null;
                },
              ),
            ),
          ]),
          const SizedBox(height: 12),
          Row(children: [
            Expanded(
              child: TextFormField(
                controller: _descCtrl,
                decoration:
                    AppDecor.inputDecoration('Description', icon: Icons.note_alt),
                validator: (v) {
                  if (v == null || v.trim().isEmpty) return 'Required';
                  if (v.trim().length < 2) return 'Too short';
                  return null;
                },
              ),
            ),
            const SizedBox(width: 10),
            Expanded(
              child: GestureDetector(
                onTap: _pickDate,
                child: Container(
                  padding: const EdgeInsets.symmetric(
                      horizontal: 14, vertical: 14),
                  decoration: BoxDecoration(
                    color: Colors.white,
                    border: Border.all(color: AppColors.peach.withOpacity(0.4)),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Row(children: [
                    const Icon(Icons.calendar_today,
                        size: 16, color: AppColors.coral),
                    const SizedBox(width: 8),
                    Text(DateFormat('dd MMM yyyy').format(_expDate),
                        style: AppText.body(size: 13)),
                  ]),
                ),
              ),
            ),
          ]),
          const SizedBox(height: 14),
          SizedBox(
            width: double.infinity,
            child: ElevatedButton.icon(
              onPressed: () => _addExpense(tripId, participants, provider),
              icon: const Icon(Icons.add),
              label: const Text('Add Expense'),
            ),
          ),
        ]),
      ),
    );
  }

  Widget _buildFilters(List<String> participants, ExpenseProvider provider) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 14),
      child: Row(children: [
        Expanded(
          child: DropdownButtonFormField<String>(
            value: provider.filterParticipant.isEmpty
                ? null
                : provider.filterParticipant,
            hint: Text('Filter by person', style: AppText.body(size: 13)),
            decoration: AppDecor.inputDecoration('').copyWith(
                prefixIcon: const Icon(Icons.filter_alt_outlined,
                    color: AppColors.coral, size: 18)),
            items: [
              DropdownMenuItem(
                  value: null,
                  child: Text('All', style: AppText.body(size: 13))),
              ...participants.map(
                  (p) => DropdownMenuItem(value: p, child: Text(p))),
            ],
            onChanged: (v) => provider.setFilterParticipant(v ?? ''),
          ),
        ),
        const SizedBox(width: 8),
        IconButton(
          icon: const Icon(Icons.calendar_month, color: AppColors.coral),
          tooltip: 'Filter by date',
          onPressed: () async {
            final picked = await showDatePicker(
              context: context,
              initialDate: provider.filterDate ?? DateTime.now(),
              firstDate: DateTime(2020),
              lastDate: DateTime(2030),
            );
            provider.setFilterDate(picked);
          },
        ),
        TextButton(
          onPressed: provider.clearFilters,
          child: Text('Clear', style: AppText.body(size: 13, color: AppColors.coral)),
        ),
      ]),
    );
  }

  Widget _buildList(ExpenseProvider provider, String tripId) {
    final list = provider.filteredExpenses;
    if (list.isEmpty) {
      return Center(
          child: Text('No expenses found 🧾',
              style: AppText.body(size: 14, color: AppColors.textMuted)));
    }
    return ListView.builder(
      padding: const EdgeInsets.all(14),
      itemCount: list.length,
      itemBuilder: (context, i) =>
          _buildExpenseRow(list[i], provider, tripId),
    );
  }

  Widget _buildExpenseRow(
      Expense expense, ExpenseProvider provider, String tripId) {
    return Container(
      margin: const EdgeInsets.only(bottom: 8),
      padding: const EdgeInsets.all(14),
      decoration: AppDecor.softCard,
      child: Row(children: [
        CircleAvatar(
          radius: 20,
          backgroundColor: AppColors.lavender.withOpacity(0.5),
          child: Text(expense.paidBy[0].toUpperCase(),
              style: AppText.body(
                  size: 16,
                  weight: FontWeight.w700,
                  color: AppColors.coral)),
        ),
        const SizedBox(width: 12),
        Expanded(
          child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
            Text(expense.description,
                style: AppText.body(size: 14, weight: FontWeight.w600)),
            Text(
                '${expense.paidBy}  •  ${DateFormat('dd MMM').format(expense.date)}',
                style: AppText.label(size: 12)),
          ]),
        ),
        Text('₹${expense.amount.toStringAsFixed(2)}',
            style: AppText.body(
                size: 15, weight: FontWeight.w700, color: AppColors.coral)),
        IconButton(
          icon: const Icon(Icons.close, color: AppColors.danger, size: 18),
          onPressed: () => provider.deleteExpense(expense.id, tripId),
        ),
      ]),
    );
  }
}
