import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import '../../../../Doctors/DoctorDetailsScreen.dart';

class DoctorListScreen extends StatelessWidget {
  final String categoryTitle;

  const DoctorListScreen({super.key, required this.categoryTitle});

  Future<Map<String, dynamic>?> getDoctorDataIfSpecialtyMatches(String doctorId) async {
    final doc = await FirebaseFirestore.instance.collection('doctors').doc(doctorId).get();
    if (!doc.exists) return null;

    final data = doc.data();
    if (data == null) return null;

    if (data.containsKey('professionalInfo')) {
      final professionalInfo = data['professionalInfo'] as Map<String, dynamic>?;
      if (professionalInfo != null &&
          professionalInfo.containsKey('specialty') &&
          professionalInfo['specialty'] == categoryTitle) {
        return data;
      }
    }

    return null;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white, // ✅ White background
      appBar: AppBar(
        title: Text('$categoryTitle Doctors'),
        backgroundColor: Colors.deepPurple,
      ),
      body: StreamBuilder<QuerySnapshot>(
        stream: FirebaseFirestore.instance
            .collection('users')
            .where('role', isEqualTo: 'doctor')
            .snapshots(),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          }

          if (!snapshot.hasData || snapshot.data!.docs.isEmpty) {
            return Center(
              child: Text(
                "No doctors found for '$categoryTitle'.",
                style: const TextStyle(fontSize: 16),
                textAlign: TextAlign.center,
              ),
            );
          }

          final users = snapshot.data!.docs;

          return FutureBuilder<List<Map<String, dynamic>?>>(
            future: Future.wait(users.map((userDoc) async {
              final userData = userDoc.data() as Map<String, dynamic>;
              final userId = userDoc.id;
              final doctorData = await getDoctorDataIfSpecialtyMatches(userId);
              if (doctorData == null) return null;
              return {
                'userData': userData,
                'doctorData': doctorData,
                'userId': userId,
              };
            }).toList()),
            builder: (context, filteredSnapshot) {
              if (filteredSnapshot.connectionState == ConnectionState.waiting) {
                return const Center(child: CircularProgressIndicator());
              }

              final filteredDoctors = filteredSnapshot.data!
                  .where((element) => element != null)
                  .cast<Map<String, dynamic>>()
                  .toList();

              if (filteredDoctors.isEmpty) {
                return Center(
                  child: Text(
                    "No doctors found for '$categoryTitle'.",
                    style: const TextStyle(fontSize: 16),
                    textAlign: TextAlign.center,
                  ),
                );
              }

              return ListView.builder(
                itemCount: filteredDoctors.length,
                itemBuilder: (context, index) {
                  final doctor = filteredDoctors[index];
                  final userData = doctor['userData'] as Map<String, dynamic>;
                  final doctorData = doctor['doctorData'] as Map<String, dynamic>;

                  final name = userData['name'] ?? 'Unknown';
                  final specialty = userData['specialization'] ?? 'N/A';
                  final clinicAddress = doctorData['contactInfo']?['clinicAddress'] ?? 'No address';
                  final profilePicUrl = userData['profilePic'];

                  return Container(
                    margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(12),
                      border: Border(
                        bottom: BorderSide(width: 1, color: Colors.deepPurple), // bottom line
                      ),
                    ),

                    child: InkWell(
                      borderRadius: BorderRadius.circular(12),
                      onTap: () {
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (context) => DoctorDetailsScreen(docId: doctor['userId']),
                          ),
                        );
                      },
                      child: Padding(
                        padding: const EdgeInsets.all(16),
                        child: Row(
                          children: [
                            profilePicUrl != null
                                ? ClipRRect(
                              borderRadius: BorderRadius.circular(50),
                              child: Image.network(
                                profilePicUrl,
                                height: 56,
                                width: 56,
                                fit: BoxFit.cover,
                                errorBuilder: (_, __, ___) => CircleAvatar(
                                  radius: 28,
                                  backgroundColor: Colors.deepPurple.shade100,
                                  child: const Icon(Icons.person, color: Colors.deepPurple),
                                ),
                              ),
                            )
                                : CircleAvatar(
                              radius: 28,
                              backgroundColor: Colors.deepPurple.shade100,
                              child: const Icon(Icons.person, color: Colors.deepPurple),
                            ),
                            const SizedBox(width: 16),
                            Expanded(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(
                                    name,
                                    style: const TextStyle(
                                      fontSize: 18,
                                      fontWeight: FontWeight.bold,
                                      color: Colors.black87,
                                    ),
                                  ),
                                  const SizedBox(height: 4),
                                  Text(
                                    specialty,
                                    style: const TextStyle(
                                      fontSize: 15,
                                      fontWeight: FontWeight.w500,
                                      color: Colors.deepPurple,
                                    ),
                                  ),
                                  const SizedBox(height: 6),
                                  Row(
                                    children: [
                                      const Icon(Icons.location_on, size: 16, color: Colors.grey),
                                      const SizedBox(width: 4),
                                      Expanded(
                                        child: Text(
                                          clinicAddress,
                                          style: const TextStyle(
                                            fontSize: 13,
                                            color: Colors.grey,
                                          ),
                                          overflow: TextOverflow.ellipsis,
                                        ),
                                      ),
                                    ],
                                  ),
                                ],
                              ),
                            ),
                            const Icon(Icons.arrow_forward_ios, size: 18, color: Colors.deepPurple),
                          ],
                        ),
                      ),
                    ),
                  );
                },
              );
            },
          );
        },
      ),
    );
  }
}
