import 'package:flutter/foundation.dart';
import '../models/trip.dart';
import '../services/hive_service.dart';

class TripProvider extends ChangeNotifier {
  List<Trip> _trips = [];
  Trip? _selectedTrip;
  String _searchQuery = '';

  List<Trip> get trips => _trips;
  Trip? get selectedTrip => _selectedTrip;
  String get searchQuery => _searchQuery;

  List<Trip> get filteredTrips {
    if (_searchQuery.isEmpty) return _trips;
    return _trips
        .where((t) =>
            t.name.toLowerCase().contains(_searchQuery.toLowerCase()) ||
            t.destination.toLowerCase().contains(_searchQuery.toLowerCase()))
        .toList();
  }

  /// Load all trips from Hive on startup
  void loadTrips() {
    _trips = HiveService.getAllTrips();
    // Restore selected trip if still exists
    if (_selectedTrip != null) {
      _selectedTrip = _trips.firstWhere(
        (t) => t.id == _selectedTrip!.id,
        orElse: () => _trips.isNotEmpty ? _trips.first : _selectedTrip!,
      );
    }
    notifyListeners();
  }

  void setSearch(String query) {
    _searchQuery = query;
    notifyListeners();
  }

  void selectTrip(Trip trip) {
    _selectedTrip = trip;
    notifyListeners();
  }

  Future<void> createTrip({
    required String name,
    required String destination,
    required DateTime startDate,
    required DateTime endDate,
    required List<String> participants,
  }) async {
    final trip = Trip(
      id: DateTime.now().millisecondsSinceEpoch.toString(),
      name: name,
      destination: destination,
      startDate: startDate,
      endDate: endDate,
      participants: participants,
    );
    await HiveService.saveTrip(trip);
    _selectedTrip = trip;
    loadTrips();
  }

  Future<void> deleteTrip(String tripId) async {
    await HiveService.deleteTrip(tripId);
    if (_selectedTrip?.id == tripId) _selectedTrip = null;
    loadTrips();
  }
}
