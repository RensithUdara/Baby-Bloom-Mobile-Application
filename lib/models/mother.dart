class Mother {
  int? id;
  final String name;
  final String nic;
  final String phone;
  final String address;
  final String mohArea;
  final String nearestClinic;
  final String? photoUrl;

  Mother({
    this.id,
    required this.name,
    required this.nic,
    required this.phone,
    required this.address,
    required this.mohArea,
    required this.nearestClinic,
    this.photoUrl,
  });

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'name': name,
      'nic': nic,
      'phone': phone,
      'address': address,
      'mohArea': mohArea,
      'nearestClinic': nearestClinic,
      'photoUrl': photoUrl,
    };
  }

  factory Mother.fromMap(Map<String, dynamic> map) {
    return Mother(
      id: map['id'] as int?,
      name: map['name'] as String,
      nic: map['nic'] as String,
      phone: map['phone'] as String,
      address: map['address'] as String,
      mohArea: map['mohArea'] as String,
      nearestClinic: map['nearestClinic'] as String,
      photoUrl: map['photoUrl'] as String?,
    );
  }

  Mother copyWith({
    int? id,
    String? name,
    String? nic,
    String? phone,
    String? address,
    String? mohArea,
    String? nearestClinic,
    String? photoUrl,
  }) {
    return Mother(
      id: id ?? this.id,
      name: name ?? this.name,
      nic: nic ?? this.nic,
      phone: phone ?? this.phone,
      address: address ?? this.address,
      mohArea: mohArea ?? this.mohArea,
      nearestClinic: nearestClinic ?? this.nearestClinic,
      photoUrl: photoUrl ?? this.photoUrl,
    );
  }
}
