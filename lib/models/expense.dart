import 'package:hive/hive.dart';

part 'expense.g.dart';

@HiveType(typeId: 2)
class Expense extends HiveObject {
  @HiveField(0)
  late String id;

  @HiveField(1)
  late String tripId;

  @HiveField(2)
  late double amount;

  @HiveField(3)
  late String paidBy;

  @HiveField(4)
  late String description;

  @HiveField(5)
  late DateTime date;

  Expense({
    required this.id,
    required this.tripId,
    required this.amount,
    required this.paidBy,
    required this.description,
    required this.date,
  });
}
