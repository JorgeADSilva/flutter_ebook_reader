import 'dart:convert';
import 'dart:io';

import 'package:advance_pdf_viewer/advance_pdf_viewer.dart';
import 'package:ebookreader/common/shared_preferences.dart';
import 'package:ebookreader/components/ebook_card.dart';
import 'package:ebookreader/model/ebook.dart';
import 'package:epub_viewer/epub_viewer.dart';
import 'package:file_picker/file_picker.dart';
import 'package:flutter/material.dart';

void main() {
  runApp(MyApp());
}

class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'Flutter Demo',
      theme: ThemeData(
        primarySwatch: Colors.blue,
      ),
      home: HomePage(title: 'Flutter Demo Home Page'),
    );
  }
}

class HomePage extends StatefulWidget {
  HomePage({Key? key, required this.title}) : super(key: key);

  final String title;

  @override
  _HomePageState createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  final _formKey = GlobalKey<FormState>();
  List<EBook> booksList = [];

  @override
  void initState() {
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Colors.amber,
        title: Text(
          "Ebook-reader",
          style: TextStyle(color: Colors.black),
        ),
      ),
      body: FutureBuilder<List<EBook>>(
        future: SharedPreferencesHolder.getEBooks(),
        builder: (BuildContext context, AsyncSnapshot<List<EBook>> snapshot) {
          Widget children;
          if (snapshot.hasData) {
            children = Container(
              child: ListView.builder(
                  padding: const EdgeInsets.all(8),
                  itemCount: snapshot.data!.length,
                  itemBuilder: (BuildContext context, int index) {
                    return EbookCard(book: snapshot.data![index]);
                  }),
            );
          } else if (snapshot.hasError) {
            children = Center(
              child: const Icon(
                Icons.error_outline,
                color: Colors.red,
                size: 60,
              ),
            );
          } else {
            children = Center(
              child: SizedBox(
                child: CircularProgressIndicator(),
                width: 60,
                height: 60,
              ),
            );
          }
          return children;
        },
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () async {
          final TextEditingController _bookTitleController =
              TextEditingController();
          final TextEditingController _bookCoverImageLinkController =
              TextEditingController();
          /*await _registerEbookDialog(
              context, _bookTitleController, _bookCoverImageLinkController);*/
          EpubViewer.setConfig(
              themeColor: Theme.of(context).primaryColor,
              identifier: "iosBook",
              scrollDirection: EpubScrollDirection.ALLDIRECTIONS,
              allowSharing: true,
              enableTts: true,
              nightMode: true);
          await EpubViewer.openAsset(
            'assets/4.epub',
          );
          EpubViewer.locatorStream.listen((locator) {
            print('LOCATOR: ${EpubLocator.fromJson(jsonDecode(locator))}');
            // convert locator from string to json and save to your database to be retrieved later
          });
        },
        child: Icon(Icons.add),
        backgroundColor: Colors.amber,
      ),
    );
  }

  _registerEbookDialog(
      BuildContext context,
      TextEditingController _bookTitleController,
      TextEditingController _bookCoverImageLinkController) async {
    late String bookPDFpath;
    showDialog(
        context: context,
        builder: (BuildContext context) {
          return AlertDialog(
            content: Stack(
              clipBehavior: Clip.none,
              children: <Widget>[
                Positioned(
                  right: -40.0,
                  top: -40.0,
                  child: InkResponse(
                    onTap: () {
                      Navigator.of(context).pop();
                    },
                    child: CircleAvatar(
                      child: Icon(Icons.close),
                      backgroundColor: Colors.red,
                    ),
                  ),
                ),
                Form(
                  key: _formKey,
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: <Widget>[
                      Padding(
                        padding: EdgeInsets.all(8.0),
                        child: Text("Book title"),
                      ),
                      Padding(
                        padding: EdgeInsets.all(8.0),
                        child: TextFormField(
                          controller: _bookTitleController,
                        ),
                      ),
                      Padding(
                        padding: EdgeInsets.all(8.0),
                        child: Text("Book Cover (Link)"),
                      ),
                      Padding(
                        padding: EdgeInsets.all(8.0),
                        child: TextFormField(
                          controller: _bookCoverImageLinkController,
                        ),
                      ),
                      Padding(
                        padding: EdgeInsets.all(8.0),
                        child: Text("Book path"),
                      ),
                      Padding(
                        padding: EdgeInsets.all(8.0),
                        child: ElevatedButton(
                          child: Text("Get File path"),
                          onPressed: () async {
                            FilePickerResult? result =
                                await FilePicker.platform.pickFiles();
                            if (result != null) {
                              bookPDFpath = result.files.single.path!;
                              print("object");
                              print("HERE" + bookPDFpath);
                              File bookFile = File(bookPDFpath);
                              PDFDocument doc =
                                  await PDFDocument.fromFile(bookFile);
                              print(doc.count);
                            } else {
                              // User canceled the picker
                            }
                          },
                        ),
                      ),
                      Padding(
                        padding: const EdgeInsets.all(8.0),
                        child: RaisedButton(
                          child: Text("Save book"),
                          onPressed: () async {
                            SharedPreferencesHolder.getEBooks().then((value) {
                              this.booksList = value;
                              print(value);
                            });
                            if (_formKey.currentState!.validate()) {
                              _formKey.currentState!.save();
                              /*final pdfController =
                                      PdfDocument.openAsset(bookPDFpath);*/
                              File bookFile = File(bookPDFpath);
                              PDFDocument doc =
                                  await PDFDocument.fromFile(bookFile);
                              print(doc.count);
                              EBook bookToAdd = EBook(
                                  booksList.length,
                                  _bookTitleController.text,
                                  _bookCoverImageLinkController.text,
                                  doc.count,
                                  0,
                                  bookPDFpath);
                              SharedPreferencesHolder.saveBook(bookToAdd);
                              setState(() {
                                booksList.add(bookToAdd);
                              });
                              Navigator.of(context).pop();
                            }
                          },
                        ),
                      )
                    ],
                  ),
                ),
              ],
            ),
          );
        });
  }
}
