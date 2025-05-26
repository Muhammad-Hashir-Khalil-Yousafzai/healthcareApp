import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'DeleteConfirmationDialog.dart';

class BookedAppointmentsScreen extends StatefulWidget {
  const BookedAppointmentsScreen({super.key});

  @override
  State<BookedAppointmentsScreen> createState() => _BookedAppointmentsScreenState();
}

class _BookedAppointmentsScreenState extends State<BookedAppointmentsScreen> {
  List<Map<String, dynamic>> bookedAppointments = [];
  bool _isLoading = true;
  String? _error;

  @override
  void initState() {
    super.initState();
    _fetchBookedAppointments();
  }

  Future<void> _fetchBookedAppointments() async {
    setState(() {
      _isLoading = true;
      _error = null;
    });
    try {
      final user = FirebaseAuth.instance.currentUser;
      if (user == null) {
        setState(() {
          _error = 'User not logged in.';
          _isLoading = false;
        });
        return;
      }
      final userId = user.uid;
      // Query all doctors' booked subcollections for appointments booked by this user
      final doctorsSnapshot = await FirebaseFirestore.instance.collection('doctors').get();
      List<Map<String, dynamic>> allAppointments = [];
      for (var doc in doctorsSnapshot.docs) {
        final bookedSnapshot = await doc.reference.collection('booked')
            .where('bookedById', isEqualTo: userId)
            .get();
        for (var bookedDoc in bookedSnapshot.docs) {
          final data = bookedDoc.data();
          allAppointments.add({
            'doctor': doc.data()['basicInfo']?['name'] ?? 'Doctor',
            'specialty': doc.data()['professionalInfo']?['specialty'] ?? '',
            'date': data['date'],
            'startTime': data['startTime'],
            'endTime': data['endTime'],
            'docId': doc.id,
            'bookedId': bookedDoc.id,
          });
        }
      }
      setState(() {
        bookedAppointments = allAppointments;
        _isLoading = false;
      });
    } catch (e) {
      setState(() {
        _error = 'Failed to fetch appointments: $e';
        _isLoading = false;
      });
    }
  }

  String formatTime(String time) {
    // time is in format '9:00 AM' or '14:00'
    try {
      final dt = DateFormat.jm().parse(time);
      return DateFormat('hh:mm a').format(dt);
    } catch (_) {
      return time;
    }
  }

  @override
  Widget build(BuildContext context) {
    bookedAppointments.sort((a, b) => (a['date'] ?? '').compareTo(b['date'] ?? ''));

    return Scaffold(
      appBar: AppBar(
        title: const Text('Booked Appointments', style: TextStyle(color: Colors.white)),
        backgroundColor: Colors.deepPurple,
        iconTheme: const IconThemeData(color: Colors.white),
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : _error != null
          ? Center(child: Text(_error!))
          : bookedAppointments.isEmpty
          ? const Center(child: Text("No appointments booked yet."))
          : ListView.builder(
        padding: const EdgeInsets.all(12),
        itemCount: bookedAppointments.length,
        itemBuilder: (context, index) {
          final appointment = bookedAppointments[index];
          return Card(
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
            elevation: 3,
            child: ListTile(
              leading: const CircleAvatar(
                backgroundColor: Colors.deepPurple,
                child: Icon(Icons.person, color: Colors.white),
              ),
              title: Text(appointment['doctor'], style: const TextStyle(fontWeight: FontWeight.bold)),
              subtitle: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text('Specialty: ${appointment['specialty']}'),
                  Text('Date: ${appointment['date']}'),
                  Text('Time: ${appointment['startTime']} - ${appointment['endTime']}'),
                ],
              ),
              trailing: IconButton(
                icon: const Icon(Icons.delete, color: Colors.deepPurple),
                onPressed: () async {
                  bool confirmed = await DeleteConfirmationDialog.show(
                    context,
                    title: 'Cancel Appointment',
                    message: 'Are you sure you want to cancel this appointment?',
                  );
                  if (confirmed) {
                    // Delete from Firestore
                    await FirebaseFirestore.instance
                        .collection('doctors')
                        .doc(appointment['docId'])
                        .collection('booked')
                        .doc(appointment['bookedId'])
                        .delete();
                    // Also update the slot to be available again
                    final slotsQuery = await FirebaseFirestore.instance
                        .collection('doctors')
                        .doc(appointment['docId'])
                        .collection('slots')
                        .where('date', isEqualTo: appointment['date'])
                        .where('startTime', isEqualTo: appointment['startTime'])
                        .where('endTime', isEqualTo: appointment['endTime'])
                        .get();
                    for (var slotDoc in slotsQuery.docs) {
                      await slotDoc.reference.update({
                        'isBooked': false,
                        'status': 'available',
                      });
                    }
                    setState(() {
                      bookedAppointments.removeAt(index);
                    });
                  }
                },
              ),
            ),
          );
        },
      ),
    );
  }
}
