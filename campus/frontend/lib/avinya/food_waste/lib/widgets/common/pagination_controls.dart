import 'package:flutter/material.dart';

class PaginationControls extends StatelessWidget {
  final bool hasPrevious;
  final bool hasNext;
  final int limit;
  final VoidCallback onPrevious;
  final VoidCallback onNext;
  final Function(int) onLimitChanged;

  const PaginationControls({
    super.key,
    required this.hasPrevious,
    required this.hasNext,
    required this.limit,
    required this.onPrevious,
    required this.onNext,
    required this.onLimitChanged,
  });

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.end,
      children: [
        const Text("Rows:", style: TextStyle(fontSize: 14)),
        const SizedBox(width: 8),
        DropdownButton<int>(
          value: limit,
          underline: Container(),
          focusColor: Colors.transparent,
          items: const [
            DropdownMenuItem(value: 5, child: Text('5')),
            DropdownMenuItem(value: 10, child: Text('10')),
            DropdownMenuItem(value: 15, child: Text('15')),
            DropdownMenuItem(value: 20, child: Text('20')),
          ],
          onChanged: (value) {
            if (value != null) onLimitChanged(value);
          },
        ),
        const SizedBox(width: 16),
        IconButton(
          icon: const Icon(Icons.chevron_left),
          onPressed: hasPrevious ? onPrevious : null,
        ),
        IconButton(
          icon: const Icon(Icons.chevron_right),
          onPressed: hasNext ? onNext : null,
        ),
      ],
    );
  }
}
