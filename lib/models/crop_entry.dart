class CropEntry {
  String cropType;
  double landSize;
  double cropWeight;
  String weightUnit;

  CropEntry({
    required this.cropType,
    required this.landSize,
    required this.cropWeight,
    required this.weightUnit,
  });

  double get cropWeightKg => weightUnit == 'man' ? cropWeight * 20 : cropWeight;
}
