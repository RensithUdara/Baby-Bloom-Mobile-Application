enum GrowthMetric { weight, height, bmi }

class GrowthRecord {
  int? id;
  final int babyId;
  final DateTime recordedDate;
  final double weightKg;
  final double heightCm;

  GrowthRecord({
    this.id,
    required this.babyId,
    required this.recordedDate,
    required this.weightKg,
    required this.heightCm,
  });

  double get bmi {
    final heightM = heightCm / 100;
    if (heightM == 0) return 0;
    return weightKg / (heightM * heightM);
  }

  String get label => '${recordedDate.day}/${recordedDate.month}';

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'babyId': babyId,
      'recordedDate': recordedDate.toIso8601String(),
      'weightKg': weightKg,
      'heightCm': heightCm,
    };
  }

  factory GrowthRecord.fromMap(Map<String, dynamic> map) {
    return GrowthRecord(
      id: map['id'] as int?,
      babyId: map['babyId'] as int,
      recordedDate: DateTime.parse(map['recordedDate'] as String),
      weightKg: (map['weightKg'] as num).toDouble(),
      heightCm: (map['heightCm'] as num).toDouble(),
    );
  }
}
