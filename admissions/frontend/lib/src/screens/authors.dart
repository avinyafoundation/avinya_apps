import 'package:flutter/material.dart';

import '../data/admission_system.dart';
import '../routing.dart';
import '../widgets/author_list.dart';

class AuthorsScreen extends StatelessWidget {
  final String title = 'Authors';

  const AuthorsScreen({super.key});

  @override
  Widget build(BuildContext context) => Scaffold(
        appBar: AppBar(
          title: Text(title),
        ),
        body: AuthorList(
          authors: admissionSystemInstance.allAuthors,
          onTap: (author) {
            RouteStateScope.of(context).go('/author/${author.id}');
          },
        ),
      );
}
