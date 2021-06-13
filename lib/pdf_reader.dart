import 'dart:io';

import 'package:advance_pdf_viewer/advance_pdf_viewer.dart';
import 'package:flutter/material.dart';

import 'model/ebook.dart';

class PDFReader extends StatefulWidget {
  final EBook bookToRead;
  const PDFReader({Key? key, required this.bookToRead}) : super(key: key);

  @override
  _PDFReaderState createState() => _PDFReaderState();
}

class _PDFReaderState extends State<PDFReader> {
  bool _isLoading = true;
  late PDFDocument document;

  @override
  void initState() {
    super.initState();
    getPDFFile();
  }

  Future<void> getPDFFile() async {
    File bookFile = File(widget.bookToRead.pdfPath);
    document = await PDFDocument.fromFile(bookFile);
    setState(() {
      _isLoading = false;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(widget.bookToRead.title),
      ),
      body: Center(
          child: _isLoading
              ? Center(child: CircularProgressIndicator())
              : PDFViewer(document: document)),
    );
  }
}
