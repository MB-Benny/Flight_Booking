import 'package:flutter/material.dart';

class ClassAndPassengerSelectionDialog extends StatefulWidget {
  final Color primaryGreen;
  final Function(String, int, int, int) onConfirm;

  ClassAndPassengerSelectionDialog({required this.primaryGreen, required this.onConfirm});

  @override
  _ClassAndPassengerSelectionDialogState createState() => _ClassAndPassengerSelectionDialogState();
}

class _ClassAndPassengerSelectionDialogState extends State<ClassAndPassengerSelectionDialog> {
  String _selectedClass = 'Economy';
  int _adults = 1;
  int _children = 0;
  int _infants = 0;

  Widget _buildPassengerCounter(String label, int count, ValueChanged<int> onChanged) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(label, style: TextStyle(color: widget.primaryGreen, fontSize: 18, fontWeight: FontWeight.bold)),
        Row(
          children: [
            IconButton(
              icon: Icon(Icons.remove_circle_outline, color: widget.primaryGreen),
              onPressed: () {
                if (count > 0) onChanged(count - 1);
              },
            ),
            Text(count.toString(), style: TextStyle(fontSize: 18, color: widget.primaryGreen)),
            IconButton(
              icon: Icon(Icons.add_circle_outline, color: widget.primaryGreen),
              onPressed: () {
                onChanged(count + 1);
              },
            ),
          ],
        ),
      ],
    );
  }

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: Text("Select Class and Passengers", style: TextStyle(color: widget.primaryGreen, fontSize: 20, fontWeight: FontWeight.bold)),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)), // Rounded edges
      elevation: 0, // No shadow
      backgroundColor: Colors.white, // Full white background
      content: Container(
        width: double.maxFinite, // Set width to max
        padding: EdgeInsets.all(16), // Add padding around content
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            InputDecorator(
              decoration: InputDecoration(
                labelText: 'Class',
                labelStyle: TextStyle(color: widget.primaryGreen, fontSize: 16),
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12), // Rounded edges
                  borderSide: BorderSide(color: widget.primaryGreen),
                ),
              ),
              child: Container(
                height: 50, // Adjust height for the dropdown
                child: DropdownButtonHideUnderline(
                  child: DropdownButton<String>(
                    value: _selectedClass,
                    isExpanded: true, // Make the dropdown expand to fill width
                    onChanged: (String? newValue) {
                      setState(() {
                        _selectedClass = newValue!;
                      });
                    },
                    items: <String>['Economy', 'Business', 'First Class']
                        .map<DropdownMenuItem<String>>((String value) {
                      return DropdownMenuItem<String>(
                        value: value,
                        child: Text(value, style: TextStyle(color: widget.primaryGreen)), // Custom style for dropdown items
                      );
                    }).toList(),
                  ),
                ),
              ),
            ),
            SizedBox(height: 20),
            _buildPassengerCounter("Adults", _adults, (int value) {
              setState(() {
                _adults = value;
              });
            }),
            _buildPassengerCounter("Children", _children, (int value) {
              setState(() {
                _children = value;
              });
            }),
            _buildPassengerCounter("Infants", _infants, (int value) {
              setState(() {
                _infants = value;
              });
            }),
          ],
        ),
      ),
      actions: [
        ElevatedButton(
          style: ElevatedButton.styleFrom(
            primary: widget.primaryGreen, // Background color
            onPrimary: Colors.white, // Text color
          ),
          child: Text("Confirm", style: TextStyle(fontSize: 16)),
          onPressed: () {
            widget.onConfirm(_selectedClass, _adults, _children, _infants); // Pass values back
            Navigator.of(context).pop();
          },
        ),
      ],
    );
  }
}
