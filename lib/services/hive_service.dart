import 'package:hive_flutter/hive_flutter.dart';
import '../models/trip.dart';
import '../models/itinerary_item.dart';
import '../models/expense.dart';

class HiveService {
  static const String _tripsBox = 'trips';
  static const String _itineraryBox = 'itinerary';
  static const String _expensesBox = 'expenses';

  /// Call once in main() before runApp
  static Future<void> init() async {
    await Hive.initFlutter();
    Hive.registerAdapter(TripAdapter());
    Hive.registerAdapter(ItineraryItemAdapter());
    Hive.registerAdapter(ExpenseAdapter());
    await Hive.openBox<Trip>(_tripsBox);
    await Hive.openBox<ItineraryItem>(_itineraryBox);
    await Hive.openBox<Expense>(_expensesBox);
  }

  // ── Trips ────────────────────────────────────────────────────────
  static Box<Trip> get tripsBox => Hive.box<Trip>(_tripsBox);

  static List<Trip> getAllTrips() => tripsBox.values.toList().reversed.toList();

  static Future<void> saveTrip(Trip trip) async {
    await tripsBox.put(trip.id, trip);
  }

  static Future<void> deleteTrip(String tripId) async {
    await tripsBox.delete(tripId);
    // cascade delete related items
    final iBox = Hive.box<ItineraryItem>(_itineraryBox);
    final toDeleteI = iBox.values.where((i) => i.tripId == tripId).toList();
    for (final item in toDeleteI) {
      await iBox.delete(item.id);
    }
    final eBox = Hive.box<Expense>(_expensesBox);
    final toDeleteE = eBox.values.where((e) => e.tripId == tripId).toList();
    for (final exp in toDeleteE) {
      await eBox.delete(exp.id);
    }
  }

  // ── Itinerary ────────────────────────────────────────────────────
  static Box<ItineraryItem> get itineraryBox =>
      Hive.box<ItineraryItem>(_itineraryBox);

  static List<ItineraryItem> getItineraryForTrip(String tripId) {
    final items =
        itineraryBox.values.where((i) => i.tripId == tripId).toList();
    items.sort((a, b) {
      final dateComp = a.date.compareTo(b.date);
      if (dateComp != 0) return dateComp;
      return (a.time ?? '').compareTo(b.time ?? '');
    });
    return items;
  }

  static Future<void> saveItineraryItem(ItineraryItem item) async {
    await itineraryBox.put(item.id, item);
  }

  static Future<void> deleteItineraryItem(String id) async {
    await itineraryBox.delete(id);
  }

  // ── Expenses ─────────────────────────────────────────────────────
  static Box<Expense> get expensesBox => Hive.box<Expense>(_expensesBox);

  static List<Expense> getExpensesForTrip(String tripId) {
    return expensesBox.values.where((e) => e.tripId == tripId).toList();
  }

  static Future<void> saveExpense(Expense expense) async {
    await expensesBox.put(expense.id, expense);
  }

  static Future<void> deleteExpense(String id) async {
    await expensesBox.delete(id);
  }
}
