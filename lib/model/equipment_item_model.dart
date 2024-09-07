import 'package:equatable/equatable.dart';
import 'package:hive/hive.dart';

part 'equipment_item_model.g.dart';

@HiveType(typeId: 1) // Ensure this typeId is unique in your Hive configuration
class EquipmentItem extends Equatable {
  @HiveField(0)
  final int id;

  @HiveField(1)
  final String equipmentId;

  @HiveField(2)
  final String classType;

  @HiveField(3)
  final String location;

  @HiveField(4)
  final String description;

  @HiveField(5)
  final String serialNo;

  @HiveField(6)
  final String voltage;

  @HiveField(7)
  final String rating;

  @HiveField(8)
  final String fuse;

  @HiveField(9)
  final String inspectionFrequency;

  EquipmentItem({
    this.id = 0,
    this.equipmentId = "",
    this.classType = "",
    this.location = "",
    this.description = "",
    this.serialNo = "",
    this.voltage = "",
    this.rating = "",
    this.fuse = "",
    this.inspectionFrequency = "",
  });

  factory EquipmentItem.fromJson(Map<String, dynamic> json) {
    return EquipmentItem(
      id: json['id'] ?? 0,
      equipmentId: json['equipmentId'] ?? "",
      classType: json['classType'] ?? "",
      location: json['location'] ?? "",
      description: json['description'] ?? "",
      serialNo: json['serialNo'] ?? "",
      voltage: json['voltage'] ?? "",
      rating: json['rating'] ?? "",
      fuse: json['fuse'] ?? "",
      inspectionFrequency: json['inspectionFrequency'] ?? "",
    );
  }

  EquipmentItem copyWith({
    int? id,
    String? equipmentId,
    String? classType,
    String? location,
    String? description,
    String? serialNo,
    String? voltage,
    String? rating,
    String? fuse,
    String? inspectionFrequency,
  }) {
    return EquipmentItem(
      id: id ?? this.id,
      equipmentId: equipmentId ?? this.equipmentId,
      classType: classType ?? this.classType,
      location: location ?? this.location,
      description: description ?? this.description,
      serialNo: serialNo ?? this.serialNo,
      voltage: voltage ?? this.voltage,
      rating: rating ?? this.rating,
      fuse: fuse ?? this.fuse,
      inspectionFrequency: inspectionFrequency ?? this.inspectionFrequency,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'equipmentId': equipmentId,
      'classType': classType,
      'location': location,
      'description': description,
      'serialNo': serialNo,
      'voltage': voltage,
      'rating': rating,
      'fuse': fuse,
      'inspectionFrequency': inspectionFrequency,
    };
  }

  @override
  List<Object?> get props => [
        id,
        equipmentId,
        classType,
        location,
        description,
        serialNo,
        voltage,
        rating,
        fuse,
        inspectionFrequency,
      ];
}
