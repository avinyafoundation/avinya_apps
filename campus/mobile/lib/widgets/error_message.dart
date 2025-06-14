import 'package:flutter/material.dart';
import 'package:oktoast/oktoast.dart';

void showErrorToast(item) {
  showToastWidget(
    Container(
      padding: const EdgeInsets.symmetric(horizontal: 24.0, vertical: 12.0),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(25.0),
        color: Colors.red[600],
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(Icons.check, color: Colors.white),
          SizedBox(width: 12.0),
          Text(
            item.toString(),
            style: TextStyle(color: Colors.white),
          ),
        ],
      ),
    ),
    duration: Duration(seconds: 3),
    position: ToastPosition.top,
  );
}
