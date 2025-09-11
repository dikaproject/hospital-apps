class UserModel {
  final String id;
  final String email;
  final String fullName;
  final String? nik;
  final String? phone;
  final String? gender;
  final DateTime? dateOfBirth;
  final String? street;
  final String? village;
  final String? district;
  final String? regency;
  final String? province;
  final String qrCode;
  final String? fingerprintData;
  final String? profilePicture; // Tambah ini
  final String role;
  final bool isActive;
  final DateTime createdAt;
  final DateTime? lastLogin;

  UserModel({
    required this.id,
    required this.email,
    required this.fullName,
    this.nik,
    this.phone,
    this.gender,
    this.dateOfBirth,
    this.street,
    this.village,
    this.district,
    this.regency,
    this.province,
    required this.qrCode,
    this.fingerprintData,
    this.profilePicture, // Tambah ini
    required this.role,
    required this.isActive,
    required this.createdAt,
    this.lastLogin,
  });

  // Convert from backend API response
  factory UserModel.fromApiResponse(Map<String, dynamic> json) {
    return UserModel(
      id: json['id'] ?? '',
      email: json['email'] ?? '',
      fullName: json['fullName'] ?? '',
      nik: json['nik'],
      phone: json['phone'],
      gender: json['gender'],
      dateOfBirth: json['dateOfBirth'] != null
          ? DateTime.parse(json['dateOfBirth'])
          : null,
      street: json['street'],
      village: json['village'],
      district: json['district'],
      regency: json['regency'],
      province: json['province'],
      qrCode: json['qrCode'] ?? '',
      fingerprintData: json['fingerprintData'],
      profilePicture: json['profilePicture'], // Tambah ini
      role: json['role'] ?? 'USER',
      isActive: json['isActive'] ?? true,
      createdAt:
          DateTime.parse(json['createdAt'] ?? DateTime.now().toIso8601String()),
      lastLogin:
          json['lastLogin'] != null ? DateTime.parse(json['lastLogin']) : null,
    );
  }

  // Convert to API request body
  Map<String, dynamic> toApiRequest() {
    final Map<String, dynamic> data = {
      'email': email,
      'fullName': fullName,
    };

    if (nik != null) data['nik'] = nik;
    if (phone != null) data['phone'] = phone;
    if (gender != null) data['gender'] = gender;
    if (dateOfBirth != null)
      data['dateOfBirth'] = dateOfBirth!.toIso8601String().split('T')[0];
    if (street != null) data['street'] = street;
    if (village != null) data['village'] = village;
    if (district != null) data['district'] = district;
    if (regency != null) data['regency'] = regency;
    if (province != null) data['province'] = province;
    if (fingerprintData != null) data['fingerprintData'] = fingerprintData;

    return data;
  }

  String get fullAddress {
    List<String> addressParts = [];
    if (street != null && street!.isNotEmpty) addressParts.add(street!);
    if (village != null && village!.isNotEmpty) addressParts.add(village!);
    if (district != null && district!.isNotEmpty) addressParts.add(district!);
    if (regency != null && regency!.isNotEmpty) addressParts.add(regency!);
    if (province != null && province!.isNotEmpty) addressParts.add(province!);
    return addressParts.join(', ');
  }

  bool get isPatient => role == 'USER';
  bool get isDoctor => role == 'DOCTOR';
  bool get isAdmin => role == 'ADMIN';

  UserModel copyWith({
    String? id,
    String? email,
    String? fullName,
    String? nik,
    String? phone,
    String? gender,
    DateTime? dateOfBirth,
    String? street,
    String? village,
    String? district,
    String? regency,
    String? province,
    String? qrCode,
    String? fingerprintData,
    String? profilePicture,
    String? role,
    bool? isActive,
    DateTime? createdAt,
    DateTime? lastLogin,
  }) {
    return UserModel(
      id: id ?? this.id,
      email: email ?? this.email,
      fullName: fullName ?? this.fullName,
      nik: nik ?? this.nik,
      phone: phone ?? this.phone,
      gender: gender ?? this.gender,
      dateOfBirth: dateOfBirth ?? this.dateOfBirth,
      street: street ?? this.street,
      village: village ?? this.village,
      district: district ?? this.district,
      regency: regency ?? this.regency,
      province: province ?? this.province,
      qrCode: qrCode ?? this.qrCode,
      fingerprintData: fingerprintData, // Allow null explicitly
      profilePicture: profilePicture ?? this.profilePicture,
      role: role ?? this.role,
      isActive: isActive ?? this.isActive,
      createdAt: createdAt ?? this.createdAt,
      lastLogin: lastLogin ?? this.lastLogin,
    );
  }
}

// Keep address models for dropdown API (separate from user model)
class AddressModel {
  final String street;
  final String village;
  final String district;
  final String regency;
  final String province;
  final String? villageId;
  final String? districtId;
  final String? regencyId;
  final String? provinceId;

  AddressModel({
    required this.street,
    required this.village,
    required this.district,
    required this.regency,
    required this.province,
    this.villageId,
    this.districtId,
    this.regencyId,
    this.provinceId,
  });

  Map<String, dynamic> toMap() {
    return {
      'street': street,
      'village': village,
      'district': district,
      'regency': regency,
      'province': province,
      'villageId': villageId,
      'districtId': districtId,
      'regencyId': regencyId,
      'provinceId': provinceId,
    };
  }

  String get fullAddress {
    return '$street, $village, $district, $regency, $province';
  }
}

class Province {
  final String id;
  final String name;

  Province({required this.id, required this.name});

  factory Province.fromMap(Map<String, dynamic> map) {
    return Province(
      id: map['id'] ?? '',
      name: map['name'] ?? '',
    );
  }
}

class Regency {
  final String id;
  final String name;
  final String provinceId;

  Regency({required this.id, required this.name, required this.provinceId});

  factory Regency.fromMap(Map<String, dynamic> map) {
    return Regency(
      id: map['id'] ?? '',
      name: map['name'] ?? '',
      provinceId: map['province_id'] ?? '',
    );
  }
}

class District {
  final String id;
  final String name;
  final String regencyId;

  District({required this.id, required this.name, required this.regencyId});

  factory District.fromMap(Map<String, dynamic> map) {
    return District(
      id: map['id'] ?? '',
      name: map['name'] ?? '',
      regencyId: map['regency_id'] ?? '',
    );
  }
}

class Village {
  final String id;
  final String name;
  final String districtId;

  Village({required this.id, required this.name, required this.districtId});

  factory Village.fromMap(Map<String, dynamic> map) {
    return Village(
      id: map['id'] ?? '',
      name: map['name'] ?? '',
      districtId: map['district_id'] ?? '',
    );
  }
}
