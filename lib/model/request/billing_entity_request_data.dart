import 'package:hive/hive.dart';

part 'billing_entity_request_data.g.dart';

@HiveType(typeId: 4)
class BillingEntityRequestData {
  @HiveField(0)
  int id;
  @HiveField(1)
  String name;
  @HiveField(2)
  String email;
  @HiveField(3)
  String logoURL;

  BillingEntityRequestData({
    this.id = 0,
    this.name = "",
    this.email = "",
    this.logoURL = "",
  });

  Map<String, dynamic> toJson() => {
          "id": id,
          "name": name,
          "email": email,
          "logoURL": logoURL,
      };
}
