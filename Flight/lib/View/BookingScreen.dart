import 'package:flight_booking/Model/material.dart';
import 'package:flight_booking/View/BookingForm.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

class BookingScreen extends StatefulWidget {
  @override
  _BookingScreenState createState() => _BookingScreenState();
}

class _BookingScreenState extends State<BookingScreen> {
  // Define green shades
  final Color primaryGreen = Color(0xFF388E3C);
  final Color lightGreen = Color(0xFFFFFFFF);
  int _currentTabIndex = 0;

  @override
  Widget build(BuildContext context) {
    return DefaultTabController(
      length: 3,
      child: Scaffold(
        appBar: AppBar(
          title: Text(
            'Flight Search',
            style: TextStyle(color: Colors.white),
          ),
          backgroundColor: primaryGreen,
          bottom: TabBar(
            indicatorColor: lightGreen,  // Tab indicator color
            labelColor: Colors.white,  // Selected tab label color
            unselectedLabelColor: lightGreen,  // Unselected tab label color
            onTap: (index) {
              setState(() {
                _currentTabIndex = index; // Update current tab index
              });
              final bookingModel = Provider.of<BookingModel>(context, listen: false);
              switch (index) {
                case 0: // One-way
                  bookingModel.resetForOneWay();
                  break;
                case 1: // Round-trip
                  bookingModel.resetForRoundTrip();
                  break;
                case 2: // Multi-city
                  bookingModel.resetForMultiCity();
                  break;
              }
            },
            tabs: [
              Tab(text: 'One-way'),
              Tab(text: 'Round-trip'),
              Tab(text: 'Multi-city'),
            ],
          ),
        ),
        body: TabBarView(
          children: [
            BookingForm(bookingType: 'One-way'),
            BookingForm(bookingType: 'Round-Trip'),
            BookingForm(bookingType: 'Multi-City'),
          ],
        ),
      ),
    );
  }
}
