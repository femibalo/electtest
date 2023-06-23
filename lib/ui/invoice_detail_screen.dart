import 'package:auto_route/auto_route.dart';
import 'package:flutter/material.dart';
import 'package:flutter_webview_pro/webview_flutter.dart';
import 'package:mezink_app/components/Buttons/loadingElevatedButton.dart';
import 'package:mezink_app/components/error_screens.dart';
import 'package:mezink_app/generated/l10n.dart';
import 'package:mezink_app/material_components/appbar/app_bar.dart';
import 'package:mezink_app/material_components/cards/elevated_card.dart';
import 'package:mezink_app/material_components/extensions/context_extensions.dart';
import 'package:mezink_app/utils/common/api_path.dart';
import 'package:mezink_app/utils/common/app_keys.dart';
import 'package:mezink_app/utils/common/environment.dart';
import 'package:mezink_app/utils/common/snack_bar.dart';
import 'package:mezink_app/utils/common/utils.dart';
import 'package:provider/provider.dart';
import 'package:share_plus/share_plus.dart';
import 'package:url_launcher/url_launcher.dart';

import '../api/invoice_api.dart';
import '../model/invoice_list_model.dart';
import 'components/button.dart';
import 'package:mezink_app/styles/progress_indicator.dart';

class InvoiceDetailScreen extends StatefulWidget {
  final Invoices invoices;
  const InvoiceDetailScreen({
    Key? key,
    required this.invoices,
  }) : super(key: key);

  static const String id = "invoiceDetail";
  static void launchScreen(BuildContext context) {
    context.router.pushNamed(id);
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
    WidgetsBinding.instance.addPostFrameCallback((_) async {
      provider.getDetailInvoice(invoiceID: widget.invoices.id);
    });
  }

  refreshData() {
    setState(() {
      provider.state.isError = false;
      provider.state.isNetworkError = false;
    });
    provider.getDetailInvoice(invoiceID: widget.invoices.id);
  }

  @override
  void dispose() {
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final provider = Provider.of<InvoicesProvider>(context);
    return Scaffold(
      backgroundColor: context.backgroundColor,
      appBar: MAppBar(
        title: S.current.invoice_details,
      ),
      bottomNavigationBar: buildButtonSendInvoice(),
      body: _getWidgetBasedOnState(provider.state),
    );
  }

  Widget _getWidgetBasedOnState(InvoicesProviderState state) {
    if (state.loading) {
      return const Center(
        child: AdaptiveProgressIndicator(),
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

    children.add(MElevatedCard(
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: 10, horizontal: 10),
        height: MediaQuery.of(context).size.height * 0.45,
        child: AbsorbPointer(
          child: WebView(
            initialUrl:
                '${Environment().config.apiUrl}/inv/data/${widget.invoices.paymentIdentifier}?showPreview=1',
            javascriptMode: JavascriptMode.unrestricted,
          ),
        ),
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
                String url =
                    "${Environment().config.apiUrl}${APIPaths.downloadInvoicePath}?${MConstants.paymentIdentifier}=${widget.invoices.paymentIdentifier}";
                await launchUrl(
                  Uri.parse(url),
                  mode: LaunchMode.externalApplication,
                );
              },
              iconAsset: "assets/images/download_blue.png",
              textButton: S.current.download_pdf,
            ),
            ButtonInvoiceDetail(
              onTap: () {
                String content =
                    "${S.current.payment_link}\nInvoice ID : ${provider.state.detailInvoiceForEdit.invoiceID}\n==========\n${provider.state.detailInvoiceForEdit.paymentLink}";
                Share.share(
                  content,
                );
              },
              iconAsset: "assets/images/share_blue.png",
              textButton: S.current.share_payment_link,
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
        children: children,
        physics: customScrollPhysics(alwaysScroll: true),
      ),
    );
  }

  Widget buildButtonSendInvoice() {
    return Visibility(
      visible: widget.invoices.status == 4 ? false : true,
      child: Container(
        height: 82,
        decoration:  BoxDecoration(
          border: Border(
            top: BorderSide(
              color: context.outlineColor,
            ),
          ),
        ),
        child: Center(
          child: LoadingElevatedButton(
            text: S.current.send_invoice,
            onPressed: () async {
              setState(() {
                provider.state.loading = true;
              });
              provider
                  .sendInvoiceReminder(widget.invoices.paymentIdentifier)
                  .then((value) {
                if (value) {
                  showSnackBar(
                    context: context,
                    text: S.current.send_invoice_reminder_success,
                    snackBarType: SnackBarType.success,
                  );
                } else {
                  showSnackBar(
                    context: context,
                    text: S.current.send_invoice_reminder_failed,
                    snackBarType: SnackBarType.error,
                  );
                }
              }).whenComplete(() {
                setState(() {
                  provider.state.loading = false;
                });
              });
            },
            expanded: true,
            showLoading: provider.state.loading,
          ),
        ),
      ),
    );
  }
}
