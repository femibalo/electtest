import 'package:hive/hive.dart';

part 'client_request_data.g.dart';

@HiveType(typeId: 0)
class ClientRequestData {
  @HiveField(0)
  int id;
  @HiveField(1)
  String name;
  @HiveField(2)
  String email;
  @HiveField(3)
  String phone;
  @HiveField(4)
  String billingAddress;
  @HiveField(5)
  String city;
  @HiveField(6)
  String state;
  @HiveField(7)
  String pinCode;
  @HiveField(8)
  String billingPhoneNumber;
  @HiveField(9)
  String displayName;

  ClientRequestData({
    this.id = 0,
    this.name = "",
    this.email = "",
    this.phone = "",
    this.billingAddress = "",
    this.city = "",
    this.state = "",
    this.pinCode = "",
    this.billingPhoneNumber = "",
    this.displayName = "",
  });

  Map<String, dynamic> toJson() => {
          "id": id,
          "name": name,
          "email": email,
          "phone": phone,
          "billingAddress": billingAddress,
          "city": city,
          "state": state,
          "pinCode": pinCode,
          "billingPhoneNumber": billingPhoneNumber,
          "displayName": displayName,
      };
}
