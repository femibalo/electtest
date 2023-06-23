class ClientInvoiceModel {
  final ClientInvoiceData data;

  const ClientInvoiceModel({
    this.data = const ClientInvoiceData(),
  });

  static ClientInvoiceModel fromJson(Map<String, dynamic> json) {
    return ClientInvoiceModel(
      data: json['data'] == null
          ? const ClientInvoiceData()
          : ClientInvoiceData.fromJson(json['data']),
    );
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = Map<String, dynamic>();
    data['data'] = this.data.toJson();
    return data;
  }
}

class ClientInvoiceData {
  final List<UserClientInvoice> userClients;
  final bool hasNext;

  const ClientInvoiceData({
    this.userClients = const [],
    this.hasNext = false,
  });

  static ClientInvoiceData fromJson(Map<String, dynamic> json) {
    List<UserClientInvoice> userClients = [];
    if (json['userClients'] == null) {
      userClients = [];
    } else {
      json['userClients'].forEach((v) {
        userClients.add(UserClientInvoice.fromJson(v));
      });
    }
    return ClientInvoiceData(
      hasNext: json['hasNext'] ?? false,
      userClients: userClients,
    );
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = Map<String, dynamic>();
    data['userClients'] = userClients.map((v) => v.toJson()).toList();

    data['hasNext'] = hasNext;
    return data;
  }
}

class UserClientInvoice {
  final int id;
  final String name;
  final String phone;
  final String email;
  final String billingAddress;
  final String city;
  final String state;
  final String pinCode;
  final String billingPhoneNumber;
  final String displayName;
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
    final Map<String, dynamic> data = Map<String, dynamic>();
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
