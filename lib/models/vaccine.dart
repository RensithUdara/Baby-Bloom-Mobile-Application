class Vaccine {
  int? id;
  int babyId;
  String vaccineName;
  String? vaccineCode;
  int doseNumber;
  DateTime dueDate;
  String status;
  DateTime? completedDate;
  String? cardPhotoPath;

  Vaccine({
    this.id,
    required this.babyId,
    required this.vaccineName,
    this.vaccineCode,
    required this.doseNumber,
    required this.dueDate,
    this.status = 'pending',
    this.completedDate,
    this.cardPhotoPath,
  });

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'babyId': babyId,
      'vaccineName': vaccineName,
      'vaccineCode': vaccineCode,
      'doseNumber': doseNumber,
      'dueDate': dueDate.toIso8601String(),
      'status': status,
      'completedDate': completedDate?.toIso8601String(),
      'cardPhotoPath': cardPhotoPath,
    };
  }

  factory Vaccine.fromMap(Map<String, dynamic> map) {
    return Vaccine(
      id: map['id'],
      babyId: map['babyId'],
      vaccineName: map['vaccineName'],
      vaccineCode: map['vaccineCode'] as String?,
      doseNumber: map['doseNumber'],
      dueDate: DateTime.parse(map['dueDate']),
      status: map['status'],
      completedDate: map['completedDate'] != null
          ? DateTime.parse(map['completedDate'])
          : null,
      cardPhotoPath: map['cardPhotoPath'],
    );
  }
}
