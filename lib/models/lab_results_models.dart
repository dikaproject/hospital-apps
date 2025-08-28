import 'family_models.dart';

enum LabTestType {
  bloodTest,
  bloodSugar,
  lipidProfile,
  immunology,
  urine,
  other,
}

enum LabResultStatus {
  pending,
  ready,
  reviewed,
}

enum LabItemStatus {
  normal,
  high,
  low,
  critical,
}

class FamilyLabResult {
  final String id;
  final String memberName;
  final FamilyRelation memberRelation;
  final DateTime testDate;
  final DateTime resultDate;
  final String hospital;
  final String doctorName;
  final LabTestType testType;
  final String testName;
  final LabResultStatus status;
  bool isNew;
  final List<LabTestItem> results;
  final String notes;

  FamilyLabResult({
    required this.id,
    required this.memberName,
    required this.memberRelation,
    required this.testDate,
    required this.resultDate,
    required this.hospital,
    required this.doctorName,
    required this.testType,
    required this.testName,
    required this.status,
    this.isNew = false,
    required this.results,
    this.notes = '',
  });
}

class LabTestItem {
  final String name;
  final String value;
  final String unit;
  final String normalRange;
  final LabItemStatus status;

  LabTestItem({
    required this.name,
    required this.value,
    required this.unit,
    required this.normalRange,
    required this.status,
  });
}
