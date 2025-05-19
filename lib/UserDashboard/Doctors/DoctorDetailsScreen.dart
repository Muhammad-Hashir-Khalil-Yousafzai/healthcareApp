import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'appointment_calendar.dart';

class DoctorDetailsScreen extends StatefulWidget {
  final String docId;

  const DoctorDetailsScreen({
    required this.docId,
    super.key,
  });

  @override
  State<DoctorDetailsScreen> createState() => _DoctorDetailsScreenState();
}

class _DoctorDetailsScreenState extends State<DoctorDetailsScreen> {
  final double patientSatisfaction = 39.0;
  final double goodReviews = 59.0;
  final double totalScore = 70.0;
  Map<String, dynamic>? doctorData;
  bool isLoading = true;
  String? errorMessage;

  @override
  void initState() {
    super.initState();
    _fetchDoctorData();
  }

  Future<void> _fetchDoctorData() async {
    try {
      final docSnapshot = await FirebaseFirestore.instance
          .collection('doctors')
          .doc(widget.docId)
          .get();

      if (docSnapshot.exists) {
        setState(() {
          doctorData = docSnapshot.data();
          isLoading = false;
        });
      } else {
        setState(() {
          errorMessage = 'Doctor not found';
          isLoading = false;
        });
      }
    } catch (e) {
      setState(() {
        errorMessage = 'Failed to load doctor data';
        isLoading = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    if (isLoading) {
      return Scaffold(
        appBar: AppBar(
          title: const Text('Loading...'),
          backgroundColor: Colors.deepPurple,
        ),
        body: const Center(child: CircularProgressIndicator()),
      );
    }

    if (errorMessage != null) {
      return Scaffold(
        appBar: AppBar(
          title: const Text('Error'),
          backgroundColor: Colors.deepPurple,
        ),
        body: Center(child: Text(errorMessage!)),
      );
    }

    final basicInfo = doctorData?['basicInfo'] ?? {};
    final professionalInfo = doctorData?['professionalInfo'] ?? {};
    final contactInfo = doctorData?['contactInfo'] ?? {};
    final availability = doctorData?['availability'] ?? {};

    return Scaffold(
      appBar: AppBar(
        title: Text(
          basicInfo['name'] ?? 'Doctor',
          style: const TextStyle(color: Colors.white),
        ),
        iconTheme: const IconThemeData(color: Colors.white),
        backgroundColor: Colors.deepPurple,
        elevation: 0,
      ),
      body: Stack(
        children: [
          // Background with gradient overlay
          Positioned.fill(
            child: ColorFiltered(
              colorFilter: ColorFilter.mode(
                Colors.black.withOpacity(0.2),
                BlendMode.darken,
              ),
              child: Image.network(
                basicInfo['profileImage'] ?? 'assets/images/doctor1.png',
                fit: BoxFit.cover,
                errorBuilder: (context, error, stackTrace) => Image.asset(
                  'assets/images/doctor1.png',
                  fit: BoxFit.cover,
                ),
              ),
            ),
          ),

          // Main content
          SingleChildScrollView(
            child: Column(
              children: [
                // Doctor image and basic info overlay
                SizedBox(
                  height: 380,
                  child: Stack(
                    children: [
                      Positioned.fill(
                        child: Container(
                          decoration: BoxDecoration(
                            gradient: LinearGradient(
                              begin: Alignment.topCenter,
                              end: Alignment.bottomCenter,
                              colors: [
                                Colors.transparent,
                                Colors.black.withOpacity(0.7),
                              ],
                            ),
                          ),
                        ),
                      ),
                      Positioned(
                        bottom: 20,
                        left: 20,
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              basicInfo['name'] ?? 'Doctor',
                              style: const TextStyle(
                                fontSize: 28,
                                fontWeight: FontWeight.bold,
                                color: Colors.white,
                              ),
                            ),
                            const SizedBox(height: 4),
                            Text(
                              professionalInfo['specialty'] ?? 'Specialist',
                              style: TextStyle(
                                fontSize: 18,
                                color: Colors.white.withOpacity(0.9),
                              ),
                            ),
                            const SizedBox(height: 8),
                            Row(
                              children: [
                                const Icon(Icons.star,
                                    color: Colors.amber, size: 20),
                                const SizedBox(width: 4),
                                Text(
                                  '${professionalInfo['rating']?.toStringAsFixed(1) ?? '5.0'}',
                                  style: const TextStyle(
                                    color: Colors.white,
                                    fontSize: 16,
                                  ),
                                ),
                                const SizedBox(width: 16),
                                const Icon(Icons.medical_services,
                                    color: Colors.white, size: 20),
                                const SizedBox(width: 4),
                                Text(
                                  '${professionalInfo['experience']?.toString() ?? '0'} yrs exp',
                                  style: const TextStyle(
                                    color: Colors.white,
                                    fontSize: 16,
                                  ),
                                ),
                              ],
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),

                // Doctor details card
                Container(
                  width: double.infinity,
                  padding: const EdgeInsets.all(20),
                  decoration: const BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.only(
                      topLeft: Radius.circular(30),
                      topRight: Radius.circular(30),
                    ),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black12,
                        blurRadius: 10,
                        offset: Offset(0, -5),
                      ),
                    ],
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      // Stats row
                      Container(
                        padding: const EdgeInsets.symmetric(
                            horizontal: 16, vertical: 12),
                        decoration: BoxDecoration(
                          color: Colors.deepPurple.withOpacity(0.1),
                          borderRadius: BorderRadius.circular(15),
                        ),
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.spaceAround,
                          children: [
                            _buildStatItem('Satisfaction', patientSatisfaction),
                            _buildStatItem('Good Reviews', goodReviews),
                            _buildStatItem('Total Score', totalScore),
                          ],
                        ),
                      ),
                      const SizedBox(height: 20),

                      // About section
                      _buildSectionTitle('About Doctor'),
                      Text(
                        professionalInfo['bio'] ?? 'No bio available',
                        style: const TextStyle(
                          fontSize: 16,
                          color: Colors.black87,
                          height: 1.5,
                        ),
                      ),
                      const SizedBox(height: 20),

                      // Qualifications
                      if (professionalInfo['qualifications'] != null &&
                          (professionalInfo['qualifications'] as List)
                              .isNotEmpty)
                        Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            _buildSectionTitle('Qualifications'),
                            const SizedBox(height: 8),
                            Wrap(
                              spacing: 8,
                              runSpacing: 8,
                              children:
                              (professionalInfo['qualifications'] as List)
                                  .map<Widget>((qualification) => Chip(
                                backgroundColor: Colors.deepPurple
                                    .withOpacity(0.1),
                                label: Text(
                                  qualification.toString(),
                                  style: const TextStyle(
                                      color: Colors.deepPurple),
                                ),
                                avatar: const Icon(Icons.verified,
                                    size: 16,
                                    color: Colors.deepPurple),
                              ))
                                  .toList(),
                            ),
                            const SizedBox(height: 20),
                          ],
                        ),

                      // Contact Information
                      // Contact Information
                      _buildSectionTitle('Contact Information'),
                      const SizedBox(height: 8),
                      Card(
                        elevation: 2,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12),
                          side:
                          BorderSide(color: Colors.grey.shade200, width: 1),
                        ),
                        child: Padding(
                          padding: const EdgeInsets.all(16),
                          child: Column(
                            children: [
                              _buildContactInfoItem(
                                icon: Icons.phone,
                                title: "Phone",
                                value: contactInfo['phone'] ?? 'Not provided',
                                color: Colors.green,
                              ),
                              const Divider(height: 24, thickness: 0.5),
                              _buildContactInfoItem(
                                icon: Icons.email,
                                title: "Email",
                                value: basicInfo['email'] ?? 'Not provided',
                                color: Colors.blue,
                              ),
                              const Divider(height: 24, thickness: 0.5),
                              _buildContactInfoItem(
                                icon: Icons.location_on,
                                title: "Clinic Address",
                                value: contactInfo['clinicAddress'] ??
                                    'Address not provided',
                                color: Colors.orange,
                                maxLines: 3,
                              ),
                            ],
                          ),
                        ),
                      ),
                      const SizedBox(height: 20),

                      // Availability
                      // Availability Section
                      _buildSectionTitle('Availability'),
                      const SizedBox(height: 12),
                      Card(
                        elevation: 0,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12),
                          side:
                          BorderSide(color: Colors.grey.shade200, width: 1),
                        ),
                        child: Padding(
                          padding: const EdgeInsets.all(16),
                          child: Column(
                            children: [
                              if (availability['workingDays'] != null) ...[
                                Row(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Icon(Icons.calendar_today,
                                        size: 20, color: Colors.deepPurple),
                                    const SizedBox(width: 16),
                                    Expanded(
                                      child: Wrap(
                                        spacing: 8,
                                        runSpacing: 8,
                                        children: (availability['workingDays']
                                        as List)
                                            .map<Widget>((day) => Chip(
                                          label: Text(
                                            day.toString(),
                                            style: const TextStyle(
                                                fontSize: 14),
                                          ),
                                          backgroundColor: Colors
                                              .deepPurple
                                              .withOpacity(0.1),
                                          shape: RoundedRectangleBorder(
                                            borderRadius:
                                            BorderRadius.circular(
                                                6),
                                          ),
                                          side: BorderSide.none,
                                        ))
                                            .toList(),
                                      ),
                                    ),
                                  ],
                                ),
                                const SizedBox(height: 16),
                              ],
                              if (availability['workingHours'] != null) ...[
                                Row(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Icon(Icons.access_time,
                                        size: 20, color: Colors.deepPurple),
                                    const SizedBox(width: 16),
                                    Container(
                                      padding: const EdgeInsets.symmetric(
                                          horizontal: 12, vertical: 8),
                                      decoration: BoxDecoration(
                                        color: Colors.green.withOpacity(0.1),
                                        borderRadius: BorderRadius.circular(8),
                                      ),
                                      child: Text(
                                        '${availability['workingHours']['start']} - ${availability['workingHours']['end']}',
                                        style: const TextStyle(
                                          fontSize: 15,
                                          fontWeight: FontWeight.w500,
                                          color: Colors.green,
                                        ),
                                      ),
                                    ),
                                  ],
                                ),
                              ],
                            ],
                          ),
                        ),
                      ),
                      const SizedBox(height: 20),

                      // Consultation Fee
                      _buildSectionTitle('Consultation Fee'),
                      Row(
                        crossAxisAlignment: CrossAxisAlignment.end,
                        children: [
                          Text(
                            professionalInfo['consultationFee'] != null
                                ? '\Pkr ${professionalInfo['consultationFee']}'
                                : 'Not specified',
                            style: const TextStyle(
                              fontSize: 24,
                              fontWeight: FontWeight.bold,
                              color: Colors.deepPurple,
                            ),
                          ),
                          const SizedBox(width: 8),
                          Padding(
                            padding: const EdgeInsets.only(
                                bottom: 2), // Better vertical alignment
                            child: Text(
                              '/session',
                              style: TextStyle(
                                fontSize: 16,
                                color: Colors.grey.shade600,
                              ),
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 30),
                      const SizedBox(height: 30),

                      // Book Appointment Button
                      SizedBox(
                        width: double.infinity,
                        child: ElevatedButton(
                          onPressed: () {
                            Navigator.push(
                              context,
                              MaterialPageRoute(
                                builder: (context) => AppointmentCalendar(),
                              ),
                            );
                          },
                          style: ElevatedButton.styleFrom(
                            backgroundColor: Colors.deepPurple,
                            padding: const EdgeInsets.symmetric(vertical: 16),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(12),
                            ),
                            elevation: 3,
                          ),
                          child: const Text(
                            'Book Appointment',
                            style: TextStyle(
                              fontSize: 18,
                              fontWeight: FontWeight.bold,
                              color: Colors.white,
                            ),
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSectionTitle(String title) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 8),
      child: Text(
        title,
        style: const TextStyle(
          fontSize: 20,
          fontWeight: FontWeight.bold,
          color: Colors.deepPurple,
        ),
      ),
    );
  }

  Widget _buildStatItem(String label, double percentage) {
    return Column(
      children: [
        Stack(
          alignment: Alignment.center,
          children: [
            // Background track
            SizedBox(
              width: 70,
              height: 70,
              child: CircularProgressIndicator(
                value: 1,
                strokeWidth: 8, // Thicker stroke
                backgroundColor: Colors.grey[200]!.withOpacity(0.3),
                valueColor: const AlwaysStoppedAnimation<Color>(Colors.grey),
              ),
            ),
            // Animated progress
            TweenAnimationBuilder<double>(
              tween: Tween(begin: 0, end: percentage / 100),
              duration: const Duration(milliseconds: 1500),
              curve: Curves.easeOutQuart,
              builder: (context, value, child) {
                return SizedBox(
                  width: 70,
                  height: 70,
                  child: CircularProgressIndicator(
                    value: value,
                    strokeWidth: 8,
                    backgroundColor: Colors.transparent,
                    valueColor: AlwaysStoppedAnimation<Color>(
                      // Dynamic color based on value
                        Colors.deepPurple),
                  ),
                );
              },
            ),
            // Percentage text
            Text(
              '${percentage.toStringAsFixed(0)}%',
              style: TextStyle(
                fontSize: 18, // Slightly larger
                fontWeight: FontWeight.bold,
                color: Colors.deepPurple, // Dynamic text color
              ),
            ),
          ],
        ),
        const SizedBox(height: 6),
        Text(
          label,
          style: TextStyle(
            fontSize: 14, // Slightly larger
            fontWeight: FontWeight.w500,
            color: Colors.grey[700],
          ),
        ),
      ],
    );
  }
}

Widget _buildContactInfoItem({
  required IconData icon,
  required String title,
  required String value,
  required Color color,
  int maxLines = 1,
}) {
  return Row(
    crossAxisAlignment: CrossAxisAlignment.start,
    children: [
      Container(
        padding: const EdgeInsets.all(8),
        decoration: BoxDecoration(
          color: color.withOpacity(0.1),
          shape: BoxShape.circle,
        ),
        child: Icon(icon, size: 20, color: color),
      ),
      const SizedBox(width: 12),
      Expanded(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              title,
              style: TextStyle(
                fontSize: 14,
                color: Colors.grey.shade600,
                fontWeight: FontWeight.w500,
              ),
            ),
            const SizedBox(height: 4),
            Text(
              value,
              style: const TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.w500,
              ),
              maxLines: maxLines,
              overflow: TextOverflow.ellipsis,
            ),
          ],
        ),
      ),
    ],
  );
}
