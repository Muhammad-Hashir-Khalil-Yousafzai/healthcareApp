import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

class BookAppointmentsScreen extends StatefulWidget {
  const BookAppointmentsScreen({super.key});

  @override
  State<BookAppointmentsScreen> createState() => _BookAppointmentsScreenState();
}

class _BookAppointmentsScreenState extends State<BookAppointmentsScreen> {
  final _formKey = GlobalKey<FormState>();

  String? _selectedSpecialty;
  String? _selectedDoctor;
  DateTime? _selectedDate;
  TimeOfDay? _selectedTime;

  final Map<String, List<String>> doctorsBySpecialty = {
    'Cardiologist': ['Dr. Ahsan Iqbal', 'Dr. Rabia Shah'],
    'Dermatologist': ['Dr. Salman Qureshi', 'Dr. Farah Naz'],
    'Neurologist': ['Dr. Adnan Malik', 'Dr. Ayesha Khan'],
    'Dentist': ['Dr. Sana Fatima', 'Dr. Faisal Anwar'],
  };

  Future<void> _pickDate() async {
    DateTime? picked = await showDatePicker(
      context: context,
      initialDate: DateTime.now().add(Duration(days: 1)),
      firstDate: DateTime.now(),
      lastDate: DateTime.now().add(Duration(days: 30)),
    );
    if (picked != null) {
      setState(() => _selectedDate = picked);
    }
  }

  Future<void> _pickTime() async {
    TimeOfDay? picked =
    await showTimePicker(context: context, initialTime: TimeOfDay.now());
    if (picked != null) {
      setState(() => _selectedTime = picked);
    }
  }

  void _submitAppointment() {
    if (_formKey.currentState!.validate() &&
        _selectedDate != null &&
        _selectedTime != null) {
      final appointmentDate =
      DateFormat('dd MMM yyyy').format(_selectedDate!);
      final appointmentTime = _selectedTime!.format(context);

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
              "Appointment booked with $_selectedDoctor on $appointmentDate at $appointmentTime"),
          backgroundColor: Colors.green,
        ),
      );

      setState(() {
        _selectedSpecialty = null;
        _selectedDoctor = null;
        _selectedDate = null;
        _selectedTime = null;
      });
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text("Please fill in all fields and select date/time."),
          backgroundColor: Colors.red,
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Book Appointment', style: TextStyle(color: Colors.white)),
        backgroundColor: Colors.deepPurple,
        iconTheme: IconThemeData(color: Colors.white),
      ),
      body: Padding(
        padding: EdgeInsets.all(18),
        child: Form(
          key: _formKey,
          child: ListView(
            children: [
              DropdownButtonFormField<String>(
                value: _selectedSpecialty,
                items: doctorsBySpecialty.keys.map((specialty) {
                  return DropdownMenuItem<String>(
                    value: specialty,
                    child: Text(specialty),
                  );
                }).toList(),
                decoration: InputDecoration(
                  labelText: 'Select Specialty',
                  border: OutlineInputBorder(),
                ),
                onChanged: (value) {
                  setState(() {
                    _selectedSpecialty = value;
                    _selectedDoctor = null;
                  });
                },
                validator: (value) =>
                value == null ? 'Please select a specialty' : null,
              ),
              SizedBox(height: 16),
              if (_selectedSpecialty != null)
                DropdownButtonFormField<String>(
                  value: _selectedDoctor,
                  items: doctorsBySpecialty[_selectedSpecialty]!.map((doctor) {
                    return DropdownMenuItem<String>(
                      value: doctor,
                      child: Text(doctor),
                    );
                  }).toList(),
                  decoration: InputDecoration(
                    labelText: 'Select Doctor',
                    border: OutlineInputBorder(),
                  ),
                  onChanged: (value) => setState(() => _selectedDoctor = value),
                  validator: (value) =>
                  value == null ? 'Please select a doctor' : null,
                ),
              if (_selectedSpecialty != null) SizedBox(height: 16),
              ListTile(
                title: Text(_selectedDate == null
                    ? 'Select Appointment Date'
                    : 'Date: ${DateFormat('dd MMM yyyy').format(_selectedDate!)}'),
                leading: Icon(Icons.calendar_today, color: Colors.deepPurple),
                onTap: _pickDate,
              ),
              Divider(),
              ListTile(
                title: Text(_selectedTime == null
                    ? 'Select Appointment Time'
                    : 'Time: ${_selectedTime!.format(context)}'),
                leading: Icon(Icons.access_time, color: Colors.deepPurple),
                onTap: _pickTime,
              ),
              Divider(),
              SizedBox(height: 20),
              ElevatedButton.icon(
                icon: Icon(Icons.check_circle),
                label: Text('Confirm Appointment'),
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.deepPurple,
                  padding: EdgeInsets.symmetric(vertical: 14),
                ),
                onPressed: _submitAppointment,
              ),
            ],
          ),
        ),
      ),
    );
  }
}
