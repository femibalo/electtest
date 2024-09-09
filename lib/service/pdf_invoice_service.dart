import 'dart:io';
import 'package:invoice_management/service/pdf_service.dart';
import 'package:pdf/pdf.dart';
import 'package:pdf/widgets.dart' as pw;
import 'package:pdf/widgets.dart';

import '../model/customer.dart';
import '../model/invoice.dart';
import '../model/supplier.dart';
import '../utils/utils.dart';

class PdfInvoiceApi {
  static Future<File> generate(Invoice invoice) async {
    final pdf = Document();

    pdf.addPage(MultiPage(
      build: (context) => [
        buildHeader(invoice),
        SizedBox(height: 3 * PdfPageFormat.cm),
        buildTitle(invoice),
        buildInvoice(invoice),
        Divider(),
        // buildTotal(invoice),
      ],
      footer: (context) => buildFooter(invoice),
    ));

    return PdfApi.saveDocument(name: 'my_invoice.pdf', pdf: pdf);
  }

  static Widget buildHeader(Invoice invoice) => Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SizedBox(height: 1 * PdfPageFormat.cm),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              buildSupplierAddress(invoice.supplier),
              Container(
                height: 50,
                width: 50,
                child: invoice.supplier.logoURL.isNotEmpty
                    ? Image(
                        MemoryImage(
                          // Assuming you have the image data as bytes (e.g. from an API or file)
                          File(invoice.supplier.logoURL).readAsBytesSync(),
                        ),
                        fit: BoxFit.cover,
                      )
                    : SizedBox.shrink(), // Handle case when logoURL is empty
              ),
            ],
          ),
          SizedBox(height: 1 * PdfPageFormat.cm),
          Row(
            crossAxisAlignment: CrossAxisAlignment.end,
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              buildCustomerAddress(invoice.customer),
              // buildInvoiceInfo(invoice.info),
            ],
          ),
        ],
      );

  static Widget buildCustomerAddress(Customer customer) => Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(customer.name, style: TextStyle(fontWeight: FontWeight.bold)),
          Text(customer.address),
        ],
      );

  static Widget buildInvoiceInfo(InvoiceInfo info) {
    final paymentTerms = '${info.dueDate.difference(info.date).inDays} days';
    final titles = <String>[
      'Invoice Number:',
      'Invoice Date:',
      'Payment Terms:',
      'Due Date:'
    ];
    final data = <String>[
      info.number,
      formatDate(info.date),
      paymentTerms,
      formatDate(info.dueDate),
    ];

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: List.generate(titles.length, (index) {
        final title = titles[index];
        final value = data[index];

        return buildText(title: title, value: value, width: 200);
      }),
    );
  }

  static Widget buildSupplierAddress(Supplier supplier) => Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(supplier.name, style: TextStyle(fontWeight: FontWeight.bold)),
          SizedBox(height: 1 * PdfPageFormat.mm),
          Text(supplier.address),
        ],
      );

  static Widget buildTitle(Invoice invoice) => Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Equipment register',
            style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
          ),
          SizedBox(height: 0.8 * PdfPageFormat.cm),
          Text(invoice.info.description),
          SizedBox(height: 0.8 * PdfPageFormat.cm),
        ],
      );

  static Widget buildInvoice(Invoice invoice) {
    final headers = [
      // 'Description',
      // 'Date',
      // 'Quantity',
      // 'Unit Price',
      // 'VAT',
      // 'Total'

      " Equipment ID no.",
      "Location",
      "Equipment description",
      "Serial No.",
      "Formal Visual inspection by occupant",
      "Combined Inspection by assessor",
      "Pass/Fail",
      "Suitable for Env",
      "Suitable for continued use",
      "Comments",
    ];
    final data = invoice.items.map((item) {
      // final total = item.unitPrice * item.quantity;

      return [
        item.EquipmentIDNumber,
        item.Location,
        item.description,
        item.SerialNo,
        "Formal Visual inspection by occupant",
        "Combined Inspection by assessor",
        item.SuitableForContinuedUse,
        "Suitable for Env",
        "Suitable for continued use",
        "Comments"
        // item.description,
        // formatDate(item.date),
        // '${item.quantity}',
        // '\$ ${item.unitPrice}',
        // '${item.vat} %',
        // '\$ ${total.toStringAsFixed(2)}',
      ];
    }).toList();

    // ignore: deprecated_member_use
    return Table.fromTextArray(
      headers: headers,
      data: data,
      border: null,
      headerStyle: TextStyle(fontWeight: FontWeight.bold),
      headerDecoration: const BoxDecoration(color: PdfColors.grey300),
      cellHeight: 30,
      cellAlignments: {
        0: Alignment.centerLeft,
        1: Alignment.centerRight,
        2: Alignment.centerRight,
        3: Alignment.centerRight,
        4: Alignment.centerRight,
        5: Alignment.centerRight,
      },
    );
  }

  // static Widget buildTotal(Invoice invoice) {
  //   double total = 0.0;
  //   double netTotal = 0.0;
  //   double discount = 0.0;
  //   double tax = 0.0;
  //   double discountPercent = 0.0;
  //   double taxPercent = 0.0;
  //   invoice.items.map((item) {
  //     netTotal += (item.quantity * item.unitPrice);
  //     discount += (item.discount / 100) * netTotal;
  //     tax += (item.vat / 100) * (netTotal - discount);
  //     discountPercent += item.discount;
  //     taxPercent += item.vat;
  //   }).toList();

  //   total = netTotal + tax - discount;

  //   return Container(
  //     alignment: Alignment.centerRight,
  //     child: Row(
  //       children: [
  //         Spacer(flex: 6),
  //         Expanded(
  //           flex: 4,
  //           child: Column(
  //             crossAxisAlignment: CrossAxisAlignment.start,
  //             children: [
  //               buildText(
  //                 title: 'Net total',
  //                 value: formatPrice(netTotal),
  //                 unite: true,
  //               ),
  //               buildText(
  //                 title: 'Vat $taxPercent %',
  //                 value: formatPrice(tax),
  //                 unite: true,
  //               ),
  //               buildText(
  //                 title: 'Discount $discountPercent %',
  //                 value: formatPrice(discount),
  //                 unite: true,
  //               ),
  //               Divider(),
  //               buildText(
  //                 title: 'Total amount due',
  //                 titleStyle: TextStyle(
  //                   fontSize: 14,
  //                   fontWeight: FontWeight.bold,
  //                 ),
  //                 value: formatPrice(total),
  //                 unite: true,
  //               ),
  //               SizedBox(height: 2 * PdfPageFormat.mm),
  //               Container(height: 1, color: PdfColors.grey400),
  //               SizedBox(height: 0.5 * PdfPageFormat.mm),
  //               Container(height: 1, color: PdfColors.grey400),
  //             ],
  //           ),
  //         ),
  //       ],
  //     ),
  //   );
  // }

  static Widget buildFooter(Invoice invoice) => Column(
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          Divider(),
          SizedBox(height: 2 * PdfPageFormat.mm),
          buildSimpleText(title: 'Address', value: invoice.supplier.address),
          SizedBox(height: 1 * PdfPageFormat.mm),
          // buildSimpleText(title: 'Paypal', value: invoice.supplier.paymentInfo),
        ],
      );

  static buildSimpleText({
    required String title,
    required String value,
  }) {
    final style = TextStyle(fontWeight: FontWeight.bold);

    return Row(
      mainAxisSize: MainAxisSize.min,
      crossAxisAlignment: pw.CrossAxisAlignment.end,
      children: [
        Text(title, style: style),
        SizedBox(width: 2 * PdfPageFormat.mm),
        Text(value),
      ],
    );
  }

  static buildText({
    required String title,
    required String value,
    double width = double.infinity,
    TextStyle? titleStyle,
    bool unite = false,
  }) {
    final style = titleStyle ?? TextStyle(fontWeight: FontWeight.bold);

    return Container(
      width: width,
      child: Row(
        children: [
          Expanded(child: Text(title, style: style)),
          Text(value, style: unite ? style : null),
        ],
      ),
    );
  }
}
