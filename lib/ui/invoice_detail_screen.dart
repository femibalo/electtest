import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../api/invoice_api.dart';
import '../model/invoice_list_model.dart';
import 'components/button.dart';
import 'components/elevated_card.dart';
import 'components/error_screens.dart';
import 'components/loadingElevatedButton.dart';

class InvoiceDetailScreen extends StatefulWidget {
  final Invoices invoices;
  const InvoiceDetailScreen({
    Key? key,
    required this.invoices,
  }) : super(key: key);

  static void launchScreen(BuildContext context,{required Invoices invoices}) {
   Navigator.of(context).push(MaterialPageRoute(builder: (context) => InvoiceDetailScreen(invoices: invoices,)));
  }

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
        title: const Text('Invoice details'),
      ),
      bottomNavigationBar: buildButtonSendInvoice(),
      body: _getWidgetBasedOnState(provider.state),
    );
  }

  Widget _getWidgetBasedOnState(InvoicesProviderState state) {
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

    return _successContent(state);
  }

  Widget _successContent(InvoicesProviderState state) {
    List<Widget> children = [];
    children.add(
      const SizedBox(
        height: 25,
      ),
    );

    children.add(ElevatedCard(
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: 10, horizontal: 10),
        height: MediaQuery.of(context).size.height * 0.45,
        child: const SizedBox.shrink(),
      ),
    ));

    children.add(
      Container(
        margin: const EdgeInsets.only(top: 10),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            ButtonInvoiceDetail(
              onTap: () async {

              },
              iconAsset: "assets/images/download_blue.png",
              textButton: 'download pdf',
            ),
            ButtonInvoiceDetail(
              onTap: () {

              },
              iconAsset: "assets/images/share_blue.png",
              textButton: 'share payment link',
            ),
          ],
        ),
      ),
    );

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
        physics: const AlwaysScrollableScrollPhysics(),
        children: children,
      ),
    );
  }

  Widget buildButtonSendInvoice() {
    return Visibility(
      visible: widget.invoices.status == 4 ? false : true,
      child: Container(
        height: 82,
        decoration:  const BoxDecoration(
          border: Border(
            top: BorderSide(
              color: Colors.grey,
            ),
          ),
        ),
        child: Center(
          child: LoadingElevatedButton(
            text: 'send invoice',
            onPressed: () async {

            },
            expanded: true,
            showLoading: provider.state.loading,
          ),
        ),
      ),
    );
  }
}
