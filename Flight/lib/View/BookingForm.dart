import 'package:flight_booking/Model/material.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../Model/Flight.dart';
import 'ClassAndPassengerSelectionDialog.dart';

class BookingForm extends StatefulWidget {
  final String bookingType;

  const BookingForm({Key? key, required this.bookingType}) : super(key: key);

  @override
  _BookingFormState createState() => _BookingFormState();
}

class _BookingFormState extends State<BookingForm> {
  final Color primaryGreen = const Color(0xFF388E3C);
  final List<Map<String, dynamic>> additionalLocations = [];
// Holds multiple locations for multi-city
  DateTime? selectedDepartureDate;
  DateTime? selectedReturnDate;

  final TextEditingController departureDateController = TextEditingController();
  final TextEditingController returnDateController = TextEditingController();
  final TextEditingController _controller = TextEditingController();

  String selectedTravelClass = "Economy";
  int adults = 1;
  int children = 0;
  int infants = 0;
  bool _showFlightList = false;

  // Sample flight list
  List<Flight> flightPreferences = [
    Flight(airline: "Airline A", departure: "10:00 AM", arrival: "5:00 PM", price: 1500.0),
    Flight(airline: "Airline B", departure: "11:00 AM", arrival: "1:00 PM", price: 2000.0),
    Flight(airline: "Airline C", departure: "12:00 PM", arrival: "2:00 PM", price: 1800.0),
  ];


  @override
  void initState() {
    super.initState();
    _loadPreferences(); // Load saved preferences on initialization
  }
  Future<void> _loadPreferences() async {
    final prefs = await SharedPreferences.getInstance();

    setState(() {
      // Load the saved departure date and update the controller
      String? savedDepartureDate = prefs.getString('departureDate');
      if (savedDepartureDate != null && savedDepartureDate.isNotEmpty) {
        selectedDepartureDate = DateTime.parse(savedDepartureDate); // Parse and store as DateTime
        departureDateController.text = '${selectedDepartureDate?.toLocal()}'.split(' ')[0]; // Format the date for display
      }

      // Load the saved return date and update the controller
      String? savedReturnDate = prefs.getString('returnDate');
      if (savedReturnDate != null && savedReturnDate.isNotEmpty) {
        selectedReturnDate = DateTime.parse(savedReturnDate); // Parse and store as DateTime
        returnDateController.text = '${selectedReturnDate?.toLocal()}'.split(' ')[0]; // Format the date for display
      }

      // Load the travel class and passenger information
      _controller.text = prefs.getString('travelClass') ?? '';

      // Load the saved "From" and "To" locations
      String? savedFrom = prefs.getString('from');
      String? savedTo = prefs.getString('to');
      Provider.of<BookingModel>(context, listen: false).updateFrom(savedFrom ?? '');
      Provider.of<BookingModel>(context, listen: false).updateTo(savedTo ?? '');

      // Optionally load additional preferences like adults, children, and infants counts
      adults = prefs.getInt('adults') ?? 1; // Default to 1 adult
      children = prefs.getInt('children') ?? 0; // Default to 0 children
      infants = prefs.getInt('infants') ?? 0; // Default to 0 infants
    });
  }



  // Method to save selected dates and travel class
  Future<void> _savePreferences(BookingModel bookingModel) async {
    SharedPreferences prefs = await SharedPreferences.getInstance();

    await prefs.setString('from', bookingModel.from);
    await prefs.setString('to', bookingModel.to);
    await prefs.setString('travelClass', selectedTravelClass); // Ensure selectedTravelClass is defined
    await prefs.setInt('adults', adults); // Ensure adults is defined
    await prefs.setInt('children', children); // Ensure children is defined
    await prefs.setInt('infants', infants); // Ensure infants is defined
    await prefs.setString('departureDate', bookingModel.departureDate?.toIso8601String() ?? ''); // Handle potential null
    await prefs.setString('returnDate', bookingModel.returnDate?.toIso8601String() ?? ''); // Handle potential null
  }



  // Validate Booking Data
  bool _validateBookingData(BookingModel bookingModel) {
    if (bookingModel.from.isEmpty || bookingModel.to.isEmpty ||
        departureDateController.text.isEmpty ||
        (widget.bookingType == 'Round-Trip' && returnDateController.text.isEmpty)) {
      return false;
    }
    return true;
  }


  // @override
  // void dispose() {
  //   departureDateController.dispose();
  //   returnDateController.dispose();
  //   super.dispose();
  // }

  @override
  Widget build(BuildContext context) {
    return Consumer<BookingModel>(
      builder: (context, bookingModel, child) {
        return Padding(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [

              // From Field with Flight Icon
              _buildDropdownField(
                label: 'From',
                value: bookingModel.from.isEmpty ? null : bookingModel.from,
                items: ['New York', 'London', 'Paris', 'Tokyo', 'Sydney'],
                onChanged: (value) => value != null ? bookingModel.updateFrom(value) : null,
                icon: Icons.flight_takeoff,
              ),
              const SizedBox(height: 20),

              // To Field with Flight Icon
              _buildDropdownField(
                label: 'To',
                value: bookingModel.to.isEmpty ? null : bookingModel.to,
                items: ['New York', 'London', 'Paris', 'Tokyo', 'Sydney'],
                onChanged: (value) => value != null ? bookingModel.updateTo(value) : null,
                icon: Icons.flight_land,
              ),
              const SizedBox(height: 20),

              // Departure Date with Calendar Icon
              _buildDateField(
                controller: departureDateController,
                label: 'Departure Date',
                onTap: () => _selectDate(context, true),
                icon: Icons.calendar_today,
              ),
              const SizedBox(height: 5),

              // Return Date with Calendar Icon (only for Round-Trip)
              if (widget.bookingType == 'Round-Trip')
                _buildDateField(
                  controller: returnDateController,
                  label: 'Return Date',
                  onTap: () => _selectDate(context, false),
                  icon: Icons.calendar_today,
                ),

              // Multi-City Additional Locations
              if (widget.bookingType == 'Multi-City')
                _buildMultiCityLocations(),

              const SizedBox(height: 10),

              // Travel Class & Passenger selection
              GestureDetector(
                onTap: () {
                  _showTravelClassAndPassengerDialog();
                },
                child: Container(
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(12),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.grey.withOpacity(0.2),
                        spreadRadius: 2,
                        blurRadius: 6,
                        offset: Offset(0, 3), // Changes position of shadow
                      ),
                    ],
                  ),
                  child: AbsorbPointer(
                    child: TextFormField(
                      controller: _controller, // Assign the controller
                      decoration: InputDecoration(
                        labelText: 'Travel Class & Passengers',
                        labelStyle: TextStyle(color: Colors.green), // Replace with your primary color
                        hintText: 'Select Travel Class & Passengers', // Placeholder for user guidance
                        hintStyle: TextStyle(color: Colors.grey), // Style for the hint text
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(12),
                          borderSide: BorderSide(color: Colors.green), // Replace with your primary color
                        ),
                        suffixIcon: Icon(Icons.arrow_drop_down, color: Colors.green), // Dropdown icon
                        filled: true,
                        fillColor: Colors.white,
                        contentPadding: EdgeInsets.symmetric(vertical: 12, horizontal: 15), // Adjusted padding
                      ),
                    ),
                  ),
                ),
              ),


              const SizedBox(height: 40),

              // Book Flight Button
              Center(
                child: SizedBox(
                  width: 400, // Set the desired width here
                  child: ElevatedButton(
                    style: ElevatedButton.styleFrom(
                      primary: primaryGreen,
                      padding: const EdgeInsets.symmetric(vertical: 15), // Keep the vertical padding
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(8),
                      ),
                      elevation: 5, // Adding elevation for depth
                    ),
                    onPressed: () {
                      // Validate data before booking
                      if (_validateBookingData(bookingModel)) {
                        _savePreferences(bookingModel);
                        setState(() {
                          _showFlightList = true; // Show flight list when booking is validated
                        });
                        // Proceed with the booking submission logic here
                        // ScaffoldMessenger.of(context).showSnackBar(
                        //   SnackBar(content: Text('Flight booked successfully!')),
                        // );
                      } else {
                        // Show validation error message
                        ScaffoldMessenger.of(context).showSnackBar(
                          SnackBar(content: Text('Please fill in all required fields.')),
                        );
                      }
                    },
                    child: const Text('Search Flight', style: TextStyle(color: Colors.white, fontSize: 16)),
                  ),
                ),
              ),
              if (_showFlightList) ...[
                SizedBox(height: 20), // Add some spacing
                if (_showFlightList) ...[
                  Expanded(
                    child: ListView.builder(
                      itemCount: flightPreferences.length,
                      itemBuilder: (context, index) {
                        final flight = flightPreferences[index];
                        return Card(
                          elevation: 5,
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(12),
                          ),
                          margin: EdgeInsets.symmetric(vertical: 8, horizontal: 16),
                          child: ListTile(
                            contentPadding: EdgeInsets.all(16),
                            tileColor: Color(0xFFE6F9E9), // Light green background
                            title: Text(
                              flight.airline,
                              style: TextStyle(
                                fontSize: 18,
                                fontWeight: FontWeight.bold,
                                color: Colors.green[800],
                              ),
                            ),
                            subtitle: Column(
                              crossAxisAlignment: CrossAxisAlignment.start, // Align text to the start
                              children: [
                                Row(
                                  children: [
                                    Icon(Icons.access_time, color: Colors.green[600]),
                                    SizedBox(width: 5),
                                    Text(
                                      'Departure: ${flight.departure}',
                                      style: TextStyle(color: Colors.green[600]),
                                    ),
                                  ],
                                ),
                                SizedBox(height: 4), // Space between departure and arrival
                                Row(
                                  children: [
                                    Icon(Icons.flight_land, color: Colors.green[600]),
                                    SizedBox(width: 5),
                                    Text(
                                      'Arrival: ${flight.arrival}',
                                      style: TextStyle(color: Colors.green[600]),
                                    ),
                                  ],
                                ),
                              ],
                            ),
                            trailing: Text(
                              '₹${flight.price.toStringAsFixed(0)}', // Display price in Rupees
                              style: TextStyle(
                                fontSize: 16,
                                fontWeight: FontWeight.bold,
                                color: Colors.green[900],
                              ),
                            ),
                          ),
                        );
                      },
                    ),
                  ),
                ],

              ],

            ],
          ),
        );
      },
    );
  }

  // Builds a dropdown field
  Widget _buildDropdownField({
    required String label,
    required String? value,
    required List<String> items,
    required ValueChanged<String?> onChanged,
    required IconData icon,
  }) {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        boxShadow: [
          BoxShadow(
            color: Colors.grey.withOpacity(0.2),
            spreadRadius: 2,
            blurRadius: 6,
            offset: Offset(0, 3), // changes position of shadow
          ),
        ],
      ),
      child: InputDecorator(
        decoration: InputDecoration(
          labelText: label,
          labelStyle: TextStyle(color: primaryGreen),
          border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(12),
            borderSide: BorderSide(color: primaryGreen),
          ),
          prefixIcon: Icon(icon, color: primaryGreen),
          filled: true,
          fillColor: Colors.white,
          contentPadding: EdgeInsets.symmetric(vertical: 8, horizontal: 12), // Reduced padding
        ),
        child: DropdownButtonHideUnderline(
          child: Container(
            height: 40, // Set specific height for the dropdown
            child: DropdownButton<String>(
              value: value,
              hint: Text('Select $label', style: TextStyle(color: Colors.grey)),
              items: items.map((location) {
                return DropdownMenuItem(
                  value: location,
                  child: Text(location, style: TextStyle(color: Colors.black)),
                );
              }).toList(),
              onChanged: onChanged,
              icon: Icon(Icons.arrow_drop_down, color: primaryGreen), // Custom dropdown icon
              isExpanded: true, // Make dropdown expand to full width
              dropdownColor: Colors.white, // Color of the dropdown menu
            ),
          ),
        ),
      ),
    );
  }



  // Builds a date picker field
  Widget _buildDateField({
    required TextEditingController controller,
    required String label,
    required VoidCallback onTap,
    required IconData icon,
  }) {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        boxShadow: [
          BoxShadow(
            color: Colors.grey.withOpacity(0.2),
            spreadRadius: 2,
            blurRadius: 6,
            offset: Offset(0, 3), // changes position of shadow
          ),
        ],
      ),
      child: GestureDetector(
        onTap: onTap,
        child: AbsorbPointer(
          child: TextFormField(
            controller: controller,
            decoration: InputDecoration(
              labelText: label,
              labelStyle: TextStyle(color: primaryGreen),
              hintText: 'Select date',
              hintStyle: TextStyle(color: Colors.grey), // hint text color
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(12),
                borderSide: BorderSide(color: primaryGreen),
              ),
              prefixIcon: Padding(
                padding: const EdgeInsets.all(12.0), // Add padding for better alignment
                child: Stack(
                  children: [
                    Icon(Icons.calendar_month_outlined, color: primaryGreen), // Calendar icon
                    Positioned(
                      right: 0,
                      top: 0,
                      child: Container(
                        decoration: BoxDecoration(
                          color: primaryGreen,
                          shape: BoxShape.circle,
                        ),
                        // padding: EdgeInsets.all(4),
                        // child: Text(
                        //   '1', // Change this number dynamically as needed
                        //   style: TextStyle(
                        //     color: Colors.white,
                        //     fontSize: 12,
                        //     fontWeight: FontWeight.bold,
                        //   ),
                        // ),
                      ),
                    ),
                  ],
                ),
              ),
              filled: true,
              fillColor: Colors.white,
              contentPadding: EdgeInsets.symmetric(vertical: 10, horizontal: 15), // Adjusted padding
            ),
          ),
        ),
      ),
    );
  }


  Future<void> _selectDate(BuildContext context, bool isDeparture) async {
    DateTime? initialDate = isDeparture ? selectedDepartureDate ?? DateTime.now() : selectedReturnDate ?? DateTime.now();
    DateTime? date = await showDatePicker(
      context: context,
      initialDate: initialDate,
      firstDate: DateTime.now(),
      lastDate: DateTime(2101),
      builder: (context, child) {
        return Theme(
          data: Theme.of(context).copyWith(
            colorScheme: ColorScheme.light(
              primary: primaryGreen,
              onPrimary: Colors.white,
              onSurface: primaryGreen,
            ),
            textButtonTheme: TextButtonThemeData(
              style: TextButton.styleFrom(primary: primaryGreen),
            ),
          ),
          child: child!,
        );
      },
    );

    if (date != null) {
      setState(() {
        if (isDeparture) {
          selectedDepartureDate = date;
          departureDateController.text = '${date.toLocal()}'.split(' ')[0]; // Set the text
        } else {
          selectedReturnDate = date;
          returnDateController.text = '${date.toLocal()}'.split(' ')[0]; // Set the text
        }
      });

      // Get the current booking model to save preferences
      final bookingModel = Provider.of<BookingModel>(context, listen: false);

      // Update the booking model with the selected dates
      if (isDeparture) {
        bookingModel.setDepartureDate(date);
      } else {
        bookingModel.setReturnDate(date);
      }

      // Save preferences with the booking model
      await _savePreferences(bookingModel);
    }
  }


// Builds the UI for additional locations in multi-city bookings
// Builds the UI for additional locations in multi-city bookings
  Widget _buildMultiCityLocations() {
    return Column(
      children: [
        ...additionalLocations.map((location) {
          return ListTile(
            title: Text('From: ${location['from']}, To: ${location['to']}'),
            subtitle: Text('Departure Date: ${location['departureDate']}'),
            trailing: IconButton(
              icon: Icon(Icons.delete, color: primaryGreen),
              onPressed: () {
                setState(() {
                  additionalLocations.remove(location);
                });
              },
            ),
          );
        }).toList(),

        Row(
          children: [
            Icon(Icons.add, color: primaryGreen),
            const SizedBox(width: 8),
            GestureDetector(
              onTap: _showAddCityBottomSheet,
              child: Text(
                'Add City',
                style: TextStyle(
                  color: primaryGreen,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
          ],
        ),
      ],
    );
  }

  void _showAddCityBottomSheet() {
    String? from;
    String? to;
    DateTime? departureDate;

    showModalBottomSheet(
      context: context,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
      ),
      backgroundColor: Colors.white,
      builder: (context) {
        return StatefulBuilder(
          builder: (BuildContext context, StateSetter setModalState) {
            return Padding(
              padding: const EdgeInsets.all(16.0),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  _buildDropdownField(
                    label: 'From',
                    value: from,
                    items: ['New York', 'London', 'Paris', 'Tokyo', 'Sydney'],
                    onChanged: (value) {
                      setModalState(() {
                        from = value;
                      });
                    },
                    icon: Icons.flight_takeoff,
                  ),
                  const SizedBox(height: 16),
                  _buildDropdownField(
                    label: 'To',
                    value: to,
                    items: ['New York', 'London', 'Paris', 'Tokyo', 'Sydney'],
                    onChanged: (value) {
                      setModalState(() {
                        to = value;
                      });
                    },
                    icon: Icons.flight_land,
                  ),
                  const SizedBox(height: 16),
                  GestureDetector(
                    onTap: () async {
                      DateTime? date = await showDatePicker(
                        context: context,
                        initialDate: DateTime.now(),
                        firstDate: DateTime.now(),
                        lastDate: DateTime(2101),
                      );
                      if (date != null) {
                        setModalState(() {
                          departureDate = date;
                        });
                      }
                    },
                    child: AbsorbPointer(
                      child: TextFormField(
                        decoration: InputDecoration(
                          labelText: departureDate != null
                              ? 'Departure Date: ${departureDate!.toLocal()}'.split(' ')[0]
                              : 'Select Departure Date',
                          labelStyle: TextStyle(color: primaryGreen),
                          border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(8),
                            borderSide: BorderSide(color: primaryGreen),
                          ),
                          prefixIcon: Icon(Icons.calendar_today, color: primaryGreen), // Green calendar icon
                          filled: true,
                          fillColor: Colors.white,
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(height: 20),
                  SizedBox(
                    width: double.infinity,
                    child: ElevatedButton(
                      style: ElevatedButton.styleFrom(
                        primary: primaryGreen, // Make the button green
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(8),
                        ),
                      ),
                      onPressed: () {
                        if (from != null && to != null && departureDate != null) {
                          setState(() {
                            additionalLocations.add({
                              'from': from,
                              'to': to,
                              'departureDate': departureDate,
                            });
                          });
                          Navigator.pop(context);
                        }
                      },
                      child: const Text(
                        'Add',
                        style: TextStyle(color: Colors.white), // White button text
                      ),
                    ),
                  ),
                ],
              ),
            );
          },
        );
      },
    );
  }





  void _showTravelClassAndPassengerDialog() {
    showDialog(
      context: context,
      builder: (context) {
        return ClassAndPassengerSelectionDialog(
          primaryGreen: Colors.green, // Replace with your primary color
          onConfirm: (String travelClass, int adultsCount, int childrenCount, int infantsCount) {
            setState(() {
              selectedTravelClass = travelClass; // Update selected travel class
              adults = adultsCount; // Update adults count
              children = childrenCount; // Update children count
              infants = infantsCount; // Update infants count

              // Update the controller text to reflect the selections
              _controller.text = '$selectedTravelClass: Adults $adults, Children $children, Infants $infants'; // Ensure all details are included
            });

            // Get the current booking model to save preferences
            final bookingModel = Provider.of<BookingModel>(context, listen: false);

            // Save preferences, passing the booking model
            _savePreferences(bookingModel);
          },
        );
      },
    );
  }


}
