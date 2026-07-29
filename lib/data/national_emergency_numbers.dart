import 'package:flutter/material.dart';
import '../models/emergency_contact.dart';

/// Sri Lanka island-wide emergency helplines. These are well-known public
/// numbers - please verify locally if in doubt.
class NationalEmergencyNumbersData {
  static const List<NationalEmergencyNumber> numbers = [
    NationalEmergencyNumber(
      label: 'Ambulance (Suwa Seriya)',
      phone: '1990',
      icon: Icons.local_hospital_rounded,
    ),
    NationalEmergencyNumber(
      label: 'Police Emergency',
      phone: '119',
      icon: Icons.local_police_rounded,
    ),
    NationalEmergencyNumber(
      label: 'Fire & Rescue',
      phone: '110',
      icon: Icons.local_fire_department_rounded,
    ),
    NationalEmergencyNumber(
      label: 'Women & Children Helpline',
      phone: '1938',
      icon: Icons.family_restroom_rounded,
    ),
  ];
}
