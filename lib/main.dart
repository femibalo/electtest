import 'package:flutter/material.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:invoice_management/ui/invoice_screen.dart';
import 'package:provider/provider.dart';
import 'package:invoice_management/api/invoice_api.dart';
import 'package:invoice_management/api/billing_entity_api.dart';
import 'package:invoice_management/api/client_api.dart';
import 'package:invoice_management/api/invoice_charge_api.dart';
import 'package:invoice_management/api/item_api.dart';

import 'generated/l10n.dart';

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
        title: 'Invoice Management',
        localizationsDelegates: const [
          S.delegate,
          GlobalMaterialLocalizations.delegate,
          GlobalWidgetsLocalizations.delegate,
          GlobalCupertinoLocalizations.delegate,
        ],
        supportedLocales: S.delegate.supportedLocales,
        theme: ThemeData(
          colorScheme: ColorScheme.fromSeed(
            seedColor: Colors.blue,
          ),
          textTheme: GoogleFonts.lateefTextTheme(),
          appBarTheme: AppBarTheme(
              color: Colors.blue,
              iconTheme: const IconThemeData(color: Colors.white),
              titleTextStyle: Theme.of(context)
                  .textTheme
                  .titleLarge
                  ?.copyWith(color: Colors.white),
              centerTitle: true),
          useMaterial3: true,
        ),
        home: const InvoicesScreen(),
      ),
    );
  }
}
