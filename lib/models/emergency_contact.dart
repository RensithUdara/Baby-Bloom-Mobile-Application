import 'package:flutter/material.dart';

class EmergencyContact {
  final int? id;
  final String name;
  final String phone;
  final String? relation;

  EmergencyContact({
    this.id,
    required this.name,
    required this.phone,
    this.relation,
  });

  Map<String, dynamic> toMap() {
    return {'id': id, 'name': name, 'phone': phone, 'relation': relation};
  }

  factory EmergencyContact.fromMap(Map<String, dynamic> map) {
    return EmergencyContact(
      id: map['id'] as int?,
      name: map['name'] as String,
      phone: map['phone'] as String,
      relation: map['relation'] as String?,
    );
  }
}

class NationalEmergencyNumber {
  final String label;
  final String phone;
  final IconData icon;

  const NationalEmergencyNumber({
    required this.label,
    required this.phone,
    required this.icon,
  });
}
