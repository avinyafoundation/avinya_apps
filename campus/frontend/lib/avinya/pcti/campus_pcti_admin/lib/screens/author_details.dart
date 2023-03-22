import 'package:flutter/material.dart';

import '../data.dart';
import '../routing.dart';
import '../widgets/book_list.dart';

class AuthorDetailsScreen extends StatelessWidget {
  final Author author;

  const AuthorDetailsScreen({
    super.key,
    required this.author,
  });

  @override
  Widget build(BuildContext context) => Scaffold(
        appBar: AppBar(
          title: Text(author.name),
        ),
        body: Center(
          child: Column(
            children: [
              Expanded(
                child: BookList(
                  books: author.books,
                  onTap: (book) {
                    RouteStateScope.of(context).go('/book/${book.id}');
                  },
                ),
              ),
            ],
          ),
        ),
      );
}
