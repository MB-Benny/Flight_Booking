import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

class Airport {
  final String iata;
  final String name;

  Airport({required this.iata, required this.name});

  factory Airport.fromJson(Map<String, dynamic> json) {
    return Airport(
      iata: json['iata'],
      name: json['name'],
    );
  }
}

Future<List<Airport>> loadAirportData() async {
  final String response = await rootBundle.loadString('assets/json/flight.json');
  final List<dynamic> data = json.decode(response);
  return data.map((e) => Airport.fromJson(e)).toList();
}
