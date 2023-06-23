
class ClientRequestData {
  int id;
  String name;
  String email;
  String phone;
  String billingAddress;
  String city;
  String state;
  String pinCode;
  String billingPhoneNumber;
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
