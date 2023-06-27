import 'package:hive/hive.dart';

part 'currency_model.g.dart';

@HiveType(typeId: 12)
class CurrencyModel {
  @HiveField(0)
  int id;
  @HiveField(1)
  String code;
  @HiveField(2)
  String name;

  CurrencyModel({
    this.id = 0,
    this.code = "",
    this.name = "",
  });

  CurrencyModel fromJson(Map<String, dynamic> json) {
    return CurrencyModel(
      id: json['id'] ?? 0,
      code: json['code'] ?? "",
      name: json['name'] ?? "",
    );
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = <String, dynamic>{};
    data['id'] = id;
    data['code'] = code;
    data['name'] = name;
    return data;
  }
}
