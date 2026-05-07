import 'package:flutter/foundation.dart';
import '../models/itinerary_item.dart';
import '../services/hive_service.dart';

class ItineraryProvider extends ChangeNotifier {
  List<ItineraryItem> _items = [];

  List<ItineraryItem> get items => _items;

  /// Group items by date (yyyy-MM-dd)
  Map<String, List<ItineraryItem>> get groupedByDay {
    final Map<String, List<ItineraryItem>> map = {};
    for (final item in _items) {
      final key =
          '${item.date.year}-${item.date.month.toString().padLeft(2, '0')}-${item.date.day.toString().padLeft(2, '0')}';
      (map[key] ??= []).add(item);
    }
    return Map.fromEntries(
        map.entries.toList()..sort((a, b) => a.key.compareTo(b.key)));
  }

  void loadForTrip(String tripId) {
    _items = HiveService.getItineraryForTrip(tripId);
    notifyListeners();
  }

  Future<void> addItem({
    required String tripId,
    required DateTime date,
    String? time,
    required String description,
  }) async {
    final item = ItineraryItem(
      id: DateTime.now().millisecondsSinceEpoch.toString(),
      tripId: tripId,
      date: date,
      time: time,
      description: description,
    );
    await HiveService.saveItineraryItem(item);
    loadForTrip(tripId);
  }

  Future<void> deleteItem(String id, String tripId) async {
    await HiveService.deleteItineraryItem(id);
    loadForTrip(tripId);
  }
}
