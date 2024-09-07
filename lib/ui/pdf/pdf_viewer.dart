import 'dart:io';
import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:share_plus/share_plus.dart';
import 'package:syncfusion_flutter_pdfviewer/pdfviewer.dart';

import '../components/button.dart';

class PDFScreen extends StatefulWidget {
  final File file;

  const PDFScreen({super.key, required this.file});

  @override
  PDFScreenState createState() => PDFScreenState();
}

class PDFScreenState extends State<PDFScreen> with WidgetsBindingObserver {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text("invoice_viewer".tr()),
      ),
      body: Column(
        children: [
          Expanded(child: SfPdfViewer.file(widget.file)),
          ButtonInvoiceDetail(
            onTap: () async {
              await Share.shareXFiles([XFile(widget.file.path)], text: '');
            },
            iconAsset: "assets/images/share_blue.png",
            textButton: "share".tr(),
          ),
        ],
      ),
    );
  }
}
