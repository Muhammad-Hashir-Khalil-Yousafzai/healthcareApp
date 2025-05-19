import 'package:healthcare/UserDashboard/AI_Features/chatbot.dart';
import 'package:healthcare/UserDashboard/AI_Features/disease_predictor.dart';
import 'package:healthcare/UserDashboard/Categories/DiseaseCategory/categories.dart';
import 'package:healthcare/UserDashboard/Categories/PhysicalFitness/physical_health.dart';
import 'package:flutter/material.dart';
import '../Doctors//DoctorDetailsScreen.dart';
import '../BottomNavbar/message.dart';
import 'dart:async';
import '../BottomNavbar/Others.dart';
import '../BottomNavbar/profile.dart';
import '../../Doctor Dashboard/Home/dr_home.dart';
import '../Login_Signup/signout.dart';



class HomePage extends StatefulWidget {
  const HomePage({super.key});

  @override
  HomePageState createState() => HomePageState();
}

class HomePageState extends State<HomePage> {
  final List<String> sliderImages = [
    'assets/images/slider1.jpeg',
    'assets/images/slider3.jpeg',
    'assets/images/slider2.jpeg',
  ];

  final List<Map<String, String>> doctors = [
    {'name': 'Dr. John Doe', 'image': 'assets/images/doctor1.png', 'speciality': 'Cardiologist'},
    {'name': 'Dr. Khayal Khan', 'image': 'assets/images/doctor2.png', 'speciality': 'Neurologist'},
    {'name': 'Dr. Ajmal Javed', 'image': 'assets/images/doctor3.png', 'speciality': 'Dermatologist'},
    {'name': 'Dr. Arif Elvi', 'image': 'assets/images/doctor4.png', 'speciality': 'Orthopedist'},
  ];

  final List<Map<String, String>> categories = [
    {'title': 'Heart', 'image': 'assets/images/heart2.png'},
    {'title': 'Mental Health', 'image': 'assets/images/mind.png'},
    {'title': 'Lungs', 'image': 'assets/images/Lungs.png'},
    {'title': 'Physical Health', 'image': 'assets/images/fitness.png'},
    {'title': 'Diabetes', 'image': 'assets/images/diabetes.png'},
    {'title': 'BP', 'image': 'assets/images/Blood_pressure.png'},
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


  late PageController _pageController;
  late Timer _timer;

  final _selectedIndex = 0;

  @override
  void initState() {
    super.initState();
    _pageController = PageController();
    _startAutoSlider();
  }

  void _startAutoSlider() {
    _timer = Timer.periodic(Duration(seconds: 3), (Timer timer) {
      if (_pageController.page == sliderImages.length - 1) {
        _pageController.jumpToPage(0);
      } else {
        _pageController.nextPage(duration: Duration(milliseconds: 300), curve: Curves.easeInOut);
      }
    });
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
    }
    else if (index == 3) {
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
              icon: Icon(Icons.menu, color: Colors.white), // Icon color set to white
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
            icon: Icon(Icons.notifications, color: Colors.white), // Icon color set to white
            onPressed: () {},
          ),
          PopupMenuButton(
            icon: Icon(Icons.more_vert, color: Colors.white), // Icon color set to white
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
                crossAxisAlignment: CrossAxisAlignment.center, // Vertically center the items
                children: [
                  CircleAvatar(
                    radius: 30,
                    backgroundImage: AssetImage('assets/images/User.png'), // Replace with user's photo
                  ),
                  SizedBox(width: 15),
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    mainAxisAlignment: MainAxisAlignment.center, // Vertically center the text
                    children: [
                      Text(
                        'M Hashir Khalil', // Replace with dynamic user name
                        style: TextStyle(
                          color: Colors.white,
                          fontSize: 20,
                          fontWeight: FontWeight.bold,
                          overflow: TextOverflow.ellipsis, // Prevent name overflow
                        ),
                        maxLines: 1,
                      ),
                      SizedBox(height: 5),
                      Text(
                        'Healthcare App User', // Replace with dynamic user role or status
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

            // Patient / App User Profile
            ListTile(
              leading: Icon(Icons.person_pin),
              title: Text('User Profile'),
              onTap: () {
                // Add logic for navigating to the patient or app user section
              },
            ),

            // Doctor Profile
            ListTile(
              leading: Icon(Icons.medical_services),
              title: Text('Doctor Profile'),
              onTap: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(builder: (context) => DrHome()), // Navigate to DrHome
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
              onTap: () {AuthService().logout(context);},
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
          _buildAIFeaturesSection(), // NEW AI Features Section

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
          Text(
            "Doctors",
            style: TextStyle(fontSize: 22, fontWeight: FontWeight.bold, color: Colors.deepPurple),
          ),
          SingleChildScrollView(
            scrollDirection: Axis.horizontal,
            child: Row(
              children: doctors.map((doctor) {
                return GestureDetector(
                  onTap: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (context) => DoctorDetailsScreen(
                          doctorName: doctor['name']!,
                          doctorSpeciality: doctor['speciality']!,
                          doctorImage: doctor['image']!,
                        ),
                      ),
                    );
                  },
                  child: Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 8.0),
                    child: Column(
                      children: [
                        CircleAvatar(
                          backgroundImage: AssetImage(doctor['image']!),
                          radius: 40,
                          backgroundColor: Colors.black,
                        ),
                        SizedBox(height: 8),
                        Text(
                          doctor['name']!,
                          style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
                        ),
                        SizedBox(height: 4),
                        Text(
                          doctor['speciality']!,
                          style: TextStyle(color: Colors.grey),
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
            style: TextStyle(fontSize: 22, fontWeight: FontWeight.bold, color: Colors.deepPurple),
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
                          categoryTitle: categories[index]['title'] ?? 'Unknown Category',
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
                          style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
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

