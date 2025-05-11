import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'DeleteConfirmationDialog.dart';

class BookedAppointmentsScreen extends StatefulWidget {
  const BookedAppointmentsScreen({super.key});

  @override
  State<BookedAppointmentsScreen> createState() => _BookedAppointmentsScreenState();
}

class _BookedAppointmentsScreenState extends State<BookedAppointmentsScreen> {
  List<Map<String, dynamic>> bookedAppointments = [
    {
      'doctor': 'Dr. Ahsan Iqbal',
      'specialty': 'Cardiologist',
      'date': DateTime(2025, 5, 12),
      'time': TimeOfDay(hour: 14, minute: 30),
    },
    {
      'doctor': 'Dr. Rabia Shah',
      'specialty': 'Dermatologist',
      'date': DateTime(2025, 5, 9),
      'time': TimeOfDay(hour: 10, minute: 0),
    },
  ];

  String formatTime(TimeOfDay time) {
    final now = DateTime.now();
    final dt = DateTime(now.year, now.month, now.day, time.hour, time.minute);
    return DateFormat('hh:mm a').format(dt);
  }

  @override
  Widget build(BuildContext context) {
    bookedAppointments.sort((a, b) => a['date'].compareTo(b['date']));

    return Scaffold(
      appBar: AppBar(
        title: Text('Booked Appointments', style: TextStyle(color: Colors.white)),
        backgroundColor: Colors.deepPurple,
        iconTheme: IconThemeData(color: Colors.white),
      ),
      body: bookedAppointments.isEmpty
          ? Center(child: Text("No appointments booked yet."))
          : ListView.builder(
        padding: EdgeInsets.all(12),
        itemCount: bookedAppointments.length,
        itemBuilder: (context, index) {
          final appointment = bookedAppointments[index];
          return Card(
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
            elevation: 3,
            child: ListTile(
              leading: CircleAvatar(
                backgroundColor: Colors.deepPurple,
                child: Icon(Icons.person, color: Colors.white),
              ),
              title: Text(appointment['doctor'], style: TextStyle(fontWeight: FontWeight.bold)),
              subtitle: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text('Specialty: ${appointment['specialty']}'),
                  Text('Date: ${DateFormat('EEE, dd MMM yyyy').format(appointment['date'])}'),
                  Text('Time: ${formatTime(appointment['time'])}'),
                ],
              ),
              trailing: IconButton(
                icon: Icon(Icons.delete, color: Colors.deepPurple),
                onPressed: () async {
                  bool confirmed = await DeleteConfirmationDialog.show(
                    context,
                    title: 'Cancel Appointment',
                    message: 'Are you sure you want to cancel this appointment?',
                  );
                  if (confirmed) {
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
