import 'dart:convert';

import 'package:equatable/equatable.dart';
import 'package:hive/hive.dart';

part 'currency_model.g.dart';

List<CurrencyModel> currencyFromJson(String str) => List<CurrencyModel>.from(
    json.decode(str).map((e) => CurrencyModel.fromJson(e)));

@HiveType(typeId: 12)
// ignore: must_be_immutable
class CurrencyModel extends Equatable {
  @HiveField(0)
  String symbol;
  @HiveField(1)
  String code;
  @HiveField(2)
  String name;

  CurrencyModel({
    this.symbol = "",
    this.code = "",
    this.name = "",
  });

  factory CurrencyModel.fromJson(Map<String, dynamic> json) {
    return CurrencyModel(
      symbol: json['symbol'] ?? 0,
      code: json['code'] ?? "",
      name: json['name'] ?? "",
    );
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = <String, dynamic>{};
    data['symbol'] = symbol;
    data['code'] = code;
    data['name'] = name;
    return data;
  }

  @override
  List<Object?> get props => [code];
}
