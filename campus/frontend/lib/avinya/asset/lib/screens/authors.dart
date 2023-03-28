import 'package:flutter/material.dart';

import '../data/campus_config_system.dart';
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
          authors: campusConfigSystemInstance.allAuthors,
          onTap: (author) {
            RouteStateScope.of(context).go('/author/${author.id}');
          },
        ),
      );
}
