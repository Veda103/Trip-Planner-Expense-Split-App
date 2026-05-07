import 'package:hive/hive.dart';

part 'trip.g.dart';

@HiveType(typeId: 0)
class Trip extends HiveObject {
  @HiveField(0)
  late String id;

  @HiveField(1)
  late String name;

  @HiveField(2)
  late String destination;

  @HiveField(3)
  late DateTime startDate;

  @HiveField(4)
  late DateTime endDate;

  @HiveField(5)
  late List<String> participants;

  Trip({
    required this.id,
    required this.name,
    required this.destination,
    required this.startDate,
    required this.endDate,
    required this.participants,
  });
}
