import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:healthcare/UserDashboard/Categories/DiseaseCategory/categories.dart';
import 'package:healthcare/UserDashboard/Categories/PhysicalFitness/physical_health.dart';
import 'package:flutter/material.dart';
import 'package:healthcare/UserDashboard/Doctors/DoctorDetailsScreen.dart';
import 'package:healthcare/UserDashboard/Login_Signup/login_screen.dart';
import 'package:shimmer/shimmer.dart';
import '../../Doctor Dashboard/Home/chatbot.dart';
import '../AI_Features/disease_predictor.dart';
import '../BottomNavbar/message.dart';
import 'dart:async';
import '../BottomNavbar/Others.dart';
import '../BottomNavbar/profile.dart';
import '../../Doctor Dashboard/Home/dr_home.dart';

class HomePage extends StatefulWidget {
  const HomePage({super.key});

  @override
  HomePageState createState() => HomePageState();
}

class HomePageState extends State<HomePage> {
  @override
  void initState() {
    super.initState();
    _pageController = PageController();
    _startAutoSlider();
    _fetchUserData();
    _fetchDoctors();
  }

  final List<String> sliderImages = [
    'assets/images/slider1.jpeg',
    'assets/images/slider3.jpeg',
    'assets/images/slider2.jpeg',
  ];


  final List<Map<String, String>> aiFeatures = [
    {
      'title': 'AI Health Consultant',
      'subtitle': 'Ask health-related queries in natural language.',
      'image': 'assets/images/ai_consultant.png'
    },
    {
      'title': 'General Disease Predictor',
      'subtitle': 'Predict disease based on symptoms.',
      'image': 'assets/images/disease_predictor.png'
    },
  ];

  List<Map<String, dynamic>> doctors = [];
  bool _isLoadingDoctors = true;

  Future<void> _fetchDoctors() async {
    setState(() {
      _isLoadingDoctors = true;
    });

    try {
      final querySnapshot = await FirebaseFirestore.instance
          .collection('doctors')
      // Limit to 6 featured doctors
          .get();

      setState(() {
        doctors = querySnapshot.docs.map((doc) {
          final data = doc.data();
          return {
            'id': doc.id, // Important for navigation
            'name': data['basicInfo']['name'] ?? 'Dr. Unknown',
            'image': data['basicInfo']['profileImage'] ??
                'assets/images/doctor1.png',
            'specialty':
            data['professionalInfo']['specialty'] ?? 'General Practitioner',
            'experience': data['professionalInfo']['experience'] ?? 0,
            'rating': 4.9, // You can add this to your doctor document
            'status': data['status']
          };
        }).toList();
        _isLoadingDoctors = false;
      });
    } catch (e) {
      print('Error fetching doctors: $e');
      setState(() {
        _isLoadingDoctors = false;
      });
    }
  }

  final List<Map<String, String>> categories = [
    {'title': 'Heart', 'image': 'assets/images/heart2.png'},
    {'title': 'Mental Health', 'image': 'assets/images/mind.png'},
    {'title': 'Lungs', 'image': 'assets/images/Lungs.png'},
    {'title': 'Physical Health', 'image': 'assets/images/fitness.png'},
    {'title': 'Diabetes', 'image': 'assets/images/diabetes.png'},
    {'title': 'BP', 'image': 'assets/images/Blood_pressure.png'},
  ];

  late PageController _pageController;
  late Timer _timer;

  final _selectedIndex = 0;

  String? userName;
  String? userRole;

  void _startAutoSlider() {
    _timer = Timer.periodic(Duration(seconds: 3), (Timer timer) {
      if (_pageController.page == sliderImages.length - 1) {
        _pageController.jumpToPage(0);
      } else {
        _pageController.nextPage(
            duration: Duration(milliseconds: 300), curve: Curves.easeInOut);
      }
    });
  }

  Future<void> _fetchUserData() async {
    final user = FirebaseAuth.instance.currentUser;
    if (user != null) {
      final doc = await FirebaseFirestore.instance
          .collection('users')
          .doc(user.uid)
          .get();
      if (doc.exists) {
        setState(() {
          userName = doc['name'] ?? 'User';
          userRole = doc['role'] ?? 'user';
        });
      }
    }
  }

  @override
  void dispose() {
    _pageController.dispose();
    _timer.cancel();
    super.dispose();
  }

  void _onItemTapped(int index) {
    if (index == 1) {
      Navigator.pushReplacement(
        context,
        MaterialPageRoute(builder: (context) => MessageScreen()),
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
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Colors.deepPurple,
        leading: Builder(
          builder: (context) {
            return IconButton(
              icon: Icon(Icons.menu,
                  color: Colors.white), // Icon color set to white
              onPressed: () {
                Scaffold.of(context).openDrawer();
              },
            );
          },
        ),
        title: Text(
          'Healthcare App',
          style: TextStyle(
            fontSize: 24,
            fontWeight: FontWeight.bold,
            color: Colors.white, // Text color set to white
          ),
        ),
        centerTitle: true,
        actions: [
          IconButton(
            icon: Icon(Icons.notifications,
                color: Colors.white), // Icon color set to white
            onPressed: () {},
          ),
          PopupMenuButton(
            icon: Icon(Icons.more_vert,
                color: Colors.white), // Icon color set to white
            itemBuilder: (context) => [
              PopupMenuItem(child: Text("Profile")),
              PopupMenuItem(child: Text("Settings")),
              PopupMenuItem(child: Text("Logout")),
            ],
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
                        userName ?? 'Loading...',
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
                        userRole == 'doctor' ? 'Doctor' : 'Healthcare App User',
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

            if (userRole == 'patient')
              ListTile(
                leading: Icon(Icons.person_pin),
                title: Text('Patient Profile'),
                onTap: () {
                  // Add logic for navigating to the patient or app user section
                },
              ),

            if (userRole == 'doctor')
              ListTile(
                leading: Icon(Icons.medical_services),
                title: Text('Doctor Profile'),
                onTap: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(builder: (context) => DrHome()),
                  );
                },
              ),

            Divider(), // Adds a separator line for visual clarity

            // Bookmark Section
            ListTile(
              leading: Icon(Icons.bookmark),
              title: Text('Bookmarks'),
              onTap: () {
                // Add logic for navigating to the bookmarks section
              },
            ),

            // Contact Us Section
            ListTile(
              leading: Icon(Icons.contact_mail),
              title: Text('Contact Us'),
              onTap: () {
                // Add logic for navigating to the contact us section
              },
            ),
            Divider(), // Adds a separator line for visual clarity

            // Settings Section
            ListTile(
              leading: Icon(Icons.settings),
              title: Text('Settings'),
              onTap: () {},
            ),

            // Logout Section
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
      body: _selectedIndex == 0 ? _buildHomeContent() : Container(),
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

  Widget _buildHomeContent() {
    return SingleChildScrollView(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Slider
          SizedBox(height: 30),
          SizedBox(
            height: 150,
            child: PageView.builder(
              controller: _pageController,
              itemCount: sliderImages.length,
              itemBuilder: (context, index) {
                return Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 8.0),
                  child: ClipRRect(
                    borderRadius: BorderRadius.circular(16.0),
                    child: Image.asset(
                      sliderImages[index],
                      fit: BoxFit.cover,
                    ),
                  ),
                );
              },
            ),
          ),
          SizedBox(height: 12),
          // Doctors Section
          _buildDoctorsSection(),
          SizedBox(height: 12),
          // Categories Section
          _buildCategoriesSection(),
          SizedBox(height: 12),
          _buildAIFeaturesSection(),
        ],
      ),
    );
  }

  Widget _buildDoctorsSection() {
    return Padding(
      padding: const EdgeInsets.all(12.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            "Doctors",
            style: TextStyle(
                fontSize: 22,
                fontWeight: FontWeight.bold,
                color: Colors.deepPurple),
          ),
          const SizedBox(height: 8),
          _isLoadingDoctors
              ? SizedBox(
            height: 120,
            child: ListView.builder(
              scrollDirection: Axis.horizontal,
              itemCount: 3,
              itemBuilder: (context, index) {
                return Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 8.0),
                  child: Shimmer.fromColors(
                    baseColor: Colors.grey[300]!,
                    highlightColor: Colors.grey[100]!,
                    child: Column(
                      children: [
                        CircleAvatar(
                          radius: 40,
                          backgroundColor: Colors.white,
                        ),
                        const SizedBox(height: 8),
                        Container(
                          width: 60,
                          height: 14,
                          color: Colors.white,
                        ),
                        const SizedBox(height: 4),
                        Container(
                          width: 50,
                          height: 12,
                          color: Colors.white,
                        ),
                      ],
                    ),
                  ),
                );
              },
            ),
          )
              : doctors.isEmpty
              ? const Text('No doctors found.',
              style: TextStyle(color: Colors.red))
              : SingleChildScrollView(
            scrollDirection: Axis.horizontal,
            child: Row(
              children: doctors.map((doctor) {
                return GestureDetector(
                  onTap: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (context) => DoctorDetailsScreen(
                          docId: doctor['id'],
                        ),
                      ),
                    );
                  },
                  child: Padding(
                    padding:
                    const EdgeInsets.symmetric(horizontal: 8.0),
                    child: Column(
                      children: [
                        Stack(
                          alignment: Alignment.bottomRight,
                          children: [
                            CircleAvatar(
                              backgroundImage: NetworkImage(
                                doctor['image'] ??
                                    'assets/images/doctor1.png',
                              ),
                              radius: 40,
                              backgroundColor: Colors.grey[200],
                              onBackgroundImageError: (_, __) =>
                              const Icon(Icons.person, size: 40),
                            ),
                            if (doctor['status'] == true)
                              Positioned(
                                top: 0,
                                right: 0,
                                child: Container(
                                  width: 16,
                                  height: 16,
                                  decoration: BoxDecoration(
                                    shape: BoxShape.circle,
                                    color: Colors.green,
                                    border: Border.all(
                                      color: Colors.white,
                                      width: 2,
                                    ),
                                  ),
                                ),
                              ),
                          ],
                        ),
                        const SizedBox(height: 8),
                        Text(
                          doctor['name'] ?? 'Doctor',
                          style: const TextStyle(
                              fontWeight: FontWeight.bold,
                              fontSize: 16),
                        ),
                        const SizedBox(height: 4),
                        Text(
                          doctor['specialty'] ?? 'Specialist',
                          style: const TextStyle(color: Colors.grey),
                        ),
                      ],
                    ),
                  ),
                );
              }).toList(),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildCategoriesSection() {
    return Padding(
      padding: const EdgeInsets.all(12.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            "Categories",
            style: TextStyle(
                fontSize: 22,
                fontWeight: FontWeight.bold,
                color: Colors.deepPurple),
          ),
          GridView.builder(
            shrinkWrap: true,
            physics: NeverScrollableScrollPhysics(),
            itemCount: categories.length,
            gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
              crossAxisCount: 2,
            ),
            itemBuilder: (context, index) {
              return GestureDetector(
                onTap: () {
                  if (categories[index]['title'] == 'Physical Health') {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (context) => PhysicalHealthScreen(
                          categoryTitle: "Physical Health",
                        ),
                      ),
                    );
                  } else {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (context) => NewScreen(
                          categoryTitle:
                          categories[index]['title'] ?? 'Unknown Category',
                        ),
                      ),
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
                          categories[index]['image']!,
                          height: 100,
                          width: 100,
                        ),
                        SizedBox(height: 8),
                        Text(
                          categories[index]['title']!,
                          style: TextStyle(
                              fontSize: 16, fontWeight: FontWeight.bold),
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
    );
  }
  Widget _buildAIFeaturesSection() {
    return Padding(
      padding: const EdgeInsets.all(12.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            "AI Features",
            style: TextStyle(fontSize: 22, fontWeight: FontWeight.bold, color: Colors.deepPurple),
          ),
          SizedBox(height: 8),
          Column(
            children: aiFeatures.map((feature) {
              return Card(
                elevation: 4,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Container(
                  height: 80,
                  alignment: Alignment.centerLeft,
                  padding: EdgeInsets.symmetric(horizontal: 16),
                  child: ListTile(
                    contentPadding: EdgeInsets.zero,
                    leading: Image.asset(
                      feature['image']!,
                      height: 50,
                      width: 50,
                      fit: BoxFit.cover,
                    ),
                    title: Text(
                      feature['title']!,
                      style: TextStyle(fontWeight: FontWeight.bold, fontSize: 18),
                    ),
                    onTap: () {
                      if (feature['title'] == 'AI Health Consultant') {
                        Navigator.push(
                          context,
                          MaterialPageRoute(builder: (context) => ChatBotScreen()),
                        );
                      } else if (feature['title'] == 'General Disease Predictor') {
                        Navigator.push(
                          context,
                          MaterialPageRoute(builder: (context) => PredictorScreen()),
                        );
                      }
                    },
                  ),
                ),
              );
            }).toList(),
          ),
        ],
      ),
    );
  }
}


