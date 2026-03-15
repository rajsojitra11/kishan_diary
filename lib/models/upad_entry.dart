class UpadEntry {
  final int? id;
  final int? laborEntryId;
  final int? landId;
  final String laborName;
  final double amount;
  final String note;
  final String date;

  UpadEntry({
    this.id,
    this.laborEntryId,
    this.landId,
    required this.laborName,
    required this.amount,
    required this.note,
    required this.date,
  });
}
