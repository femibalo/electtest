import 'package:flutter/material.dart';
import 'package:invoice_management/model/invoice_list_model.dart';
import 'package:invoice_management/ui/pdf/pdf_viewer.dart';
import '../../service/pdf_invoice_service.dart';
import '../../model/customer.dart';
import '../../model/invoice.dart';
import '../../model/supplier.dart';
import '../../utils/utils.dart';

class PDFViewWrapper extends StatefulWidget {
  final Invoices invoices;

  const PDFViewWrapper({super.key, required this.invoices});

  @override
  PDFViewWrapperState createState() => PDFViewWrapperState();
}

class PDFViewWrapperState extends State<PDFViewWrapper> {
  late DateTime date;
  late DateTime dueDate;

  @override
  void initState() {
    date = widget.invoices.invoiceDate.isNotEmpty
        ? getDateFromString(widget.invoices.invoiceDate)
        : DateTime.now();
    dueDate = widget.invoices.dueDate.isNotEmpty
        ? getDateFromString(widget.invoices.dueDate)
        : date.add(const Duration(days: 7));
    initializePDfView();
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(32),
      child: const Center(
        child: CircularProgressIndicator(),
      ),
    );
  }

  void initializePDfView() async {
    final invoice = Invoice(
        supplier: Supplier(
          name: widget.invoices.profileName,
          address: widget.invoices.profileEmail,
          logoURL: widget.invoices.logoURL,
        ),
        customer: Customer(
          name: widget.invoices.clientName,
          address: widget.invoices.clientAddress,
        ),
        info: InvoiceInfo(
          date: date,
          dueDate: dueDate,
          description: widget.invoices.description,
          number: '${widget.invoices.id}',
        ),
        items: widget.invoices.items
            .map(
              (e) => UserBillProductItem(
                  // description: e.name,
                  // date: DateTime.now(),
                  // quantity: e.qty,
                  // vat: e.taxPercent.ceilToDouble(),
                  // discount: e.discountPercent.ceilToDouble(),
                  // unitPrice: e.price.ceilToDouble(),
                  EquipmentIDNumber: e.equipmentId,
                  Location: e.location,
                  description: e.description,
                  SerialNo: 34,
                  FormalVisualInspectionByOccupant: "Formal visual inspection",
                  CombinedInspectionByAssessor: "Combined visual inspection",
                  PassFail: "Pass fail",
                  SuitableForEnv: "suitable for environment",
                  SuitableForContinuedUse: "suitable for continuous use",
                  Comments: "comments"),
            )
            .toList()
        // items: [
        //   InvoiceItem(
        //     description: 'Coffee',
        //     date: DateTime.now(),
        //     quantity: 3,
        //     vat: 0.19,
        //     unitPrice: 5.99,
        //   ),
        //   InvoiceItem(
        //     description: 'Water',
        //     date: DateTime.now(),
        //     quantity: 8,
        //     vat: 0.19,
        //     unitPrice: 0.99,
        //   ),
        //   InvoiceItem(
        //     description: 'Orange',
        //     date: DateTime.now(),
        //     quantity: 3,
        //     vat: 0.19,
        //     unitPrice: 2.99,
        //   ),
        //   InvoiceItem(
        //     description: 'Apple',
        //     date: DateTime.now(),
        //     quantity: 8,
        //     vat: 0.19,
        //     unitPrice: 3.99,
        //   ),
        //   InvoiceItem(
        //     description: 'Mango',
        //     date: DateTime.now(),
        //     quantity: 1,
        //     vat: 0.19,
        //     unitPrice: 1.59,
        //   ),
        //   InvoiceItem(
        //     description: 'Blue Berries',
        //     date: DateTime.now(),
        //     quantity: 5,
        //     vat: 0.19,
        //     unitPrice: 0.99,
        //   ),
        //   InvoiceItem(
        //     description: 'Lemon',
        //     date: DateTime.now(),
        //     quantity: 4,
        //     vat: 0.19,
        //     unitPrice: 1.29,
        //   ),
        // ],
        );

    await PdfInvoiceApi.generate(invoice).then((pdfFile) {
      Future.delayed(const Duration(milliseconds: 1500), () {
        Navigator.pushReplacement(
          context,
          MaterialPageRoute(
            builder: (context) => PDFScreen(file: pdfFile),
          ),
        );
      });
    });
  }
}
