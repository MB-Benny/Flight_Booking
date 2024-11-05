import 'package:flutter/foundation.dart';

class BookingModel extends ChangeNotifier {
  String from = '';
  String to = '';
  DateTime? departureDate;
  DateTime? returnDate;

  // For multi-city booking
  List<String> additionalLocations = [];

  void updateFrom(String location) {
    from = location;
    notifyListeners();
  }

  void updateTo(String location) {
    to = location;
    notifyListeners();
  }

  void setDepartureDate(DateTime date) {
    departureDate = date; // Always update the departure date
    notifyListeners();
  }

  void setReturnDate(DateTime date) {
    returnDate = date; // Always update the return date
    notifyListeners();
  }

  void resetForOneWay() {
    from = '';
    to = '';
    departureDate = null;
    returnDate = null;
    notifyListeners();
  }

  void resetForRoundTrip() {
    from = '';
    to = '';
    departureDate = null;
    returnDate = null;
    notifyListeners();
  }

  void resetForMultiCity() {
    from = '';
    to = '';
    departureDate = null;
    returnDate = null;
    additionalLocations.clear();
    notifyListeners();
  }


  DateTime? getDepartureDate() => departureDate;
  DateTime? getReturnDate() => returnDate;
}
