import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:hive/hive.dart';
import 'package:invoice_management/model/bill_product_item_model.dart';
import 'package:invoice_management/model/billing_entity_model.dart';
import 'package:invoice_management/model/client_invoice_model.dart';
import 'package:invoice_management/model/invoice_charge_model.dart';
import 'package:invoice_management/model/invoice_list_model.dart';
import 'package:invoice_management/ui/invoice_screen.dart';
import 'package:path_provider/path_provider.dart';
import 'package:provider/provider.dart';
import 'package:invoice_management/api/invoice_api.dart';
import 'package:invoice_management/api/billing_entity_api.dart';
import 'package:invoice_management/api/client_api.dart';
import 'package:invoice_management/api/invoice_charge_api.dart';
import 'package:invoice_management/api/item_api.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  final document = await getApplicationDocumentsDirectory();
  Hive.init(document.path);
  Hive.registerAdapter(BillingEntityProfilesAdapter());
  await Hive.openBox<BillingEntityProfiles>(billingEntity);
  Hive.registerAdapter(UserClientInvoiceAdapter());
  await Hive.openBox<UserClientInvoice>(clientInvoice);
  Hive.registerAdapter(UserBillProductItemAdapter());
  await Hive.openBox<UserBillProductItem>(billProductItems);
  Hive.registerAdapter(InvoicesAdapter());
  await Hive.openBox<Invoices>(invoice);
  Hive.registerAdapter(InvoiceChargeModelAdapter());
  await Hive.openBox<InvoiceChargeModel>(billExtraCharge);
  await EasyLocalization.ensureInitialized();
  runApp(EasyLocalization(
      supportedLocales: const [
        Locale('en', 'US'),
        Locale('bn', 'BN'),
        Locale('ar', 'AR')
      ],
      path: 'assets/translations',
      saveLocale: true,
      // assetLoader: CsvAssetLoader(),
      fallbackLocale: const Locale('en', 'US'),
      child: const MyApp()));
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
        title: 'Pat Testing',
        localizationsDelegates: context.localizationDelegates,
        supportedLocales: context.supportedLocales,
        locale: context.locale,
        theme: ThemeData(
          colorScheme: ColorScheme.fromSeed(
            seedColor: Colors.blue,
          ),
          textTheme: GoogleFonts.lateefTextTheme(),
          appBarTheme: AppBarTheme(
              color: Colors.green,
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
