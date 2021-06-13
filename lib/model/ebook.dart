class EBook {
  final int id;
  final String title;
  final String coverURL;
  final int pages;
  int bookMark;
  final String pdfPath;

  EBook(this.id, this.title, this.coverURL, this.pages, this.bookMark,
      this.pdfPath);

  EBook.fromJson(Map<String, dynamic> json)
      : id = json['id'],
        title = json['title'],
        coverURL = json['coverURL'],
        pages = json['pages'],
        bookMark = json['bookMark'],
        pdfPath = json['pdfPath'];

  Map<String, dynamic> toJson() => {
        'id': id,
        'title': title,
        'coverURL': coverURL,
        'pages': pages,
        'bookMark': bookMark,
        'pdfPath': pdfPath,
      };
}
