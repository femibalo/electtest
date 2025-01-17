import 'package:hive/hive.dart';

part 'client_invoice_model.g.dart';

@HiveType(typeId:7)
class UserClientInvoice {
  @HiveField(0)
  final int id;
  @HiveField(1)
  final String name;
  @HiveField(2)
  final String phone;
  @HiveField(3)
  final String email;
  @HiveField(4)
  final String billingAddress;
  @HiveField(5)
  final String city;
  @HiveField(6)
  final String state;
  @HiveField(7)
  final String pinCode;
  @HiveField(8)
  final String billingPhoneNumber;
  @HiveField(9)
  final String displayName;
  @HiveField(10)
  final bool isDeleted;

  const UserClientInvoice({
    this.id = 0,
    this.name = "",
    this.phone = "",
    this.email = "",
    this.billingAddress = "",
    this.city = "",
    this.state = "",
    this.pinCode = "",
    this.billingPhoneNumber = "",
    this.displayName = "",
    this.isDeleted = false,
  });

  static UserClientInvoice fromJson(Map<String, dynamic> json) {
    return UserClientInvoice(
      id: json['id'] ?? 0,
      name: json['name'] ?? "",
      phone: json['phone'] ?? "",
      email: json['email'] ?? "",
      billingAddress: json['billingAddress'] ?? "",
      city: json['city'] ?? "",
      state: json['state'] ?? "",
      pinCode: json['pinCode'] ?? "",
      billingPhoneNumber: json['billingPhoneNumber'] ?? "",
      displayName: json['displayName'] ?? "",
      isDeleted: json['isDeleted'] ?? false,
    );
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = <String, dynamic>{};
    data['id'] = id;
    data['name'] = name;
    data['phone'] = phone;
    data['email'] = email;
    data['billingAddress'] = billingAddress;
    data['city'] = city;
    data['state'] = state;
    data['pinCode'] = pinCode;
    data['billingPhoneNumber'] = billingPhoneNumber;
    data['displayName'] = displayName;
    data['isDeleted'] = isDeleted;
    return data;
  }
}
