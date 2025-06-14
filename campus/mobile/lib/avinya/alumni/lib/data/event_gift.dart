import 'dart:convert';

import 'package:http/http.dart' as http;
class EventGift {
  int? id;
  int? activity_instance_id;
  double? gift_amount;
  int? no_of_gifts;
  String? notes;
  String? description;

  EventGift({
    this.id,
    this.activity_instance_id,
    this.gift_amount,
    this.no_of_gifts,
    this.notes,
    this.description
  });

  factory EventGift.fromJson(Map<String, dynamic> json) {
    return EventGift(
      id: json['id'],
      activity_instance_id: json['activity_instance_id'],
      gift_amount: json['gift_amount'],
      no_of_gifts: json['no_of_gifts'],
      notes: json['notes'],
      description: json['description']
    );
  }

  Map<String, dynamic> toJson() => {
        if (id != null) 'id': id,
        if (activity_instance_id != null) 'activity_instance_id': activity_instance_id,
        if (gift_amount != null) 'gift_amount': gift_amount,
        if (no_of_gifts != null) 'no_of_gifts': no_of_gifts,
        if (notes != null) 'notes': notes,
        if (description !=null) 'description': description
      };
}

