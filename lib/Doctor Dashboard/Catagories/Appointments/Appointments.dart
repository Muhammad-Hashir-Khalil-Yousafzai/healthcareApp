import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

class ManageSlotsScreen extends StatefulWidget {
  const ManageSlotsScreen({super.key});

  @override
  State<ManageSlotsScreen> createState() => _ManageSlotsScreenState();
}

class _ManageSlotsScreenState extends State<ManageSlotsScreen> {
  DateTime? _selectedDate;
  TimeOfDay? _startTime;
  TimeOfDay? _endTime;
  int? _slotDuration; // in minutes
  List<TimeOfDay> _slots = [];
  bool _isLoading = false;

  Map<String, List<TimeOfDay>> savedSlots = {};

  @override
  void initState() {
    super.initState();
    _selectedDate = DateTime.now();
    _startTime = const TimeOfDay(hour: 9, minute: 0);
    _endTime = const TimeOfDay(hour: 17, minute: 0);
    _slotDuration = 10;
  }

  void _pickDate() async {
    DateTime? picked = await showDatePicker(
      context: context,
      initialDate: _selectedDate ?? DateTime.now(),
      firstDate: DateTime.now(),
      lastDate: DateTime.now().add(const Duration(days: 90)),
    );
    if (picked != null) {
      setState(() {
        _selectedDate = picked;
        _slots = [];
      });
    }
  }

  Future<TimeOfDay?> _pickTime(TimeOfDay initialTime) async {
    return await showTimePicker(context: context, initialTime: initialTime);
  }

  void _generateSlots() async {
    if (_selectedDate == null || _startTime == null || _endTime == null || _slotDuration == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text("Please fill all fields."),
          backgroundColor: Colors.red,
        ),
      );
      return;
    }

    setState(() {
      _isLoading = true;
    });

    await Future.delayed(const Duration(seconds: 1)); // Simulated delay

    List<TimeOfDay> slots = [];
    TimeOfDay current = _startTime!;
    while (_isBefore(current, _endTime!)) {
      slots.add(current);
      current = _addMinutes(current, _slotDuration!);
    }

    setState(() {
      _slots = slots;
      _isLoading = false;
    });
  }

  bool _isBefore(TimeOfDay t1, TimeOfDay t2) {
    return t1.hour < t2.hour || (t1.hour == t2.hour && t1.minute < t2.minute);
  }

  TimeOfDay _addMinutes(TimeOfDay time, int minutes) {
    final dt = DateTime(0, 0, 0, time.hour, time.minute).add(Duration(minutes: minutes));
    return TimeOfDay(hour: dt.hour, minute: dt.minute);
  }

  void _saveSlots() {
    if (_selectedDate != null && _slots.isNotEmpty) {
      savedSlots[DateFormat('yyyy-MM-dd').format(_selectedDate!)] = _slots;
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text("Slots saved successfully."),
          backgroundColor: Colors.green,
        ),
      );
      setState(() {
        _slots = [];
        _selectedDate = DateTime.now();
        _startTime = const TimeOfDay(hour: 9, minute: 0);
        _endTime = const TimeOfDay(hour: 17, minute: 0);
        _slotDuration = 30;
      });
    }
  }

  void _viewAllSlots() {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (_) => ViewAllSlotsScreen(savedSlots: savedSlots),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("Manage Slots", style: TextStyle(color: Colors.white)),
        backgroundColor: Colors.deepPurple,
        iconTheme: const IconThemeData(color: Colors.white),
        actions: [
          IconButton(
            icon: const Icon(Icons.calendar_view_month, color: Colors.white),
            tooltip: "View All Slots",
            onPressed: _viewAllSlots,
          ),
        ],
      ),
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: ListView(
          children: [
            ListTile(
              leading: const Icon(Icons.calendar_today, color: Colors.deepPurple),
              title: Text(
                _selectedDate == null
                    ? "Select Date"
                    : "Date: ${DateFormat('dd MMM yyyy').format(_selectedDate!)}",
              ),
              onTap: _pickDate,
            ),
            const SizedBox(height: 10),
            ListTile(
              leading: const Icon(Icons.access_time, color: Colors.deepPurple),
              title: Text(
                _startTime == null ? "Select Start Time" : "Start: ${_startTime!.format(context)}",
              ),
              onTap: () async {
                final picked = await _pickTime(_startTime ?? TimeOfDay.now());
                if (picked != null) setState(() => _startTime = picked);
              },
            ),
            ListTile(
              leading: const Icon(Icons.access_time_filled, color: Colors.deepPurple),
              title: Text(
                _endTime == null ? "Select End Time" : "End: ${_endTime!.format(context)}",
              ),
              onTap: () async {
                final picked = await _pickTime(_endTime ?? TimeOfDay.now());
                if (picked != null) setState(() => _endTime = picked);
              },
            ),
            const SizedBox(height: 10),
            TextFormField(
              initialValue: _slotDuration?.toString(),
              keyboardType: TextInputType.number,
              decoration: const InputDecoration(
                labelText: "Slot Duration (minutes)",
                border: OutlineInputBorder(),
              ),
              onChanged: (value) => _slotDuration = int.tryParse(value),
            ),
            const SizedBox(height: 16),
            _isLoading
                ? const Center(child: CircularProgressIndicator(color: Colors.deepPurple))
                : ElevatedButton.icon(
              icon: const Icon(Icons.timelapse, color: Colors.white),
              label: const Text("Generate Slots", style: TextStyle(color: Colors.white)),
              onPressed: _generateSlots,
              style: ElevatedButton.styleFrom(backgroundColor: Colors.deepPurple),
            ),
            const SizedBox(height: 20),
            if (_slots.isNotEmpty)
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text("Generated Slots:", style: TextStyle(fontWeight: FontWeight.bold)),
                  const SizedBox(height: 10),
                  Wrap(
                    spacing: 10,
                    children: _slots
                        .map((slot) => Chip(
                      label: Text(slot.format(context)),
                      backgroundColor: Colors.deepPurple.shade100,
                    ))
                        .toList(),
                  ),
                  const SizedBox(height: 20),
                  ElevatedButton.icon(
                    icon: const Icon(Icons.save, color: Colors.white),
                    label: const Text("Save Slots", style: TextStyle(color: Colors.white)),
                    onPressed: _saveSlots,
                    style: ElevatedButton.styleFrom(backgroundColor: Colors.deepPurple),
                  )
                ],
              ),
          ],
        ),
      ),
    );
  }
}

class ViewAllSlotsScreen extends StatelessWidget {
  final Map<String, List<TimeOfDay>> savedSlots;

  const ViewAllSlotsScreen({super.key, required this.savedSlots});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("All Slots", style: TextStyle(color: Colors.white)),
        backgroundColor: Colors.deepPurple,
        iconTheme: const IconThemeData(color: Colors.white),
      ),
      body: savedSlots.isEmpty
          ? const Center(child: Text("No slots available."))
          : ListView(
        padding: const EdgeInsets.all(16),
        children: savedSlots.entries.map((entry) {
          return Card(
            child: ExpansionTile(
              title: Text("Date: ${entry.key}"),
              children: entry.value
                  .map(
                    (time) => ListTile(
                  leading: const Icon(Icons.schedule, color: Colors.deepPurple),
                  title: Text(time.format(context)),
                  trailing: const Text("Free"),
                ),
              )
                  .toList(),
            ),
          );
        }).toList(),
      ),
    );
  }
}
