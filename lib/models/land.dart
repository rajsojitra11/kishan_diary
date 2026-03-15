import 'crop_entry.dart';
import 'expense_entry.dart';
import 'income_entry.dart';
import 'labor_entry.dart';
import 'upad_entry.dart';

class Land {
  int? id;
  String name;
  double size;
  String location;
  double laborRupees;
  double fertilizerKg;
  double income;
  double expenses;
  double cropProductionKg;
  double animalIncome;
  List<CropEntry> cropEntries;
  List<ExpenseEntry> expenseEntries;
  List<IncomeEntry> incomeEntries;
  List<LaborEntry> laborEntries;
  List<UpadEntry> upadEntries;
  bool detailsLoaded;

  Land({
    this.id,
    required this.name,
    required this.size,
    required this.location,
    this.laborRupees = 0,
    this.fertilizerKg = 0,
    this.income = 0,
    this.expenses = 0,
    this.cropProductionKg = 0,
    this.animalIncome = 0,
    List<CropEntry>? cropEntries,
    List<ExpenseEntry>? expenseEntries,
    List<IncomeEntry>? incomeEntries,
    List<LaborEntry>? laborEntries,
    List<UpadEntry>? upadEntries,
    this.detailsLoaded = false,
  }) : cropEntries = cropEntries ?? [],
       expenseEntries = expenseEntries ?? [],
       incomeEntries = incomeEntries ?? [],
       laborEntries = laborEntries ?? [],
       upadEntries = upadEntries ?? [];
}
