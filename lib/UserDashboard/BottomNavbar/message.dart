import 'package:flutter/material.dart';
import 'chat.dart';
import 'package:healthcare/UserDashboard/Home/Home.dart';
import 'Others.dart';
import 'profile.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:shimmer/shimmer.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:intl/intl.dart';

class MessageScreen extends StatefulWidget {
  const MessageScreen({super.key});

  @override
  _MessageScreenState createState() => _MessageScreenState();
}

class _MessageScreenState extends State<MessageScreen> {
  int _selectedIndex = 1;

  List<Map<String, dynamic>> recentlyOnlineDoctors = [];
  List<Map<String, dynamic>> allDoctors = [];
  bool _isLoadingRecentlyOnline = true;
  bool _isLoadingAllDoctors = true;

  final TextEditingController _searchController = TextEditingController();

  @override
  void initState() {
    super.initState();
    _fetchRecentlyOnlineDoctors();
    _fetchAllDoctors();
  }

  Future<void> _fetchRecentlyOnlineDoctors() async {
    setState(() {
      _isLoadingRecentlyOnline = true;
    });
    final querySnapshot = await FirebaseFirestore.instance
        .collection('users')
        .where('role', isEqualTo: 'doctor')
        .where('status', isEqualTo: true)
        .get();
    setState(() {
      recentlyOnlineDoctors = querySnapshot.docs
          .map((doc) => {
        'uid': doc.id,
        'name': (doc['name'] ?? 'Unknown Doctor').toString(),
        'image': 'assets/images/doctor1.png',
        'status': doc['status'] ?? false,
      })
          .toList();
      _isLoadingRecentlyOnline = false;
    });
  }

  Future<void> _fetchAllDoctors() async {
    setState(() {
      _isLoadingAllDoctors = true;
    });
    final user = FirebaseAuth.instance.currentUser;
    if (user == null) return;

    final patientId = user.uid;

    final querySnapshot = await FirebaseFirestore.instance
        .collection('users')
        .where('role', isEqualTo: 'doctor')
        .get();

    List<Map<String, dynamic>> doctorList = [];

    for (var doc in querySnapshot.docs) {
      final doctorId = doc.id;
      final chatIdList = [doctorId, patientId]..sort();
      final chatDocId = '${chatIdList[0]}_${chatIdList[1]}';

      final chatDoc = await FirebaseFirestore.instance
          .collection('chats')
          .doc(chatDocId)
          .get();

      final lastMessage = chatDoc.exists ? (chatDoc['lastMessage'] ?? '') : '';
      final lastTimestamp = chatDoc.exists ? chatDoc['lastTimestamp'] : null;

      doctorList.add({
        'uid': doctorId,
        'name': doc['name'] ?? 'Unknown Doctor',
        'image': 'assets/images/doctor1.png',
        'lastMessage': lastMessage,
        'lastTimestamp': lastTimestamp,
      });
    }

    setState(() {
      allDoctors = doctorList;
      _isLoadingAllDoctors = false;
    });
  }

  void _onItemTapped(int index) {
    if (index == 0) {
      Navigator.pushReplacement(
        context,
        MaterialPageRoute(builder: (context) => HomePage()),
      );
    } else if (index == 2) {
      Navigator.pushReplacement(
        context,
        MaterialPageRoute(builder: (context) => OtherScreen()),
      );
    } else if (index == 3) {
      Navigator.pushReplacement(
        context,
        MaterialPageRoute(builder: (context) => ProfileScreen()),
      );
    } else {
      setState(() {
        _selectedIndex = index;
      });
    }
  }

  void _onDoctorTap(Map<String, dynamic> doctor) async {
    final user = FirebaseAuth.instance.currentUser;
    if (user == null) return;

    final patientId = user.uid;
    final doctorId = doctor['uid'];
    final doctorName = doctor['name'];

    final chatIdList = [doctorId, patientId]..sort();
    final chatDocId = '${chatIdList[0]}_${chatIdList[1]}';

    final chatRef =
    FirebaseFirestore.instance.collection('chats').doc(chatDocId);

    final chatSnap = await chatRef.get();
    if (!chatSnap.exists) {
      await chatRef.set({
        'doctorId': doctorId,
        'patientId': patientId,
        'lastMessage': '',
        'lastTimestamp': FieldValue.serverTimestamp(),
      });
    }

    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => ChatScreen(
          chatWithName: doctorName,
          chatDocId: chatDocId,
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Messages',
            style: TextStyle(color: const Color.fromARGB(255, 100, 75, 75))),
        backgroundColor: Colors.deepPurple,
        iconTheme: IconThemeData(color: Colors.white),
      ),
      body: SingleChildScrollView(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 8.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Search bar
              TextField(
                controller: _searchController,
                decoration: InputDecoration(
                  hintText: 'Search Doctors...',
                  prefixIcon: Icon(Icons.search),
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12.0),
                  ),
                  filled: true,
                  fillColor: Colors.grey[200],
                ),
              ),
              SizedBox(height: 20.0),

              // Recently Online Doctors Section
              Text(
                'Recently Online',
                style: TextStyle(
                  fontSize: 18.0,
                  fontWeight: FontWeight.bold,
                ),
              ),
              SizedBox(height: 10.0),
              SizedBox(
                height: 100.0,
                child: _isLoadingRecentlyOnline
                    ? ListView.builder(
                  scrollDirection: Axis.horizontal,
                  itemCount: 3,
                  itemBuilder: (context, index) => Padding(
                    padding: const EdgeInsets.only(right: 12.0),
                    child: Shimmer.fromColors(
                      baseColor: Colors.grey[300]!,
                      highlightColor: Colors.grey[100]!,
                      child: Column(
                        children: [
                          CircleAvatar(
                              radius: 35.0,
                              backgroundColor: Colors.white),
                          SizedBox(height: 5.0),
                          Container(
                              width: 60, height: 12, color: Colors.white),
                        ],
                      ),
                    ),
                  ),
                )
                    : ListView.builder(
                  scrollDirection: Axis.horizontal,
                  itemCount: recentlyOnlineDoctors.length,
                  itemBuilder: (context, index) {
                    return GestureDetector(
                      onTap: () =>
                          _onDoctorTap(recentlyOnlineDoctors[index]),
                      child: Padding(
                        padding: const EdgeInsets.only(right: 12.0),
                        child: Column(
                          children: [
                            Stack(
                              children: [
                                CircleAvatar(
                                  radius: 35.0,
                                  backgroundImage: AssetImage(
                                      recentlyOnlineDoctors[index]
                                      ['image']),
                                ),
                                if (recentlyOnlineDoctors[index]
                                ['status'] ==
                                    true)
                                  Positioned(
                                    top: 0,
                                    right: 0,
                                    child: Container(
                                      width: 16,
                                      height: 16,
                                      decoration: BoxDecoration(
                                        shape: BoxShape.circle,
                                        color: Colors.blue,
                                        border: Border.all(
                                          color: Colors.white,
                                          width: 2,
                                        ),
                                      ),
                                    ),
                                  ),
                              ],
                            ),
                            SizedBox(height: 5.0),
                            Text(
                              recentlyOnlineDoctors[index]['name'],
                              style: TextStyle(fontSize: 12.0),
                              overflow: TextOverflow.ellipsis,
                            ),
                          ],
                        ),
                      ),
                    );
                  },
                ),
              ),
              SizedBox(height: 20.0),

              // Chats Section
              Text(
                'Chats',
                style: TextStyle(
                  fontSize: 18.0,
                  fontWeight: FontWeight.bold,
                ),
              ),
              SizedBox(height: 10.0),
              ListView.builder(
                shrinkWrap: true,
                physics: NeverScrollableScrollPhysics(),
                itemCount: _isLoadingAllDoctors ? 3 : allDoctors.length,
                itemBuilder: (context, index) {
                  if (_isLoadingAllDoctors) {
                    return Card(
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12.0),
                      ),
                      elevation: 4,
                      margin: EdgeInsets.only(bottom: 12.0),
                      child: Shimmer.fromColors(
                        baseColor: Colors.grey[300]!,
                        highlightColor: Colors.grey[100]!,
                        child: ListTile(
                          leading: CircleAvatar(backgroundColor: Colors.white),
                          title: Container(
                              width: 80, height: 14, color: Colors.white),
                          subtitle: Container(
                              width: 60, height: 12, color: Colors.white),
                          trailing: Icon(Icons.chat, color: Colors.deepPurple),
                        ),
                      ),
                    );
                  }

                  final lastTimestamp = allDoctors[index]['lastTimestamp'];
                  String formattedTime = '';
                  if (lastTimestamp != null) {
                    DateTime time = (lastTimestamp as Timestamp).toDate();
                    formattedTime = DateFormat('hh:mm a').format(time);
                  }

                  return Card(
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12.0),
                    ),
                    elevation: 4,
                    margin: EdgeInsets.only(bottom: 12.0),
                    child: ListTile(
                      onTap: () => _onDoctorTap(allDoctors[index]),
                      title: Text(
                        allDoctors[index]['name'],
                        style: TextStyle(fontWeight: FontWeight.bold),
                      ),
                      subtitle: Text(
                        allDoctors[index]['lastMessage'] ?? '',
                        style: TextStyle(color: Colors.black54),
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),
                      leading: CircleAvatar(
                        backgroundImage: AssetImage(allDoctors[index]['image']),
                      ),
                      trailing: Text(
                        formattedTime,
                        style: TextStyle(color: Colors.grey),
                      ),
                    ),
                  );
                },
              ),
            ],
          ),
        ),
      ),
      bottomNavigationBar: BottomNavigationBar(
        items: [
          BottomNavigationBarItem(
            icon: Icon(Icons.home),
            label: 'Home',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.message),
            label: 'Messages',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.shield_moon_rounded),
            label: 'Others',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.person),
            label: 'Profile',
          ),
        ],
        currentIndex: _selectedIndex,
        onTap: _onItemTapped,
        selectedItemColor: Colors.deepPurple,
        unselectedItemColor: Colors.grey,
        type: BottomNavigationBarType.fixed,
      ),
    );
  }
}
