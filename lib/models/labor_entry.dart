class LaborEntry {
  final String name;
  final String mobile;
  final int days;
  final double dailyRate;

  LaborEntry({
    required this.name,
    required this.mobile,
    required this.days,
    required this.dailyRate,
  });

  double get total => days * dailyRate;
}
