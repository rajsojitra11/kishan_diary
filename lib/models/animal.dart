import 'animal_record.dart';

class Animal {
  int? id;
  String name;
  final List<AnimalRecord> records;
  double? totalAmountCached;
  double? totalMilkCached;

  Animal({
    this.id,
    required this.name,
    List<AnimalRecord>? records,
    this.totalAmountCached,
    this.totalMilkCached,
  }) : records = records ?? [];

  double get totalAmount => records.isNotEmpty
      ? records.fold(0.0, (sum, item) => sum + item.amount)
      : (totalAmountCached ?? 0.0);

  double get totalMilk => records.isNotEmpty
      ? records.fold(0.0, (sum, item) => sum + item.milk)
      : (totalMilkCached ?? 0.0);
}
