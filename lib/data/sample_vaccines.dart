import '../models/vaccine.dart';

List<Vaccine> sampleVaccines({int babyId = 1}) {
  return [
    Vaccine(
      babyId: babyId,
      vaccineName: 'BCG',
      doseNumber: 1,
      dueDate: DateTime(2026, 5, 22),
      status: 'pending',
    ),
    Vaccine(
      babyId: babyId,
      vaccineName: 'Pentavalent 1',
      doseNumber: 1,
      dueDate: DateTime(2026, 7, 21),
      status: 'pending',
    ),
    Vaccine(
      babyId: babyId,
      vaccineName: 'OPV 1',
      doseNumber: 1,
      dueDate: DateTime(2026, 7, 21),
      status: 'pending',
    ),
    Vaccine(
      babyId: babyId,
      vaccineName: 'fIPV 1',
      doseNumber: 1,
      dueDate: DateTime(2026, 7, 21),
      status: 'pending',
    ),
    Vaccine(
      babyId: babyId,
      vaccineName: 'Pentavalent 2',
      doseNumber: 2,
      dueDate: DateTime(2026, 9, 19),
      status: 'pending',
    ),
    Vaccine(
      babyId: babyId,
      vaccineName: 'OPV 2',
      doseNumber: 2,
      dueDate: DateTime(2026, 9, 19),
      status: 'pending',
    ),
    Vaccine(
      babyId: babyId,
      vaccineName: 'fIPV 2',
      doseNumber: 2,
      dueDate: DateTime(2026, 9, 19),
      status: 'pending',
    ),
    Vaccine(
      babyId: babyId,
      vaccineName: 'Pentavalent 3',
      doseNumber: 3,
      dueDate: DateTime(2026, 11, 18),
      status: 'pending',
    ),
  ];
}
