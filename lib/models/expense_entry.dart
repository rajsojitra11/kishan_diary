import 'dart:typed_data';

class ExpenseEntry {
  String type;
  double amount;
  String date;
  String note;
  String? billPhotoPath;
  Uint8List? billPhotoBytes;

  ExpenseEntry({
    required this.type,
    this.amount = 0,
    required this.date,
    required this.note,
    this.billPhotoPath,
    this.billPhotoBytes,
  });

  ExpenseEntry copyWith({
    String? type,
    double? amount,
    String? date,
    String? note,
    String? billPhotoPath,
    Uint8List? billPhotoBytes,
    bool clearBillPhoto = false,
  }) {
    return ExpenseEntry(
      type: type ?? this.type,
      amount: amount ?? this.amount,
      date: date ?? this.date,
      note: note ?? this.note,
      billPhotoPath: clearBillPhoto
          ? null
          : (billPhotoPath ?? this.billPhotoPath),
      billPhotoBytes: clearBillPhoto
          ? null
          : (billPhotoBytes ?? this.billPhotoBytes),
    );
  }
}
