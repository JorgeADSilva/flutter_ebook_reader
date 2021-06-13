import 'dart:convert';

import 'package:ebookreader/model/ebook.dart';
import 'package:shared_preferences/shared_preferences.dart';

class SharedPreferencesHolder {
  static saveInitialDocuments() async {
    List<EBook> booksToSave = [
      EBook(
          1,
          "The monk who sold his ferrari",
          "https://www.booksfree.org/wp-content/uploads/2021/01/The-Monk-Who-Sold-His-Ferrari-pdf-free-download.jpg",
          208,
          2,
          "empty"),
      EBook(2, "The monk who sold his ferrari", "empty", 208, 3, "empty")
    ];
    String booksJSON = jsonEncode(booksToSave);
    SharedPreferences prefs = await SharedPreferences.getInstance();
    await prefs.setString('booksSaved', booksJSON);
  }

  static saveBook(EBook newBook) async {
    List<EBook> booksToSave = await getEBooks();
    booksToSave.add(newBook);
    String booksJSON = jsonEncode(booksToSave);
    SharedPreferences prefs = await SharedPreferences.getInstance();
    await prefs.setString('booksSaved', booksJSON);
  }

  static updateEbookBookMark(EBook book, int bookMark) async {
    List<EBook> booksToSave = await getEBooks();
    book.bookMark = bookMark;
    booksToSave[booksToSave.indexWhere((element) => element.id == book.id)] =
        book;
    SharedPreferences prefs = await SharedPreferences.getInstance();
    String booksJSON = jsonEncode(booksToSave);
    await prefs.setString('booksSaved', booksJSON);
  }

  static Future<List<EBook>> getEBooks() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    String? books = prefs.getString('booksSaved');
    if (books == null) {
      return [];
    } else {
      Iterable l = json.decode(books);
      return List<EBook>.from(l.map((model) => EBook.fromJson(model)));
    }
  }
}
