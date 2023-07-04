import 'package:flutter/material.dart';
import 'package:invoice_management/ui/invoice_screen.dart';
import 'package:provider/provider.dart';
import 'package:invoice_management/api/invoice_api.dart';
import 'package:invoice_management/api/billing_entity_api.dart';
import 'package:invoice_management/api/client_api.dart';
import 'package:invoice_management/api/invoice_charge_api.dart';
import 'package:invoice_management/api/item_api.dart';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MultiProvider(
      providers: [
        ChangeNotifierProvider(create: (_) => InvoiceItemProvider()),
        ChangeNotifierProvider(create: (_) => InvoiceChargeProvider()),
        ChangeNotifierProvider(create: (_) => BillingEntityProvider()),
        ChangeNotifierProvider(create: (_) => ClientInvoiceProvider()),
        ChangeNotifierProvider(create: (_) => InvoicesProvider()),
        ChangeNotifierProvider(create: (_) => InvoicesProvider()),
      ],
      child: MaterialApp(
        title: 'Flutter Demo',
        theme: ThemeData(
          colorScheme: ColorScheme.fromSeed(seedColor: Colors.blue,),
          appBarTheme: const AppBarTheme(color: Colors.blue,titleTextStyle: TextStyle(color: Colors.white)),
          useMaterial3: true,
        ),
        home: const InvoicesScreen(),
      ),
    );
  }
}

