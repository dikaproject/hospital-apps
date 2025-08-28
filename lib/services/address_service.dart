import 'dart:convert';
import 'package:http/http.dart' as http;

class Province {
  final String id;
  final String name;

  Province({required this.id, required this.name});

  factory Province.fromJson(Map<String, dynamic> json) {
    return Province(
      id: json['id'] ?? '',
      name: json['name'] ?? '',
    );
  }
}

class Regency {
  final String id;
  final String provinceId;
  final String name;

  Regency({required this.id, required this.provinceId, required this.name});

  factory Regency.fromJson(Map<String, dynamic> json) {
    return Regency(
      id: json['id'] ?? '',
      provinceId: json['province_id'] ?? '',
      name: json['name'] ?? '',
    );
  }
}

class District {
  final String id;
  final String regencyId;
  final String name;

  District({required this.id, required this.regencyId, required this.name});

  factory District.fromJson(Map<String, dynamic> json) {
    return District(
      id: json['id'] ?? '',
      regencyId: json['regency_id'] ?? '',
      name: json['name'] ?? '',
    );
  }
}

class Village {
  final String id;
  final String districtId;
  final String name;

  Village({required this.id, required this.districtId, required this.name});

  factory Village.fromJson(Map<String, dynamic> json) {
    return Village(
      id: json['id'] ?? '',
      districtId: json['district_id'] ?? '',
      name: json['name'] ?? '',
    );
  }
}

class AddressService {
  static const String baseUrl =
      'https://emsifa.github.io/api-wilayah-indonesia/api';

  static Future<List<Province>> getProvinces() async {
    try {
      final response = await http.get(Uri.parse('$baseUrl/provinces.json'));

      if (response.statusCode == 200) {
        final List<dynamic> data = json.decode(response.body);
        return data.map((json) => Province.fromJson(json)).toList();
      } else {
        throw Exception('Failed to load provinces');
      }
    } catch (e) {
      throw Exception('Error loading provinces: $e');
    }
  }

  static Future<List<Regency>> getRegencies(String provinceId) async {
    try {
      final response =
          await http.get(Uri.parse('$baseUrl/regencies/$provinceId.json'));

      if (response.statusCode == 200) {
        final List<dynamic> data = json.decode(response.body);
        return data.map((json) => Regency.fromJson(json)).toList();
      } else {
        throw Exception('Failed to load regencies');
      }
    } catch (e) {
      throw Exception('Error loading regencies: $e');
    }
  }

  static Future<List<District>> getDistricts(String regencyId) async {
    try {
      final response =
          await http.get(Uri.parse('$baseUrl/districts/$regencyId.json'));

      if (response.statusCode == 200) {
        final List<dynamic> data = json.decode(response.body);
        return data.map((json) => District.fromJson(json)).toList();
      } else {
        throw Exception('Failed to load districts');
      }
    } catch (e) {
      throw Exception('Error loading districts: $e');
    }
  }

  static Future<List<Village>> getVillages(String districtId) async {
    try {
      final response =
          await http.get(Uri.parse('$baseUrl/villages/$districtId.json'));

      if (response.statusCode == 200) {
        final List<dynamic> data = json.decode(response.body);
        return data.map((json) => Village.fromJson(json)).toList();
      } else {
        throw Exception('Failed to load villages');
      }
    } catch (e) {
      throw Exception('Error loading villages: $e');
    }
  }
}
