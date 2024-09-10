import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:invoice_management/ui/pdf/pdf_view.dart';
import 'package:provider/provider.dart';
import '../api/invoice_api.dart';
import '../model/invoice_list_model.dart';
import '../utils/utils.dart';
import 'components/error_screens.dart';

class InvoiceDetailScreen extends StatefulWidget {
  final Invoices invoices;

  const InvoiceDetailScreen({super.key, required this.invoices});

  static void launchScreen(BuildContext context) {}

  @override
  State<InvoiceDetailScreen> createState() => _InvoiceDetailScreenState();
}

class _InvoiceDetailScreenState extends State<InvoiceDetailScreen> {
  late InvoicesProvider provider;

  @override
  void initState() {
    super.initState();
    provider = Provider.of<InvoicesProvider>(context, listen: false);
  }

  refreshData() {
    setState(() {
      provider.state.isError = false;
      provider.state.isNetworkError = false;
    });
  }

  @override
  void dispose() {
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final provider = Provider.of<InvoicesProvider>(context);
    return Scaffold(
      appBar: AppBar(
        title: Text('Register Generating...'.tr()),
      ),
      body: _getWidgetBasedOnState(provider.state, widget.invoices),
    );
  }

  Widget _getWidgetBasedOnState(
      InvoicesProviderState state, Invoices invoices) {
    if (state.loading) {
      return const Center(
        child: CircularProgressIndicator(),
      );
    }
    if (state.isNetworkError) {
      return NetworkErrorWidget(onRefresh: () {
        refreshData();
      });
    }

    if (state.isError) {
      return GenericErrorWidget(onRefresh: () {
        refreshData();
      });
    }

    return _successContent(state, invoices);
  }

  Widget _successContent(InvoicesProviderState state, Invoices invoices) {
    List<Widget> children = [];
    children.add(SizedBox(
        height: 500,
        width: 200.0,
        child: PDFViewWrapper(
          invoices: invoices,
        )));

    return RefreshIndicator(
      onRefresh: () async {
        refreshData();
      },
      child: ListView(
        padding: EdgeInsets.only(
          left: 20,
          right: 20,
          bottom: MediaQuery.of(context).size.height * 0.1,
        ),
        physics: customScrollPhysics(alwaysScroll: true),
        children: children,
      ),
    );
  }
}
