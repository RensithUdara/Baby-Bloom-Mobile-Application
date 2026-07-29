class Baby {
  int? id;
  String name;
  DateTime dob;
  String gender;
  String? photoPath;
  String? bloodGroup;
  double? birthWeightKg;
  String? hospital;

  Baby({
    this.id,
    required this.name,
    required this.dob,
    required this.gender,
    this.photoPath,
    this.bloodGroup,
    this.birthWeightKg,
    this.hospital,
  });

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'name': name,
      'dob': dob.toIso8601String(),
      'gender': gender,
      'photoPath': photoPath,
      'bloodGroup': bloodGroup,
      'birthWeightKg': birthWeightKg,
      'hospital': hospital,
    };
  }

  factory Baby.fromMap(Map<String, dynamic> map) {
    return Baby(
      id: map['id'],
      name: map['name'],
      dob: DateTime.parse(map['dob']),
      gender: map['gender'] ?? 'female',
      photoPath: map['photoPath'],
      bloodGroup: map['bloodGroup'],
      birthWeightKg: map['birthWeightKg'] != null
          ? (map['birthWeightKg'] as num).toDouble()
          : null,
      hospital: map['hospital'],
    );
  }
}
