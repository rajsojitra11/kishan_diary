import 'dart:typed_data';

class IncomeEntry {
  String type;
  double amount;
  String date;
  String note;
  String? billPhotoPath;
  Uint8List? billPhotoBytes;

  IncomeEntry({
    required this.type,
    this.amount = 0,
    required this.date,
    required this.note,
    this.billPhotoPath,
    this.billPhotoBytes,
  });

  IncomeEntry copyWith({
    String? type,
    double? amount,
    String? date,
    String? note,
    String? billPhotoPath,
    Uint8List? billPhotoBytes,
    bool clearBillPhoto = false,
  }) {
    return IncomeEntry(
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
