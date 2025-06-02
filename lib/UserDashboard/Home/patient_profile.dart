import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';

class PatientProfile extends StatefulWidget {
  @override
  _PatientProfileState createState() => _PatientProfileState();
}

class _PatientProfileState extends State<PatientProfile> {
  int _selectedIndex = 3;

  String _name = 'Loading...';
  String _profession = 'Software Developer';
  String _medicalHistory =
      'No major medical history. Regular checkups recommended.';
  String _email = 'patient@example.com';
  String _phone = '+123 456 7890';

  final _professionController = TextEditingController();
  final _medicalHistoryController = TextEditingController();
  final _emailController = TextEditingController();
  final _phoneController = TextEditingController();

  List<MapEntry<String, String>> _customFields = [];

  @override
  void initState() {
    super.initState();
    _loadUserData();
  }

  Future<void> _loadUserData() async {
    final uid = FirebaseAuth.instance.currentUser?.uid;
    if (uid == null) return;

    final userSnapshot =
    await FirebaseFirestore.instance.collection('users').doc(uid).get();

    final patientSnapshot =
    await FirebaseFirestore.instance.collection('patients').doc(uid).get();

    if (userSnapshot.exists) {
      final userData = userSnapshot.data();
      setState(() {
        _name = userData?['name'] ?? 'Unknown User';
      });
    }

    if (patientSnapshot.exists) {
      final patientData = patientSnapshot.data();
      setState(() {
        _profession = patientData?['profession'] ?? _profession;
        _medicalHistory =
            patientData?['medical_history'] ?? _medicalHistory;
        _email = patientData?['email'] ?? _email;
        _phone = patientData?['phone'] ?? _phone;

        final additional = patientData?['additional_fields'] as Map?;
        if (additional != null) {
          _customFields = additional.entries
              .map<MapEntry<String, String>>(
                  (e) => MapEntry(e.key.toString(), e.value.toString()))
              .toList();
        }
      });
    }
  }

  void _editProfileDialog() {
    _professionController.text = _profession;
    _medicalHistoryController.text = _medicalHistory;
    _emailController.text = _email;
    _phoneController.text = _phone;

    showDialog(
      context: context,
      builder: (context) {
        List<TextEditingController> keyControllers = _customFields
            .map((e) => TextEditingController(text: e.key))
            .toList();
        List<TextEditingController> valueControllers = _customFields
            .map((e) => TextEditingController(text: e.value))
            .toList();

        return StatefulBuilder(
          builder: (context, setStateDialog) => AlertDialog(
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(16),
            ),
            title: Text('Edit Profile'),
            content: SingleChildScrollView(
              child: Column(
                children: [
                  _buildLabeledField('Profession', _professionController),
                  _buildLabeledField('Medical History', _medicalHistoryController, maxLines: 3),
                  _buildLabeledField('Email', _emailController),
                  _buildLabeledField('Phone', _phoneController),
                  SizedBox(height: 12),
                  Divider(),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text('Additional Fields',
                          style: TextStyle(
                              fontWeight: FontWeight.bold,
                              color: Colors.deepPurple)),
                      IconButton(
                        icon: Icon(Icons.add_circle, color: Colors.deepPurple),
                        onPressed: () {
                          setStateDialog(() {
                            keyControllers.add(TextEditingController());
                            valueControllers.add(TextEditingController());
                          });
                        },
                      )
                    ],
                  ),
                  SizedBox(height: 8),
                  for (int i = 0; i < keyControllers.length; i++)
                    Card(
                      margin: EdgeInsets.symmetric(vertical: 6),
                      shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(10)),
                      child: Padding(
                        padding: const EdgeInsets.all(8.0),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            TextField(
                              controller: keyControllers[i],
                              decoration: InputDecoration(
                                labelText: 'Field Name',
                                border: OutlineInputBorder(
                                  borderRadius: BorderRadius.circular(8),
                                ),
                              ),
                            ),
                            SizedBox(height: 8),
                            TextField(
                              controller: valueControllers[i],
                              decoration: InputDecoration(
                                labelText: 'Value',
                                border: OutlineInputBorder(
                                  borderRadius: BorderRadius.circular(8),
                                ),
                              ),
                            ),
                            Align(
                              alignment: Alignment.centerRight,
                              child: IconButton(
                                icon: Icon(Icons.delete, color: Colors.red),
                                onPressed: () {
                                  setStateDialog(() {
                                    keyControllers.removeAt(i);
                                    valueControllers.removeAt(i);
                                  });
                                },
                              ),
                            )
                          ],
                        ),
                      ),
                    ),
                ],
              ),
            ),
            actions: [
              TextButton(
                child: Text('Cancel', style: TextStyle(color: Colors.grey)),
                onPressed: () => Navigator.of(context).pop(),
              ),
              ElevatedButton(
                child: Text('Save'),
                style: ElevatedButton.styleFrom(backgroundColor: Colors.deepPurple),
                onPressed: () async {
                  final uid = FirebaseAuth.instance.currentUser?.uid;
                  if (uid == null) return;

                  setState(() {
                    _profession = _professionController.text;
                    _medicalHistory = _medicalHistoryController.text;
                    _email = _emailController.text;
                    _phone = _phoneController.text;
                    _customFields = List.generate(
                      keyControllers.length,
                          (index) => MapEntry(
                        keyControllers[index].text,
                        valueControllers[index].text,
                      ),
                    );
                  });

                  Map<String, String> additionalFields = {
                    for (var entry in _customFields) entry.key: entry.value
                  };

                  await FirebaseFirestore.instance
                      .collection('patients')
                      .doc(uid)
                      .set({
                    'name': _name,
                    'profession': _profession,
                    'medical_history': _medicalHistory,
                    'email': _email,
                    'phone': _phone,
                    'additional_fields': additionalFields,
                    'timestamp': FieldValue.serverTimestamp(),
                  });

                  Navigator.of(context).pop();
                },
              ),
            ],
          ),
        );
      },
    );
  }

  Widget _buildLabeledField(String label, TextEditingController controller,
      {int maxLines = 1}) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 12.0),
      child: TextField(
        controller: controller,
        maxLines: maxLines,
        decoration: InputDecoration(
          labelText: label,
          border: OutlineInputBorder(borderRadius: BorderRadius.circular(8)),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Profile', style: TextStyle(color: Colors.white)),
        backgroundColor: Colors.deepPurple,
        iconTheme: IconThemeData(color: Colors.white),
        actions: [
          IconButton(
            icon: Icon(Icons.edit, color: Colors.white),
            onPressed: _editProfileDialog,
          ),
        ],
      ),
      body: SingleChildScrollView(
        child: Padding(
          padding: EdgeInsets.all(16.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Profile Header
              Row(
                children: [
                  CircleAvatar(
                    radius: 50,
                    backgroundImage: AssetImage('assets/images/MHK.png'),
                  ),
                  SizedBox(width: 16),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          _name,
                          style: TextStyle(
                            fontSize: 24,
                            fontWeight: FontWeight.bold,
                            color: Colors.deepPurple,
                          ),
                          overflow: TextOverflow.ellipsis,
                          maxLines: 1,
                        ),
                        SizedBox(height: 8),
                        Text(
                          _profession,
                          style: TextStyle(
                            fontSize: 16,
                            color: Colors.grey[600],
                          ),
                          overflow: TextOverflow.ellipsis,
                          maxLines: 1,
                        ),
                      ],
                    ),
                  ),
                ],
              ),
              SizedBox(height: 30),

              // Medical History
              _sectionHeader('Medical History'),
              SizedBox(height: 8),
              Text(
                _medicalHistory,
                style: TextStyle(fontSize: 16, color: Colors.grey[800]),
              ),
              SizedBox(height: 30),

              // Contact Info
              _sectionHeader('Contact Info'),
              SizedBox(height: 8),
              _infoRow(Icons.email, _email),
              SizedBox(height: 16),
              _infoRow(Icons.phone, _phone),
              SizedBox(height: 30),

              // Additional Info
              if (_customFields.isNotEmpty) ...[
                _sectionHeader('Additional Info'),
                SizedBox(height: 8),
                Column(
                  children: _customFields.map((entry) {
                    return Card(
                      shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(10)),
                      elevation: 2,
                      margin: EdgeInsets.only(bottom: 10),
                      child: ListTile(
                        leading: Icon(Icons.info, color: Colors.deepPurple),
                        title: Text(
                          entry.key,
                          style: TextStyle(
                              fontWeight: FontWeight.bold,
                              color: Colors.deepPurple),
                        ),
                        subtitle: Text(
                          entry.value,
                          style: TextStyle(color: Colors.grey[700]),
                        ),
                      ),
                    );
                  }).toList(),
                ),
              ]
            ],
          ),
        ),
      ),
    );
  }

  Widget _sectionHeader(String title) {
    return Text(
      title,
      style: TextStyle(
        fontSize: 18,
        fontWeight: FontWeight.bold,
        color: Colors.deepPurple,
      ),
    );
  }

  Widget _infoRow(IconData icon, String text) {
    return Row(
      children: [
        Icon(icon, color: Colors.deepPurple),
        SizedBox(width: 8),
        Expanded(
          child: Text(
            text,
            style: TextStyle(fontSize: 16, color: Colors.grey[800]),
          ),
        ),
      ],
    );
  }
}
