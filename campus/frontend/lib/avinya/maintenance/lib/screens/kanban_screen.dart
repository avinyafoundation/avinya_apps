import 'package:flutter/material.dart';
import '../widgets/kanban_board.dart';

class KanbanScreen extends StatelessWidget {
  const KanbanScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      body: KanbanBoard(),
    );
  }
}