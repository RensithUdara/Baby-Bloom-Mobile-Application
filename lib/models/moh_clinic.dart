class MohClinic {
  final String mohArea;
  final String name;
  final double distanceKm;
  final DateTime nextClinicDate;
  final String phone;
  final String workingHours;
  final String address;
  final String? photoUrl;

  MohClinic({
    required this.mohArea,
    required this.name,
    required this.distanceKm,
    required this.nextClinicDate,
    required this.phone,
    required this.workingHours,
    required this.address,
    this.photoUrl,
  });

  String get nextClinicDateText {
    const months = [
      'Jan',
      'Feb',
      'Mar',
      'Apr',
      'May',
      'Jun',
      'Jul',
      'Aug',
      'Sep',
      'Oct',
      'Nov',
      'Dec',
    ];
    return '${nextClinicDate.day} ${months[nextClinicDate.month - 1]} ${nextClinicDate.year}';
  }
}
