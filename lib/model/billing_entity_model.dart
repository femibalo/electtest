class BillingEntityProfiles {
  final int id;
  final String name;
  final String email;
  final String logoURL;
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
