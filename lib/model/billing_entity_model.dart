class BillingEntityModel {
  final BillingEntityData billingEntityData;

  const BillingEntityModel({
    this.billingEntityData = const BillingEntityData(),
  });

  static BillingEntityModel fromJson(Map<String, dynamic> json) {
    return BillingEntityModel(
      billingEntityData: json['data'] == null
          ? const BillingEntityData()
          : BillingEntityData.fromJson(json['data']),
    );
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = Map<String, dynamic>();
    data['data'] = billingEntityData.toJson();
    return data;
  }
}

class BillingEntityData {
  final List<BillingEntityProfiles> profiles;
  final bool hasNext;

  const BillingEntityData({
    this.profiles = const [],
    this.hasNext = false,
  });

  static BillingEntityData fromJson(Map<String, dynamic> json) {
    List<BillingEntityProfiles> profiles = [];
    if (json['profiles'] == null) {
      profiles = [];
    } else {
      json['profiles'].forEach((v) {
        profiles.add(BillingEntityProfiles.fromJson(v));
      });
    }
    return BillingEntityData(
      hasNext: json['hasNext'] ?? false,
      profiles: profiles,
    );
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = Map<String, dynamic>();
    data['profiles'] = profiles.map((v) => v.toJson()).toList();
    data['hasNext'] = hasNext;
    return data;
  }
}

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
    final Map<String, dynamic> data = Map<String, dynamic>();
    data['id'] = id;
    data['name'] = name;
    data['email'] = email;
    data['logoURL'] = logoURL;
    data['isDeleted'] = isDeleted;
    return data;
  }
}
