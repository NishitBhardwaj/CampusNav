/// CampusNav - Data Version Entity
///
/// PHASE 5: Data versioning for integrity and trust.

import 'package:hive/hive.dart';

part 'data_version.g.dart';

@HiveType(typeId: 9)
class DataVersion extends HiveObject {
  @HiveField(0)
  String id;
  
  @HiveField(1)
  int versionNumber;
  
  @HiveField(2)
  String datasetName; // 'rooms', 'personnel', 'navigation_graph', etc.
  
  @HiveField(3)
  DateTime lastUpdated;
  
  @HiveField(4)
  String updatedBy; // Admin username or 'System'
  
  @HiveField(5)
  String? changeDescription;
  
  @HiveField(6)
  int recordCount; // Number of records in dataset
  
  DataVersion({
    required this.id,
    required this.versionNumber,
    required this.datasetName,
    DateTime? lastUpdated,
    this.updatedBy = 'System',
    this.changeDescription,
    this.recordCount = 0,
  }) : lastUpdated = lastUpdated ?? DateTime.now();
  
  DataVersion copyWith({
    int? versionNumber,
    DateTime? lastUpdated,
    String? updatedBy,
    String? changeDescription,
    int? recordCount,
  }) {
    return DataVersion(
      id: id,
      versionNumber: versionNumber ?? this.versionNumber,
      datasetName: datasetName,
      lastUpdated: lastUpdated ?? DateTime.now(),
      updatedBy: updatedBy ?? this.updatedBy,
      changeDescription: changeDescription ?? this.changeDescription,
      recordCount: recordCount ?? this.recordCount,
    );
  }
  
  String getFormattedLastUpdated() {
    final day = lastUpdated.day.toString().padLeft(2, '0');
    final month = lastUpdated.month.toString().padLeft(2, '0');
    final year = lastUpdated.year;
    final hour = lastUpdated.hour.toString().padLeft(2, '0');
    final minute = lastUpdated.minute.toString().padLeft(2, '0');
    
    return '$day/$month/$year @ $hour:$minute';
  }
  
  @override
  String toString() => 'DataVersion($datasetName v$versionNumber)';
}
