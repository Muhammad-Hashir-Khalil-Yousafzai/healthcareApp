import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

class ManageSlotsScreen extends StatefulWidget {
  final String doctorId;

  const ManageSlotsScreen({super.key, required this.doctorId});

  @override
  State<ManageSlotsScreen> createState() => _ManageSlotsScreenState();
}

class _ManageSlotsScreenState extends State<ManageSlotsScreen> {
  DateTime? _selectedDate;
  TimeOfDay? _startTime;
  TimeOfDay? _endTime;
  int? _slotDuration; // in minutes
  List<TimeSlot> _slots = [];
  bool _isLoading = false;
  Set<int> _selectedSlotIndexes = {}; // For multi-select
  bool _multiSelectMode = false;

  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  @override
  void initState() {
    super.initState();
    _selectedDate = DateTime.now();
    _startTime = const TimeOfDay(hour: 9, minute: 0);
    _endTime = const TimeOfDay(hour: 17, minute: 0);
    _slotDuration = 30;
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
      _loadExistingSlots(picked);
    }
  }

  Future<void> _loadExistingSlots(DateTime date) async {
    setState(() => _isLoading = true);

    final formattedDate = DateFormat('yyyy-MM-dd').format(date);
    final snapshot = await _firestore
        .collection('doctors')
        .doc(widget.doctorId)
        .collection('slots')
        .where('date', isEqualTo: formattedDate)
        .get();

    setState(() {
      _slots = snapshot.docs.map((doc) => TimeSlot.fromFirestore(doc)).toList();
      _isLoading = false;
    });
  }

  Future<TimeOfDay?> _pickTime(TimeOfDay initialTime) async {
    return await showTimePicker(context: context, initialTime: initialTime);
  }

  void _generateSlots() async {
    if (_selectedDate == null ||
        _startTime == null ||
        _endTime == null ||
        _slotDuration == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text("Please fill all fields."),
          backgroundColor: Colors.red,
        ),
      );
      return;
    }

    setState(() => _isLoading = true);

    List<TimeSlot> slots = [];
    TimeOfDay current = _startTime!;
    while (_isBefore(current, _endTime!)) {
      slots.add(TimeSlot(
        startTime: current,
        endTime: _addMinutes(current, _slotDuration!),
        isBooked: false,
      ));
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
    final dt = DateTime(0, 0, 0, time.hour, time.minute)
        .add(Duration(minutes: minutes));
    return TimeOfDay(hour: dt.hour, minute: dt.minute);
  }

  Future<void> _saveSlots() async {
    if (_selectedDate == null || _slots.isEmpty) return;

    setState(() => _isLoading = true);
    final formattedDate = DateFormat('yyyy-MM-dd').format(_selectedDate!);
    final batch = _firestore.batch();

    // First, delete existing slots for this date
    final existingSlots = await _firestore
        .collection('doctors')
        .doc(widget.doctorId)
        .collection('slots')
        .where('date', isEqualTo: formattedDate)
        .get();

    for (var doc in existingSlots.docs) {
      batch.delete(doc.reference);
    }

    // Add new slots
    for (var slot in _slots) {
      final docRef = _firestore
          .collection('doctors')
          .doc(widget.doctorId)
          .collection('slots')
          .doc(); // Auto-generated ID

      batch.set(docRef, {
        'date': formattedDate,
        'startTime': slot.startTime.format(context),
        'endTime': slot.endTime.format(context),
        'isBooked': false,
        'status': 'available',
        'createdAt': FieldValue.serverTimestamp(),
      });
    }

    try {
      await batch.commit();
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text("Slots saved successfully."),
          backgroundColor: Colors.deepPurple,
        ),
      );
      setState(() {
        _slots = [];
        _selectedDate = DateTime.now();
        _startTime = const TimeOfDay(hour: 9, minute: 0);
        _endTime = const TimeOfDay(hour: 17, minute: 0);
        _slotDuration = 30;
      });
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text("Error saving slots: $e"),
          backgroundColor: Colors.red,
        ),
      );
    } finally {
      setState(() => _isLoading = false);
    }
  }

  Future<void> _deleteAllSlotsForDate() async {
    if (_selectedDate == null) return;
    final formattedDate = DateFormat('yyyy-MM-dd').format(_selectedDate!);
    final confirm = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('Delete All Slots?'),
        content:
        Text('Are you sure you want to delete all slots for this date?'),
        actions: [
          TextButton(
              onPressed: () => Navigator.pop(ctx, false),
              child: const Text('Cancel')),
          TextButton(
              onPressed: () => Navigator.pop(ctx, true),
              child: const Text('Delete', style: TextStyle(color: Colors.red))),
        ],
      ),
    );
    if (confirm != true) return;
    setState(() => _isLoading = true);
    final batch = _firestore.batch();
    final existingSlots = await _firestore
        .collection('doctors')
        .doc(widget.doctorId)
        .collection('slots')
        .where('date', isEqualTo: formattedDate)
        .get();
    for (var doc in existingSlots.docs) {
      batch.delete(doc.reference);
    }
    try {
      await batch.commit();
      setState(() => _slots = []);
      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(
          content: Text('All slots deleted.'),
          backgroundColor: Colors.deepPurple));
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Error: $e'), backgroundColor: Colors.red));
    } finally {
      setState(() => _isLoading = false);
    }
  }

  Future<void> _deleteSlot(int index) async {
    final slot = _slots[index];
    final formattedDate = DateFormat('yyyy-MM-dd').format(_selectedDate!);
    final confirm = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('Delete Slot?'),
        content: Text('Delete slot at ${slot.startTime.format(context)}?'),
        actions: [
          TextButton(
              onPressed: () => Navigator.pop(ctx, false),
              child: const Text('Cancel')),
          TextButton(
              onPressed: () => Navigator.pop(ctx, true),
              child: const Text('Delete', style: TextStyle(color: Colors.red))),
        ],
      ),
    );
    if (confirm != true) return;
    setState(() => _isLoading = true);
    final query = await _firestore
        .collection('doctors')
        .doc(widget.doctorId)
        .collection('slots')
        .where('date', isEqualTo: formattedDate)
        .where('startTime', isEqualTo: TimeSlot._formatTime(slot.startTime))
        .get();
    for (var doc in query.docs) {
      await doc.reference.delete();
    }
    setState(() {
      _slots.removeAt(index);
      _isLoading = false;
    });
    ScaffoldMessenger.of(context).showSnackBar(const SnackBar(
        content: Text('Slot deleted.'), backgroundColor: Colors.deepPurple));
  }

  Future<void> _deleteSelectedSlots() async {
    if (_selectedSlotIndexes.isEmpty) return;
    final confirm = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('Delete Selected Slots?'),
        content: Text('Delete ${_selectedSlotIndexes.length} selected slots?'),
        actions: [
          TextButton(
              onPressed: () => Navigator.pop(ctx, false),
              child: const Text('Cancel')),
          TextButton(
              onPressed: () => Navigator.pop(ctx, true),
              child: const Text('Delete', style: TextStyle(color: Colors.red))),
        ],
      ),
    );
    if (confirm != true) return;
    setState(() => _isLoading = true);
    final formattedDate = DateFormat('yyyy-MM-dd').format(_selectedDate!);
    final batch = _firestore.batch();
    for (final idx in _selectedSlotIndexes) {
      final slot = _slots[idx];
      final query = await _firestore
          .collection('doctors')
          .doc(widget.doctorId)
          .collection('slots')
          .where('date', isEqualTo: formattedDate)
          .where('startTime', isEqualTo: TimeSlot._formatTime(slot.startTime))
          .get();
      for (var doc in query.docs) {
        batch.delete(doc.reference);
      }
    }
    try {
      await batch.commit();
      setState(() {
        _slots = [
          for (int i = 0; i < _slots.length; i++)
            if (!_selectedSlotIndexes.contains(i)) _slots[i]
        ];
        _selectedSlotIndexes.clear();
        _multiSelectMode = false;
      });
      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(
          content: Text('Selected slots deleted.'),
          backgroundColor: Colors.deepPurple));
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Error: $e'), backgroundColor: Colors.red));
    } finally {
      setState(() => _isLoading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title:
        const Text("Manage Slots", style: TextStyle(color: Colors.white)),
        backgroundColor: Colors.deepPurple,
        iconTheme: const IconThemeData(color: Colors.white),
        actions: [
          if (_slots.isNotEmpty && !_multiSelectMode)
            IconButton(
              icon: const Icon(Icons.delete_forever),
              tooltip: 'Delete all slots for this date',
              onPressed: _deleteAllSlotsForDate,
            ),
          if (_slots.isNotEmpty && !_multiSelectMode)
            IconButton(
              icon: const Icon(Icons.select_all),
              tooltip: 'Select multiple slots',
              onPressed: () => setState(() => _multiSelectMode = true),
            ),
          if (_multiSelectMode)
            IconButton(
              icon: const Icon(Icons.delete),
              tooltip: 'Delete selected slots',
              onPressed: _deleteSelectedSlots,
            ),
          if (_multiSelectMode)
            IconButton(
              icon: const Icon(Icons.close),
              tooltip: 'Cancel multi-select',
              onPressed: () => setState(() {
                _multiSelectMode = false;
                _selectedSlotIndexes.clear();
              }),
            ),
          IconButton(
            icon: const Icon(Icons.view_list),
            onPressed: () {
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (context) => ViewAllSlotsScreen(
                    doctorId: widget.doctorId,
                  ),
                ),
              );
            },
          ),
        ],
      ),
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: ListView(
          children: [
            ListTile(
              leading:
              const Icon(Icons.calendar_today, color: Colors.deepPurple),
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
                _startTime == null
                    ? "Select Start Time"
                    : "Start: ${_startTime!.format(context)}",
              ),
              onTap: () async {
                final picked = await _pickTime(_startTime ?? TimeOfDay.now());
                if (picked != null) setState(() => _startTime = picked);
              },
            ),
            ListTile(
              leading: const Icon(Icons.access_time_filled,
                  color: Colors.deepPurple),
              title: Text(
                _endTime == null
                    ? "Select End Time"
                    : "End: ${_endTime!.format(context)}",
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
                ? const Center(
                child: CircularProgressIndicator(color: Colors.deepPurple))
                : ElevatedButton.icon(
              icon: const Icon(Icons.timelapse, color: Colors.white),
              label: const Text("Generate Slots",
                  style: TextStyle(color: Colors.white)),
              onPressed: _generateSlots,
              style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.deepPurple),
            ),
            const SizedBox(height: 20),
            if (_slots.isNotEmpty)
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text("Generated Slots:",
                      style: TextStyle(fontWeight: FontWeight.bold)),
                  const SizedBox(height: 10),
                  Wrap(
                    spacing: 10,
                    children: List.generate(_slots.length, (i) {
                      final slot = _slots[i];
                      final selected = _selectedSlotIndexes.contains(i);
                      return GestureDetector(
                        onTap: _multiSelectMode
                            ? () {
                          setState(() {
                            if (selected) {
                              _selectedSlotIndexes.remove(i);
                            } else {
                              _selectedSlotIndexes.add(i);
                            }
                          });
                        }
                            : () async {
                          // If slots are not yet saved (i.e., just generated), delete locally
                          final confirm = await showDialog<bool>(
                            context: context,
                            builder: (ctx) => AlertDialog(
                              title: const Text('Delete Slot?'),
                              content: Text(
                                  'Delete slot at ${slot.startTime.format(context)}?'),
                              actions: [
                                TextButton(
                                    onPressed: () =>
                                        Navigator.pop(ctx, false),
                                    child: const Text('Cancel')),
                                TextButton(
                                    onPressed: () =>
                                        Navigator.pop(ctx, true),
                                    child: const Text('Delete',
                                        style: TextStyle(
                                            color: Colors.red))),
                              ],
                            ),
                          );
                          if (confirm == true) {
                            setState(() {
                              _slots.removeAt(i);
                            });
                            ScaffoldMessenger.of(context).showSnackBar(
                              const SnackBar(
                                  content: Text('Slot removed.'),
                                  backgroundColor: Colors.deepPurple),
                            );
                          }
                        },
                        onLongPress: !_multiSelectMode
                            ? () => setState(() {
                          _multiSelectMode = true;
                          _selectedSlotIndexes.add(i);
                        })
                            : null,
                        child: Chip(
                          label: Text(slot.startTime.format(context)),
                          backgroundColor: selected
                              ? Colors.red.shade200
                              : slot.isBooked
                              ? Colors.red.shade100
                              : Colors.deepPurple.shade100,
                          labelStyle: TextStyle(
                            color: selected
                                ? Colors.red
                                : slot.isBooked
                                ? Colors.red
                                : Colors.deepPurple,
                          ),
                          avatar: _multiSelectMode
                              ? Icon(
                            selected
                                ? Icons.check_circle
                                : Icons.circle_outlined,
                            color: selected ? Colors.red : Colors.grey,
                          )
                              : null,
                        ),
                      );
                    }),
                  ),
                  const SizedBox(height: 20),
                  ElevatedButton.icon(
                    icon: const Icon(Icons.save, color: Colors.white),
                    label: const Text("Save Slots",
                        style: TextStyle(color: Colors.white)),
                    onPressed: _saveSlots,
                    style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.deepPurple),
                  )
                ],
              ),
          ],
        ),
      ),
    );
  }
}

class TimeSlot {
  final TimeOfDay startTime;
  final TimeOfDay endTime;
  final bool isBooked;
  final String? status;
  final String? date; // Add date field to store the date string

  TimeSlot({
    required this.startTime,
    required this.endTime,
    this.isBooked = false,
    this.status = 'available',
    this.date,
  });

  // Convert Firestore document to TimeSlot
  factory TimeSlot.fromFirestore(DocumentSnapshot doc) {
    final data = doc.data() as Map<String, dynamic>;
    return TimeSlot(
      startTime: _parseTime(data['startTime']),
      endTime: _parseTime(data['endTime']),
      isBooked: data['isBooked'] ?? false,
      status: data['status'] ?? 'available',
      date: data['date'],
    );
  }

  // Convert TimeSlot to Firestore data
  Map<String, dynamic> toFirestore() {
    return {
      'date': date,
      'startTime': _formatTime(startTime),
      'endTime': _formatTime(endTime),
      'isBooked': isBooked,
      'status': status,
    };
  }

  // Helper method to parse time string to TimeOfDay
  static TimeOfDay _parseTime(String time) {
    final parts = time.split(' ');
    final timeParts = parts[0].split(':');
    int hour = int.parse(timeParts[0]);
    final minute = int.parse(timeParts[1]);

    if (parts.length > 1 && parts[1] == 'PM' && hour != 12) {
      hour += 12;
    } else if (parts.length > 1 && parts[1] == 'AM' && hour == 12) {
      hour = 0;
    }
    return TimeOfDay(hour: hour, minute: minute);
  }

  // Helper method to format TimeOfDay to string
  static String _formatTime(TimeOfDay time) {
    final hour = time.hourOfPeriod;
    final minute = time.minute.toString().padLeft(2, '0');
    final period = time.period == DayPeriod.am ? 'AM' : 'PM';
    return '$hour:$minute $period';
  }
}

class ViewAllSlotsScreen extends StatefulWidget {
  final String doctorId;

  const ViewAllSlotsScreen({super.key, required this.doctorId});

  @override
  State<ViewAllSlotsScreen> createState() => _ViewAllSlotsScreenState();
}

class _ViewAllSlotsScreenState extends State<ViewAllSlotsScreen> {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  Map<String, List<TimeSlot>> _groupedSlots = {};
  bool _isLoading = true;
  String? _error;
  bool _multiSelectMode = false;
  final Set<_SlotSelection> _selectedSlots = {};

  @override
  void initState() {
    super.initState();
    _loadSlots();
  }

  Future<void> _loadSlots() async {
    setState(() {
      _isLoading = true;
      _error = null;
    });

    try {
      print('Fetching slots for doctor: \\${widget.doctorId}');

      final snapshot = await _firestore
          .collection('doctors')
          .doc(widget.doctorId)
          .collection('slots')
          .orderBy('date')
      // .orderBy('startTime') // Uncomment this and create index for production
          .get();

      print('Found \\${snapshot.docs.length} slots');

      final slots = snapshot.docs
          .map((doc) {
        try {
          return TimeSlot.fromFirestore(doc);
        } catch (e) {
          print('Error parsing document \\${doc.id}: \\${e}');
          return null;
        }
      })
          .whereType<TimeSlot>()
          .toList();

      print('Successfully parsed \\${slots.length} slots');

      // Group by date
      final Map<String, List<TimeSlot>> newGroupedSlots = {};
      for (final slot in slots) {
        final date = slot.date ?? 'Unknown Date';
        newGroupedSlots.putIfAbsent(date, () => []).add(slot);
      }

      print('Grouped into \\${newGroupedSlots.length} dates');

      setState(() {
        _groupedSlots = newGroupedSlots;
        _isLoading = false;
      });
    } catch (e) {
      print('Error loading slots: \\${e}');
      String errorMsg = 'Failed to load slots: \\${e.toString()}';
      if (e.toString().contains('failed-precondition')) {
        errorMsg =
        'Firestore requires a composite index for this query. Please create the index in the Firebase console as suggested in the error message.';
      }
      setState(() {
        _error = errorMsg;
        _isLoading = false;
      });
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
        return Colors.deepPurple;
    }
  }

  Future<void> _deleteSelectedSlots() async {
    if (_selectedSlots.isEmpty) return;
    final confirm = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('Delete Selected Slots?'),
        content: Text('Delete ${_selectedSlots.length} selected slots?'),
        actions: [
          TextButton(
              onPressed: () => Navigator.pop(ctx, false),
              child: const Text('Cancel')),
          TextButton(
              onPressed: () => Navigator.pop(ctx, true),
              child: const Text('Delete', style: TextStyle(color: Colors.red))),
        ],
      ),
    );
    if (confirm != true) return;
    setState(() => _isLoading = true);
    final batch = _firestore.batch();
    for (final sel in _selectedSlots) {
      final snapshot = await _firestore
          .collection('doctors')
          .doc(widget.doctorId)
          .collection('slots')
          .where('date', isEqualTo: sel.date)
          .where('startTime',
          isEqualTo: TimeSlot._formatTime(sel.slot.startTime))
          .get();
      for (var doc in snapshot.docs) {
        batch.delete(doc.reference);
      }
    }
    try {
      await batch.commit();
      setState(() {
        for (final sel in _selectedSlots) {
          _groupedSlots[sel.date]?.remove(sel.slot);
        }
        _selectedSlots.clear();
        _multiSelectMode = false;
      });
      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(
          content: Text('Selected slots deleted.'),
          backgroundColor: Colors.deepPurple));
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Error: $e'), backgroundColor: Colors.red));
    } finally {
      setState(() => _isLoading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("All Slots", style: TextStyle(color: Colors.white)),
        backgroundColor: Colors.deepPurple,
        iconTheme: const IconThemeData(color: Colors.white),
        actions: [
          if (_multiSelectMode)
            IconButton(
              icon: const Icon(Icons.delete),
              tooltip: 'Delete selected slots',
              onPressed: _deleteSelectedSlots,
            ),
          if (_multiSelectMode)
            IconButton(
              icon: const Icon(Icons.close),
              tooltip: 'Cancel multi-select',
              onPressed: () => setState(() {
                _multiSelectMode = false;
                _selectedSlots.clear();
              }),
            ),
          IconButton(
            icon: const Icon(Icons.refresh),
            onPressed: _loadSlots,
          ),
        ],
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : _error != null
          ? Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Text(_error!),
            const SizedBox(height: 20),
            ElevatedButton(
              onPressed: _loadSlots,
              child: const Text('Retry'),
            ),
          ],
        ),
      )
          : _groupedSlots.isEmpty
          ? const Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.calendar_today, size: 64),
            SizedBox(height: 16),
            Text('No slots available'),
          ],
        ),
      )
          : RefreshIndicator(
        onRefresh: _loadSlots,
        child: ListView(
          padding: const EdgeInsets.all(16),
          children: _groupedSlots.entries.map((entry) {
            return Card(
              margin: const EdgeInsets.only(bottom: 16),
              child: ExpansionTile(
                title: Text("Date: ${entry.key}"),
                children: entry.value.map((slot) {
                  final sel =
                  _SlotSelection(date: entry.key, slot: slot);
                  final selected = _selectedSlots.contains(sel);
                  return ListTile(
                    leading: const Icon(Icons.schedule,
                        color: Colors.deepPurple),
                    title: Text(
                        "${slot.startTime.format(context)} - ${slot.endTime.format(context)}"),
                    trailing: _multiSelectMode
                        ? Icon(
                        selected
                            ? Icons.check_circle
                            : Icons.circle_outlined,
                        color: selected
                            ? Colors.red
                            : Colors.grey)
                        : null,
                    subtitle: slot.isBooked
                        ? const Text("Booked",
                        style: TextStyle(color: Colors.red))
                        : const Text("Available",
                        style:
                        TextStyle(color: Colors.green)),
                    onTap: _multiSelectMode
                        ? () {
                      setState(() {
                        if (selected) {
                          _selectedSlots.remove(sel);
                        } else {
                          _selectedSlots.add(sel);
                        }
                      });
                    }
                        : null,
                    onLongPress: !_multiSelectMode
                        ? () => setState(() {
                      _multiSelectMode = true;
                      _selectedSlots.add(sel);
                    })
                        : null,
                  );
                }).toList(),
              ),
            );
          }).toList(),
        ),
      ),
    );
  }
}

class _SlotSelection {
  final String date;
  final TimeSlot slot;
  const _SlotSelection({required this.date, required this.slot});
  @override
  bool operator ==(Object other) =>
      other is _SlotSelection &&
          other.date == date &&
          other.slot.startTime == slot.startTime &&
          other.slot.endTime == slot.endTime;
  @override
  int get hashCode =>
      date.hashCode ^ slot.startTime.hashCode ^ slot.endTime.hashCode;
}
