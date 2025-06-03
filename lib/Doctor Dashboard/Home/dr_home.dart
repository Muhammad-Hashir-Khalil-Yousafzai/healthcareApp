import 'dart:ffi';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:healthcare/Doctor%20Dashboard/Catagories/Ad%20Banners/adbanners.dart';
import 'package:healthcare/Doctor%20Dashboard/Catagories/HealthReels/HealthReels.dart';
import 'package:healthcare/Doctor%20Dashboard/Catagories/Location/location.dart';

import 'package:healthcare/Doctor%20Dashboard/Home/message_screen.dart';
import 'package:healthcare/Doctor%20Dashboard/Home/postArticles.dart';
import 'package:healthcare/Doctor%20Dashboard/Home/upload_chat.dart';
import 'package:healthcare/Doctor%20Dashboard/Home/dr_profile_screen.dart';
import 'package:healthcare/UserDashboard/Login_Signup/login_screen.dart';
import '../Catagories/Appointments/Appointments.dart';
import '../Catagories/FindCases/FindCases.dart';
import '../Catagories/MarkedCases/markedCases.dart';

class DrHome extends StatefulWidget {
  const DrHome({super.key});

  @override
  _DrHomeState createState() => _DrHomeState();
}

class _DrHomeState extends State<DrHome> {
  int _selectedIndex = 0;

  final user = FirebaseAuth.instance.currentUser;
  final List<Map<String, dynamic>> doctorFeatures = [
    {"name": "Appointments", "image": 'assets/images/calander.png'},
    {"name": "Find Cases", "image": 'assets/images/Find_cases.png'},
    {"name": "Location", "image": 'assets/images/Location.png'},
    {"name": "Add Reels", "image": 'assets/images/reels.png'},
    {"name": "Ad Banner", "image": 'assets/images/ad.png'},
    {"name": "Marked Cases", "image": 'assets/images/cases.png'},
  ];

  late final List<Widget> _screens;

  @override
  void initState() {
    super.initState();
    _screens = [
      _buildHomeScreen(),
      DoctorMessageScreen(),
      PostArticles(),
      ProfileScreen(),
    ];
  }

  void _onItemTapped(int index) {
    setState(() {
      _selectedIndex = index;
    });
  }

  Widget _buildHomeScreen() {
    return Padding(
      padding: const EdgeInsets.all(12.0),
      child: SingleChildScrollView(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            SizedBox(height: 12),
            GridView.builder(
              shrinkWrap: true,
              physics: NeverScrollableScrollPhysics(),
              itemCount: doctorFeatures.length,
              gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                crossAxisCount: 2,
                crossAxisSpacing: 10,
                mainAxisSpacing: 10,
              ),
              itemBuilder: (context, index) {
                return GestureDetector(
                  onTap: () {
                    String featureName = doctorFeatures[index]['name'];
                    if (featureName == "Find Cases") {
                      Navigator.push(context,
                          MaterialPageRoute(builder: (_) => FindCases()));
                    } else if (featureName == "Location") {
                      Navigator.push(context,
                          MaterialPageRoute(builder: (_) => LocationScreen()));
                    } else if (featureName == "Marked Cases") {
                      Navigator.push(
                        context,
                        MaterialPageRoute(builder: (_) => MarkedCases()),
                      );
                    } else if (featureName == "Appointments") {
                      final doctorId = FirebaseAuth.instance.currentUser?.uid ?? '';
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (_) => ManageSlotsScreen(doctorId: doctorId),
                        ),
                      );
                    }

                    else if (featureName == "Ad Banner") {
                      Navigator.push(
                        context,
                        MaterialPageRoute(builder: (_) => AddBanner()),
                      );
                    }
                    else if (featureName == "Add Reels") {
                      Navigator.push(
                        context,
                        MaterialPageRoute(builder: (_) => AddReelScreen()),
                      );
                    }
                  },
                  child: Card(
                    margin: EdgeInsets.all(8),
                    elevation: 6,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: Center(
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Image.asset(
                            doctorFeatures[index]['image'],
                            height: 65,
                            width: 65,
                          ),
                          SizedBox(height: 10),
                          Text(
                            doctorFeatures[index]['name']!,
                            style: TextStyle(
                              fontSize: 16,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                );
              },
            ),
          ],
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Colors.deepPurple,
        title: Text(
          _selectedIndex == 0
              ? 'Doctor Dashboard'
              : _selectedIndex == 1
                  ? 'Messages'
                  : _selectedIndex == 2
                      ? 'Others'
                      : 'Profile',
          style: TextStyle(
            fontSize: 24,
            fontWeight: FontWeight.bold,
            color: Colors.white,
          ),
        ),
        centerTitle: true,
        leading: Builder(
          builder: (context) {
            return IconButton(
              icon: Icon(Icons.menu, color: Colors.white),
              onPressed: () {
                Scaffold.of(context).openDrawer();
              },
            );
          },
        ),
        actions: [
          IconButton(
            icon: Icon(Icons.notifications, color: Colors.white),
            onPressed: () {},
          ),
        ],
      ),
      drawer: Drawer(
        child: ListView(
          padding: EdgeInsets.zero,
          children: [
            DrawerHeader(
              decoration: BoxDecoration(
                color: Colors.deepPurple,
              ),
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.center,
                children: [
                  CircleAvatar(
                    radius: 30,
                    backgroundImage: AssetImage('assets/images/User.png'),
                  ),
                  SizedBox(width: 15),
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Text(
                        'M Hashir Khalil',
                        style: TextStyle(
                          color: Colors.white,
                          fontSize: 20,
                          fontWeight: FontWeight.bold,
                          overflow: TextOverflow.ellipsis,
                        ),
                        maxLines: 1,
                      ),
                      SizedBox(height: 5),
                      Text(
                        'Healthcare App User',
                        style: TextStyle(
                          color: Colors.white70,
                          fontSize: 14,
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
            // ListTile(
            //   leading: Icon(Icons.person_pin),
            //   title: Text('User Profile'),
            //   onTap: () {
            //     Navigator.push(
            //       context,
            //       MaterialPageRoute(builder: (context) => HomePage()),
            //     );
            //   },
            // ),
            ListTile(
              leading: Icon(Icons.medical_services),
              title: Text('Find Cases'),
              onTap: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(builder: (_) => FindCases()),
                );
              },
            ),
            ListTile(
              leading: Icon(Icons.location_on),
              title: Text('Add Location'),
              onTap: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(builder: (_) => LocationScreen()),
                );
              },
            ),
            Divider(),
            ListTile(
              leading: Icon(Icons.bookmark),
              title: Text('Bookmarks'),
              onTap: () {},
            ),
            ListTile(
              leading: Icon(Icons.contact_mail),
              title: Text('Contact Us'),
              onTap: () {},
            ),
            Divider(),
            ListTile(
              leading: Icon(Icons.settings),
              title: Text('Settings'),
              onTap: () {},
            ),
            ListTile(
              leading: Icon(Icons.upload_file),
              title: Text('Upload Chats'),
              onTap: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                      builder: (context) => UploadDoctorProfileScreen()),
                );
              },
            ),
            ListTile(
              leading: Icon(Icons.logout),
              title: Text('Logout'),
              onTap: () {
                FirebaseAuth.instance.signOut().then((value) {
                  Navigator.pushReplacement(
                    context,
                    MaterialPageRoute(builder: (context) => LoginScreen()),
                  );
                });
              },
            ),
          ],
        ),
      ),
      body: _screens[_selectedIndex],
      bottomNavigationBar: BottomNavigationBar(
        elevation: 0,
        backgroundColor: Colors.transparent,
        currentIndex: _selectedIndex,
        onTap: _onItemTapped,
        selectedItemColor: Colors.deepPurple,
        unselectedItemColor: Colors.grey,
        selectedLabelStyle: const TextStyle(fontWeight: FontWeight.bold),
        items: const [
          BottomNavigationBarItem(
            icon: Icon(Icons.home_rounded),
            activeIcon: Icon(Icons.home_rounded, size: 28),
            label: 'Home',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.message_rounded),
            activeIcon: Icon(Icons.message_rounded, size: 28),
            label: 'Messages',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.article),
            activeIcon: Icon(Icons.article, size: 28),
            label: 'Others',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.person),
            activeIcon: Icon(Icons.person, size: 28),
            label: 'Profile',
          ),
        ],
      ),
    );
  }
}

