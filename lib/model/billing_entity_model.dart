import 'package:hive/hive.dart';

part 'billing_entity_model.g.dart';

@HiveType(typeId:6)
class BillingEntityProfiles {
  @HiveField(0)
  final int id;
  @HiveField(1)
  final String name;
  @HiveField(2)
  final String email;
  @HiveField(3)
  final String logoURL;
  @HiveField(4)
  final bool isDeleted;

  const BillingEntityProfiles({
    this.id = 0,
    this.name = "",
    this.email = "",
    this.logoURL = "",
    this.isDeleted = false,
  });

  static BillingEntityProfiles fromJson(Map<String, dynamic> json) {
    return BillingEntityProfiles(
      id: json['id'] ?? 0,
      name: json['name'] ?? "",
      email: json['email'] ?? "",
      logoURL: json['logoURL'] ?? "",
      isDeleted: json['isDeleted'] ?? false,
    );
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = <String, dynamic>{};
    data['id'] = id;
    data['name'] = name;
    data['email'] = email;
    data['logoURL'] = logoURL;
    data['isDeleted'] = isDeleted;
    return data;
  }
}
