import 'dart:isolate';
import 'package:flutter/services.dart';
import 'package:invoice_management/model/currency_model.dart';

final currenciesReceivePort = ReceivePort();

Future<void> currencyIsolate() async {

  final token = ServicesBinding.rootIsolateToken;

  await Isolate.spawn((v) async{
    SendPort sendPort = v.last as SendPort;
    BackgroundIsolateBinaryMessenger.ensureInitialized(v[1] as RootIsolateToken);
    final currencyJson = currencyFromJson(v.first as String);
    sendPort.send(currencyJson);
  }, [await rootBundle.loadString('json/currencies.json'),token,currenciesReceivePort.sendPort]);
}
