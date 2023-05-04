import 'dart:async';

import 'package:http/http.dart' as http;
import 'dart:convert';

import '../config/app_config.dart';
import '../data.dart';

class Organization {
  int? id;

  Organization({this.id});

  factory Organization.fromJson(Map<String, dynamic> json) {
    return Organization(
      id: json['id'],
    );
  }

  Map<String, dynamic> toJson() => {
        if (id != null) 'id': id,
      };
}
