class Land {
  String name;
  double size;
  String location;
  double laborRupees;
  double fertilizerKg;
  double income;
  double expenses;
  double cropProductionKg;
  double animalIncome;

  Land({
    required this.name,
    required this.size,
    required this.location,
    this.laborRupees = 0,
    this.fertilizerKg = 0,
    this.income = 0,
    this.expenses = 0,
    this.cropProductionKg = 0,
    this.animalIncome = 0,
  });
}
