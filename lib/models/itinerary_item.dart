import 'package:hive/hive.dart';

part 'itinerary_item.g.dart';

@HiveType(typeId: 1)
class ItineraryItem extends HiveObject {
  @HiveField(0)
  late String id;

  @HiveField(1)
  late String tripId;

  @HiveField(2)
  late DateTime date;

  @HiveField(3)
  String? time; // optional, stored as "HH:mm" string

  @HiveField(4)
  late String description;

  ItineraryItem({
    required this.id,
    required this.tripId,
    required this.date,
    this.time,
    required this.description,
  });
}
