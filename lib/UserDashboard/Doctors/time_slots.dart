import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:healthcare/UserDashboard/Doctors/appointment_confirmation_screen.dart';
import 'package:intl/intl.dart';

class TimeSlotsScreen extends StatefulWidget {
  final DateTime selectedDate;
  final String doctorId;
  final String userId; // Add user info
  final String userName;
  final String userEmail;

  const TimeSlotsScreen({
    Key? key,
    required this.selectedDate,
    required this.doctorId,
    required this.userId,
    required this.userName,
    required this.userEmail,
  }) : super(key: key);

  @override
  State<TimeSlotsScreen> createState() => _TimeSlotsScreenState();
}

class _TimeSlotsScreenState extends State<TimeSlotsScreen> {
  String? _selectedSlotId;
  bool _isLoading = true;
  List<Map<String, dynamic>> _slots = [];
  String? _error;

  @override
  void initState() {
    super.initState();
    _fetchSlots();
  }

  Future<void> _fetchSlots() async {
    setState(() {
      _isLoading = true;
      _error = null;
    });

    try {
      final formattedDate =
      DateFormat('yyyy-MM-dd').format(widget.selectedDate);
      debugPrint('Fetching slots for date: $formattedDate');
      final QuerySnapshot snapshot = await FirebaseFirestore.instance
          .collection('doctors')
          .doc(widget.doctorId)
          .collection('slots')
          .where('date', isEqualTo: formattedDate)
      // .orderBy('startTime') // Uncomment after creating Firestore index
          .get();

      debugPrint('Found ${snapshot.docs.length} slots');

      setState(() {
        _slots = snapshot.docs.map((doc) {
          return {
            'id': doc.id,
            'date': doc['date'],
            'startTime': doc['startTime'],
            'endTime': doc['endTime'],
            'status': doc['status'] ?? 'available',
            'isBooked': doc['isBooked'] ?? false,
          };
        }).toList();
        _isLoading = false;
      });
    } on FirebaseException catch (e) {
      setState(() {
        _error = 'Database error: ${e.message}';
        _isLoading = false;
      });
      debugPrint('Firestore error: ${e.message}');
    } catch (e) {
      setState(() {
        _error = 'Unexpected error: $e';
        _isLoading = false;
      });
      debugPrint('Error fetching slots: $e');
    }
  }

  Future<void> _bookSlot() async {
    if (_selectedSlotId == null) return;

    try {
      setState(() => _isLoading = true);

      // Update the slot status to booked
      await FirebaseFirestore.instance
          .collection('doctors')
          .doc(widget.doctorId)
          .collection('slots')
          .doc(_selectedSlotId)
          .update({
        'status': 'booked',
        'isBooked': true,
        'bookedAt': FieldValue.serverTimestamp(),
      });

      // Get the booked slot details
      final bookedSlot = _slots.firstWhere((s) => s['id'] == _selectedSlotId);

      // Create a document in the 'booked' subcollection with patient info
      await FirebaseFirestore.instance
          .collection('doctors')
          .doc(widget.doctorId)
          .collection('booked')
          .add({
        'slotId': _selectedSlotId,
        'date': bookedSlot['date'],
        'startTime': bookedSlot['startTime'],
        'endTime': bookedSlot['endTime'],
        'status': 'booked',
        'isBooked': true,
        'bookedAt': FieldValue.serverTimestamp(),
        'bookedById': widget.userId,
        'bookedByName': widget.userName,
        'bookedByEmail': widget.userEmail,
      });

      // Navigate to confirmation screen
      Navigator.pushReplacement(
        context,
        MaterialPageRoute(
          builder: (context) => AppointmentConfirmationScreen(
            selectedDate: widget.selectedDate,
            selectedSlot: '${bookedSlot['startTime']} - ${bookedSlot['endTime']}',
          ),
        ),
      );
    } catch (e) {
      setState(() => _isLoading = false);
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Booking failed: $e')),
      );
    } finally {
      setState(() {
        _isLoading = false;
        _selectedSlotId = null;
      });
      await _fetchSlots(); // Refresh the slots
    }
  }

  Color _getStatusColor(String status) {
    switch (status.toLowerCase()) {
      case 'booked':
        return Colors.orange;
      case 'completed':
        return Colors.green;
      case 'cancelled':
        return Colors.red;
      default:
        return Colors.blue;
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Available Time Slots'),
        backgroundColor: Colors.deepPurple,
        foregroundColor: Colors.white,
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : _error != null
          ? Center(child: Text(_error!))
          : _slots.isEmpty
          ? const Center(
          child: Text('No available slots for this date'))
          : Column(
        children: [
          Padding(
            padding: const EdgeInsets.all(16.0),
            child: Card(
              child: Padding(
                padding: const EdgeInsets.all(16.0),
                child: Column(
                  children: [
                    Text(
                      DateFormat('EEEE, MMMM d')
                          .format(widget.selectedDate),
                      style: const TextStyle(
                        fontSize: 20,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(height: 8),
                    const Text(
                      'Select an available time slot',
                      style: TextStyle(fontSize: 16),
                    ),
                  ],
                ),
              ),
            ),
          ),
          Expanded(
            child: ListView.builder(
              padding: const EdgeInsets.symmetric(horizontal: 16),
              itemCount: _slots.length,
              itemBuilder: (context, index) {
                final slot = _slots[index];
                final isAvailable = slot['status'] == 'available';

                return Card(
                  margin: const EdgeInsets.only(bottom: 12),
                  color: _selectedSlotId == slot['id']
                      ? Colors.deepPurple.withOpacity(0.1)
                      : null,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                    side: BorderSide(
                      color: _selectedSlotId == slot['id']
                          ? Colors.deepPurple
                          : Colors.grey.shade300,
                      width: 1,
                    ),
                  ),
                  child: ListTile(
                    title: Text(
                      '${slot['startTime']} - ${slot['endTime']}',
                      style: TextStyle(
                        fontWeight: FontWeight.w500,
                        color: isAvailable
                            ? Colors.black
                            : Colors.grey,
                      ),
                    ),
                    subtitle: Text(
                      slot['status'].toString().toUpperCase(),
                      style: TextStyle(
                        color: _getStatusColor(slot['status']),
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    trailing: isAvailable
                        ? _selectedSlotId == slot['id']
                        ? const Icon(Icons.check_circle,
                        color: Colors.green)
                        : const Icon(
                        Icons.radio_button_unchecked)
                        : const Icon(Icons.lock,
                        color: Colors.orange),
                    onTap: isAvailable
                        ? () => setState(
                            () => _selectedSlotId = slot['id'])
                        : null,
                  ),
                );
              },
            ),
          ),
          if (_selectedSlotId != null)
            Padding(
              padding: const EdgeInsets.all(16.0),
              child: ElevatedButton(
                style: ElevatedButton.styleFrom(
                  minimumSize: const Size(double.infinity, 50),
                  backgroundColor: Colors.deepPurple,
                ),
                onPressed: _bookSlot,
                child: const Text(
                  'BOOK APPOINTMENT',
                  style: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                    color: Colors.white,
                  ),
                ),
              ),
            ),
        ],
      ),
    );
  }
}
