class LaborEntry {
  final int? id;
  final String name;
  final String mobile;
  final double days;
  final double dailyRate;

  LaborEntry({
    this.id,
    required this.name,
    required this.mobile,
    required this.days,
    required this.dailyRate,
  });

  double get total => days * dailyRate;
}
