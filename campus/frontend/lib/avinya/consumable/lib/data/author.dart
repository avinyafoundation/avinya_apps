import 'book.dart';

class Author {
  final int id;
  final String name;
  final books = <Book>[];

  Author(this.id, this.name);
}
