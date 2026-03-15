import 'animal_record.dart';

class Animal {
  String name;
  final List<AnimalRecord> records;

  Animal({required this.name, List<AnimalRecord>? records})
    : records = records ?? [];

  double get totalAmount => records.fold(0.0, (sum, item) => sum + item.amount);

  double get totalMilk => records.fold(0.0, (sum, item) => sum + item.milk);
}
