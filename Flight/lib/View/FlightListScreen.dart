import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';

import '../Model/Flight.dart';

class FlightListScreen extends StatefulWidget {
  const FlightListScreen({super.key});

  @override
  State<FlightListScreen> createState() => _FlightListScreenState();
}

class _FlightListScreenState extends State<FlightListScreen> {

  final List<Flight> flightPreferences = [
    Flight(airline: "Airline A", departure: "10:00 AM", arrival: "12:00 PM", price: 150.0),
    Flight(airline: "Airline B", departure: "11:00 AM", arrival: "1:00 PM", price: 200.0),
    Flight(airline: "Airline C", departure: "12:00 PM", arrival: "2:00 PM", price: 180.0),
    // Add more flights as needed
  ];


  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text('Flight Preferences')),
      body: ListView.builder(
        itemCount: flightPreferences.length,
        itemBuilder: (context, index) {
          final flight = flightPreferences[index];
          return ListTile(
            title: Text(flight.airline),
            subtitle: Text('Departure: ${flight.departure}, Arrival: ${flight.arrival}'),
            trailing: Text('\$${flight.price}'),
          );
        },
      ),
    );
  }
}
