
class BillingEntityRequestData {
  int id;
  String name;
  String email;
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
