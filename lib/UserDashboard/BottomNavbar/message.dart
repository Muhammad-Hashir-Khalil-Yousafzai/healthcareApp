import 'package:flutter/material.dart';
import 'chat.dart';
import 'package:healthcare/UserDashboard/Home/Home.dart';
import 'Others.dart';
import 'profile.dart';

class MessageScreen extends StatefulWidget {
  @override
  _MessageScreenState createState() => _MessageScreenState();
}

class _MessageScreenState extends State<MessageScreen> {
  int _selectedIndex = 1;

  List<String> doctors = [
    'Dr. Smith',
    'Dr. Johnson',
    'Dr. Lee',
    'Dr. Davis',
    'Dr. Clark',
  ];

  List<String> doctorCategories = [
    'Cardiologist',
    'Dermatologist',
    'Neurologist',
    'Pediatrician',
    'Orthopedic',
  ];

  List<Map<String, String>> recentlyOnlineDoctors = [
    {'name': 'Dr. Smith', 'image': 'assets/images/doctor1.png'},
    {'name': 'Dr. Johnson', 'image': 'assets/images/doctor2.png'},
    {'name': 'Dr. Lee', 'image': 'assets/images/doctor3.png'},
  ];

  List<Map<String, String>> doctorImages = [
    {'name': 'Dr. Smith', 'image': 'assets/images/doctor1.png'},
    {'name': 'Dr. Johnson', 'image': 'assets/images/doctor2.png'},
    {'name': 'Dr. Lee', 'image': 'assets/images/doctor3.png'},
    {'name': 'Dr. Davis', 'image': 'assets/images/doctor4.png'},
    {'name': 'Dr. Clark', 'image': 'assets/images/doctor1.png'},
  ];

  TextEditingController _searchController = TextEditingController();

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

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Messages', style: TextStyle(color: Colors.white)),
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
              child: ListView.builder(
                scrollDirection: Axis.horizontal,
                itemCount: recentlyOnlineDoctors.length,
                itemBuilder: (context, index) {
                  return GestureDetector(
                    onTap: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (context) => ChatScreen(
                            doctorName: recentlyOnlineDoctors[index]['name']!,
                          ),
                        ),
                      );
                    },
                    child: Padding(
                      padding: const EdgeInsets.only(right: 12.0),
                      child: Column(
                        children: [
                          CircleAvatar(
                            radius: 35.0,
                            backgroundImage:
                            AssetImage(recentlyOnlineDoctors[index]['image']!),
                          ),
                          SizedBox(height: 5.0),
                          Text(
                            recentlyOnlineDoctors[index]['name']!,
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
                itemCount: doctors.length,
                itemBuilder: (context, index) {
                  return Card(
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12.0),
                    ),
                    elevation: 4,
                    margin: EdgeInsets.only(bottom: 12.0),
                    child: ListTile(
                      onTap: () {
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (context) =>
                                ChatScreen(doctorName: doctors[index]),
                          ),
                        );
                      },
                      title: Text(
                        doctorImages[index]['name']!,
                        style: TextStyle(fontWeight: FontWeight.bold),
                      ),
                      subtitle: Text(doctorCategories[index]),
                      leading: CircleAvatar(
                        backgroundImage:
                        AssetImage(doctorImages[index]['image']!),
                      ),
                      trailing: Icon(Icons.chat, color: Colors.deepPurple),
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
            label: 'Others',          ),
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
