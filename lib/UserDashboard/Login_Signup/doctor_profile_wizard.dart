import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:intl/intl.dart';

class DoctorProfileWizard extends StatefulWidget {
  final String userId;
  final String specialization;
  final String? email;
  final String? name;

  const DoctorProfileWizard({
    super.key,
    required this.userId,
    required this.specialization,
    this.email,
    this.name,
  });

  @override
  _DoctorProfileWizardState createState() => _DoctorProfileWizardState();
}

class _DoctorProfileWizardState extends State<DoctorProfileWizard> {
  final _formKey = GlobalKey<FormState>();
  int _currentStep = 0;

  // Professional Info
  String _specialty = '';
  final List<String> _qualifications = [];
  final _qualificationController = TextEditingController();
  int _experience = 0;
  String _bio = '';
  double _consultationFee = 0;

  // Contact Info
  String _phone = '';
  String _clinicAddress = '';

  // Availability
  final List<String> _workingDays = [];
  TimeOfDay _startTime = TimeOfDay(hour: 9, minute: 0);
  TimeOfDay _endTime = TimeOfDay(hour: 17, minute: 0);

  @override
  void initState() {
    super.initState();
    _specialty = widget.specialization;
  }

  @override
  void dispose() {
    _qualificationController.dispose();
    super.dispose();
  }

  List<Step> _buildSteps() {
    return [
      Step(
        title: const Text('Professional Info'),
        content: _buildProfessionalInfoStep(),
        isActive: _currentStep >= 0,
        state: _currentStep > 0 ? StepState.complete : StepState.indexed,
      ),
      Step(
        title: const Text('Contact Info'),
        content: _buildContactInfoStep(),
        isActive: _currentStep >= 1,
        state: _currentStep > 1 ? StepState.complete : StepState.indexed,
      ),
      Step(
        title: const Text('Availability'),
        content: _buildAvailabilityStep(),
        isActive: _currentStep >= 2,
        state: StepState.indexed,
      ),
    ];
  }

  Widget _buildProfessionalInfoStep() {
    return Form(
      key: _formKey,
      child: Column(
        children: [
          TextFormField(
            initialValue: _specialty,
            decoration: const InputDecoration(
              labelText: 'Specialty',
              border: OutlineInputBorder(),
            ),
            onChanged: (value) => _specialty = value,
            validator: (value) {
              if (value == null || value.isEmpty) {
                return 'Please enter your specialty';
              }
              return null;
            },
          ),
          const SizedBox(height: 16),
          TextFormField(
            decoration: const InputDecoration(
              labelText: 'Years of Experience',
              border: OutlineInputBorder(),
            ),
            keyboardType: TextInputType.number,
            onChanged: (value) => _experience = int.tryParse(value) ?? 0,
            validator: (value) {
              if (value == null || value.isEmpty) {
                return 'Please enter your experience';
              }
              return null;
            },
          ),
          const SizedBox(height: 16),
          TextFormField(
            decoration: const InputDecoration(
              labelText: 'Consultation Fee',
              border: OutlineInputBorder(),
              prefixText: '\$',
            ),
            keyboardType: TextInputType.number,
            onChanged: (value) =>
                _consultationFee = double.tryParse(value) ?? 0,
            validator: (value) {
              if (value == null || value.isEmpty) {
                return 'Please enter consultation fee';
              }
              return null;
            },
          ),
          const SizedBox(height: 16),
          TextFormField(
            controller: _qualificationController,
            decoration: InputDecoration(
              labelText: 'Add Qualification',
              border: const OutlineInputBorder(),
              suffixIcon: IconButton(
                icon: const Icon(Icons.add),
                onPressed: () {
                  if (_qualificationController.text.isNotEmpty) {
                    setState(() {
                      _qualifications.add(_qualificationController.text);
                      _qualificationController.clear();
                    });
                  }
                },
              ),
            ),
          ),
          if (_qualifications.isNotEmpty) ...[
            const SizedBox(height: 8),
            Wrap(
              spacing: 8,
              children: _qualifications.map((qualification) {
                return Chip(
                  label: Text(qualification),
                  onDeleted: () {
                    setState(() {
                      _qualifications.remove(qualification);
                    });
                  },
                );
              }).toList(),
            ),
          ],
          const SizedBox(height: 16),
          TextFormField(
            decoration: const InputDecoration(
              labelText: 'Bio',
              border: OutlineInputBorder(),
            ),
            maxLines: 3,
            onChanged: (value) => _bio = value,
          ),
        ],
      ),
    );
  }

  Widget _buildContactInfoStep() {
    return Column(
      children: [
        TextFormField(
          decoration: const InputDecoration(
            labelText: 'Phone Number',
            border: OutlineInputBorder(),
            prefixText: '+',
          ),
          keyboardType: TextInputType.phone,
          onChanged: (value) => _phone = value,
          validator: (value) {
            if (value == null || value.isEmpty) {
              return 'Please enter your phone number';
            }
            return null;
          },
        ),
        const SizedBox(height: 16),
        TextFormField(
          decoration: const InputDecoration(
            labelText: 'Clinic Address',
            border: OutlineInputBorder(),
          ),
          onChanged: (value) => _clinicAddress = value,
          validator: (value) {
            if (value == null || value.isEmpty) {
              return 'Please enter clinic address';
            }
            return null;
          },
        ),
      ],
    );
  }

  Widget _buildAvailabilityStep() {
    return Column(
      children: [
        const Text(
          'Select Working Days:',
          style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
        ),
        const SizedBox(height: 8),
        Wrap(
          spacing: 8,
          children: [
            'Monday',
            'Tuesday',
            'Wednesday',
            'Thursday',
            'Friday',
            'Saturday'
          ].map((day) {
            return FilterChip(
              label: Text(day),
              selected: _workingDays.contains(day),
              onSelected: (selected) {
                setState(() {
                  if (selected) {
                    _workingDays.add(day);
                  } else {
                    _workingDays.remove(day);
                  }
                });
              },
            );
          }).toList(),
        ),
        const SizedBox(height: 16),
        ListTile(
          title: const Text('Start Time'),
          trailing: TextButton(
            child: Text(
              _startTime.format(context),
              style: const TextStyle(fontSize: 16),
            ),
            onPressed: () async {
              final time = await showTimePicker(
                context: context,
                initialTime: _startTime,
              );
              if (time != null) {
                setState(() => _startTime = time);
              }
            },
          ),
        ),
        ListTile(
          title: const Text('End Time'),
          trailing: TextButton(
            child: Text(
              _endTime.format(context),
              style: const TextStyle(fontSize: 16),
            ),
            onPressed: () async {
              final time = await showTimePicker(
                context: context,
                initialTime: _endTime,
              );
              if (time != null) {
                setState(() => _endTime = time);
              }
            },
          ),
        ),
      ],
    );
  }

  Future<void> _saveProfile() async {
    if (_formKey.currentState!.validate()) {
      try {
        await FirebaseFirestore.instance
            .collection('doctors')
            .doc(widget.userId)
            .set({
          'basicInfo': {
            'name': widget.name, // Will be updated from users collection
            'email': widget.email, // Will be updated from users collection
          },
          'professionalInfo': {
            'specialty': _specialty,
            'qualifications': _qualifications,
            'experience': _experience,
            'bio': _bio,
            'consultationFee': _consultationFee,
          },
          'contactInfo': {
            'phone': _phone,
            'clinicAddress': _clinicAddress,
          },
          'availability': {
            'workingDays': _workingDays,
            'workingHours': {
              'start':
                  '${_startTime.hour}:${_startTime.minute.toString().padLeft(2, '0')}',
              'end':
                  '${_endTime.hour}:${_endTime.minute.toString().padLeft(2, '0')}',
            },
          },
          'status': false,
          'createdAt': FieldValue.serverTimestamp(),
          'userId': widget.userId,
        });

        // Update user document to mark profile as complete
        await FirebaseFirestore.instance
            .collection('users')
            .doc(widget.userId)
            .update({
          'profileComplete': true,
        });

        Navigator.pop(context); // Return to previous screen
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Profile saved successfully!')),
        );
      } catch (e) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Error saving profile: $e')),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Complete Doctor Profile'),
        backgroundColor: Colors.deepPurple,
        foregroundColor: Colors.white,
      ),
      body: Stepper(
        currentStep: _currentStep,
        steps: _buildSteps(),
        onStepContinue: () {
          if (_currentStep < _buildSteps().length - 1) {
            setState(() => _currentStep++);
          } else {
            _saveProfile();
          }
        },
        onStepCancel: () {
          if (_currentStep > 0) {
            setState(() => _currentStep--);
          } else {
            Navigator.pop(context);
          }
        },
        controlsBuilder: (context, details) {
          return Padding(
            padding: const EdgeInsets.symmetric(vertical: 16),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                if (_currentStep != 0)
                  OutlinedButton(
                    onPressed: details.onStepCancel,
                    child: const Text('Back'),
                  ),
                ElevatedButton(
                  onPressed: details.onStepContinue,
                  child: Text(
                    _currentStep == _buildSteps().length - 1
                        ? 'Save Profile'
                        : 'Next',
                  ),
                ),
              ],
            ),
          );
        },
      ),
    );
  }
}
