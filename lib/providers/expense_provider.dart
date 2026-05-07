import 'package:flutter/foundation.dart';
import '../models/expense.dart';
import '../services/hive_service.dart';

class Settlement {
  final String from;
  final String to;
  final double amount;
  Settlement({required this.from, required this.to, required this.amount});
}

class ExpenseProvider extends ChangeNotifier {
  List<Expense> _expenses = [];
  String _filterParticipant = '';
  DateTime? _filterDate;

  List<Expense> get expenses => _expenses;
  String get filterParticipant => _filterParticipant;
  DateTime? get filterDate => _filterDate;

  List<Expense> get filteredExpenses {
    return _expenses.where((e) {
      final matchPart =
          _filterParticipant.isEmpty || e.paidBy == _filterParticipant;
      final matchDate = _filterDate == null ||
          (e.date.year == _filterDate!.year &&
              e.date.month == _filterDate!.month &&
              e.date.day == _filterDate!.day);
      return matchPart && matchDate;
    }).toList();
  }

  double get totalExpenses =>
      _expenses.fold(0, (sum, e) => sum + e.amount);

  void loadForTrip(String tripId) {
    _expenses = HiveService.getExpensesForTrip(tripId);
    notifyListeners();
  }

  void setFilterParticipant(String p) {
    _filterParticipant = p;
    notifyListeners();
  }

  void setFilterDate(DateTime? d) {
    _filterDate = d;
    notifyListeners();
  }

  void clearFilters() {
    _filterParticipant = '';
    _filterDate = null;
    notifyListeners();
  }

  Future<void> addExpense({
    required String tripId,
    required double amount,
    required String paidBy,
    required String description,
    required DateTime date,
  }) async {
    final expense = Expense(
      id: DateTime.now().millisecondsSinceEpoch.toString(),
      tripId: tripId,
      amount: amount,
      paidBy: paidBy,
      description: description,
      date: date,
    );
    await HiveService.saveExpense(expense);
    loadForTrip(tripId);
  }

  Future<void> deleteExpense(String id, String tripId) async {
    await HiveService.deleteExpense(id);
    loadForTrip(tripId);
  }

  /// How much each participant paid
  Map<String, double> paidPerPerson(List<String> participants) {
    final map = {for (final p in participants) p: 0.0};
    for (final e in _expenses) {
      map[e.paidBy] = (map[e.paidBy] ?? 0) + e.amount;
    }
    return map;
  }

  /// Simplified greedy settlement: who owes whom
  List<Settlement> computeSettlements(List<String> participants) {
    if (participants.isEmpty) return [];
    final total = totalExpenses;
    final share = total / participants.length;
    final paid = paidPerPerson(participants);
    final net = {for (final p in participants) p: (paid[p] ?? 0) - share};

    // Typed lists to avoid Map<String, Object> inference issues
    final List<String> debtorNames =
        participants.where((p) => net[p]! < -0.01).toList();
    final List<double> debtorAmts =
        debtorNames.map((p) => -net[p]!).toList();

    final List<String> creditorNames =
        participants.where((p) => net[p]! > 0.01).toList();
    final List<double> creditorAmts =
        creditorNames.map((p) => net[p]!).toList();

    final settlements = <Settlement>[];
    int i = 0, j = 0;
    while (i < debtorNames.length && j < creditorNames.length) {
      final amt = debtorAmts[i] < creditorAmts[j]
          ? debtorAmts[i]
          : creditorAmts[j];
      settlements.add(Settlement(
        from: debtorNames[i],
        to: creditorNames[j],
        amount: amt,
      ));
      debtorAmts[i] -= amt;
      creditorAmts[j] -= amt;
      if (debtorAmts[i] < 0.01) i++;
      if (creditorAmts[j] < 0.01) j++;
    }
    return settlements;
  }
}
