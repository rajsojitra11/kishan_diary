import 'dart:typed_data';

class ExpenseEntry {
  int? id;
  String type;
  double amount;
  String date;
  String note;
  String? billPhotoPath;
  String? billPhotoUrl;
  Uint8List? billPhotoBytes;

  ExpenseEntry({
    this.id,
    required this.type,
    this.amount = 0,
    required this.date,
    required this.note,
    this.billPhotoPath,
    this.billPhotoUrl,
    this.billPhotoBytes,
  });

  ExpenseEntry copyWith({
    int? id,
    String? type,
    double? amount,
    String? date,
    String? note,
    String? billPhotoPath,
    String? billPhotoUrl,
    Uint8List? billPhotoBytes,
    bool clearBillPhoto = false,
  }) {
    return ExpenseEntry(
      id: id ?? this.id,
      type: type ?? this.type,
      amount: amount ?? this.amount,
      date: date ?? this.date,
      note: note ?? this.note,
      billPhotoPath: clearBillPhoto
          ? null
          : (billPhotoPath ?? this.billPhotoPath),
      billPhotoUrl: clearBillPhoto ? null : (billPhotoUrl ?? this.billPhotoUrl),
      billPhotoBytes: clearBillPhoto
          ? null
          : (billPhotoBytes ?? this.billPhotoBytes),
    );
  }
}
