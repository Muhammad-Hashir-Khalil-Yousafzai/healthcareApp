import 'package:flutter/material.dart';
import 'package:healthcare/UserDashboard/BottomNavbar/Others/BookAppointments.dart';
import 'package:healthcare/UserDashboard/BottomNavbar/Others/BookedAppointments.dart';
import 'package:healthcare/UserDashboard/BottomNavbar/Others/DoctorReelsScreen.dart';
import 'package:healthcare/UserDashboard/BottomNavbar/Others/EmergencyGuidance.dart';
import 'package:healthcare/UserDashboard/BottomNavbar/Others/HealthBot.dart';
import 'package:healthcare/UserDashboard/BottomNavbar/Others/PatientsDiaries.dart';
import 'package:healthcare/UserDashboard/BottomNavbar/Others/TopDoctors.dart';
import 'package:healthcare/UserDashboard/Home/Home.dart';
import 'message.dart';
import 'profile.dart';
import 'Others/ShareYourStories.dart';

class OtherScreen extends StatefulWidget {
  const OtherScreen({super.key});

  @override
  _OtherScreenState createState() => _OtherScreenState();


}

class _OtherScreenState extends State<OtherScreen> {
  int _selectedIndex = 2;

  void _onItemTapped(int index) {
    if (index == 0) {
      Navigator.pushReplacement(
        context,
        MaterialPageRoute(builder: (context) => HomePage()),
      );
    } else if (index == 1) {
      Navigator.pushReplacement(
        context,
        MaterialPageRoute(builder: (context) => MessageScreen()),
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
    title: Text('Profile',style: TextStyle(color: Colors.white)),
    backgroundColor: Colors.deepPurple,
    iconTheme: IconThemeData(color: Colors.white)),

      body: ListView(
        padding: EdgeInsets.all(10),
        children: [
          ListTile(
            leading: Icon(Icons.campaign, color: Colors.deepPurple),
            title: Text('Share Your Health Story'),
            subtitle: Text('Let doctors discover and respond to your case voluntarily.'),
            trailing: Icon(Icons.arrow_forward_ios),
            onTap: () {
              Navigator.push(
                context,
                PageRouteBuilder(
                  pageBuilder: (context, animation, secondaryAnimation) =>
                      ShareYourStoriesPage(),
                  transitionsBuilder: (context, animation, secondaryAnimation, child) {
                    const begin = Offset(1.0, 0.0); // slide from right
                    const end = Offset.zero;
                    const curve = Curves.easeInOut;

                    final tween = Tween(begin: begin, end: end).chain(CurveTween(curve: curve));
                    final offsetAnimation = animation.drive(tween);

                    return SlideTransition(position: offsetAnimation, child: child);
                  },
                ),
              );
            },

          ),
          Divider(),

          ListTile(
            leading: Icon(Icons.thumb_up_alt, color: Colors.deepPurple),
            title: Text('Patient Diaries'),
            subtitle: Text('Explore and share real-life recovery stories.'),
            trailing: Icon(Icons.arrow_forward_ios),
            onTap: () {
              Navigator.push(
                context,
                PageRouteBuilder(
                  pageBuilder: (context, animation, secondaryAnimation) =>
                      PatientDiaries(),
                  transitionsBuilder: (context, animation, secondaryAnimation, child) {
                    const begin = Offset(1.0, 0.0); // slide from right
                    const end = Offset.zero;
                    const curve = Curves.easeInOut;

                    final tween = Tween(begin: begin, end: end).chain(CurveTween(curve: curve));
                    final offsetAnimation = animation.drive(tween);

                    return SlideTransition(position: offsetAnimation, child: child);
                  },
                ),
              );
            },          ),
          Divider(),

          ListTile(
            leading: Icon(Icons.movie, color: Colors.deepPurple),
            title: Text('Doctor Reels'),
            subtitle: Text('Watch short videos from certified healthcare experts.'),
            trailing: Icon(Icons.arrow_forward_ios),
            onTap: () {
              Navigator.push(
                context,
                PageRouteBuilder(
                  pageBuilder: (context, animation, secondaryAnimation) =>
                      DoctorReelsScreen(),
                  transitionsBuilder: (context, animation, secondaryAnimation, child) {
                    const begin = Offset(1.0, 0.0); // slide from right
                    const end = Offset.zero;
                    const curve = Curves.easeInOut;

                    final tween = Tween(begin: begin, end: end).chain(CurveTween(curve: curve));
                    final offsetAnimation = animation.drive(tween);

                    return SlideTransition(position: offsetAnimation, child: child);
                  },
                ),
              );
            },             ),
          Divider(),

          ListTile(
            leading: Icon(Icons.chat_bubble_outline, color: Colors.deepPurple),
            title: Text('HealthBot – Ask & Learn'),
            subtitle: Text('Get instant answers to common health questions.'),
            trailing: Icon(Icons.arrow_forward_ios),
            onTap: () {
              Navigator.push(
                context,
                PageRouteBuilder(
                  pageBuilder: (context, animation, secondaryAnimation) =>
                      HealthBotScreen(),
                  transitionsBuilder: (context, animation, secondaryAnimation, child) {
                    const begin = Offset(1.0, 0.0); // slide from right
                    const end = Offset.zero;
                    const curve = Curves.easeInOut;

                    final tween = Tween(begin: begin, end: end).chain(CurveTween(curve: curve));
                    final offsetAnimation = animation.drive(tween);

                    return SlideTransition(position: offsetAnimation, child: child);
                  },
                ),
              );
            },
          ),
          Divider(),

          // Additional Creative and Valuable Items
          ListTile(
            leading: Icon(Icons.stars, color: Colors.deepPurple),
            title: Text('Top Rated Doctors'),
            subtitle: Text('Find doctors highly rated by patients like you.'),
            trailing: Icon(Icons.arrow_forward_ios),
            onTap: () {
              Navigator.push(
                context,
                PageRouteBuilder(
                  pageBuilder: (context, animation, secondaryAnimation) =>
                      TopRatedDoctorsScreen(),
                  transitionsBuilder: (context, animation, secondaryAnimation, child) {
                    const begin = Offset(1.0, 0.0); // slide from right
                    const end = Offset.zero;
                    const curve = Curves.easeInOut;

                    final tween = Tween(begin: begin, end: end).chain(CurveTween(curve: curve));
                    final offsetAnimation = animation.drive(tween);

                    return SlideTransition(position: offsetAnimation, child: child);
                  },
                ),
              );
            },
          ),
          Divider(),

          ListTile(
            leading: Icon(Icons.schedule, color: Colors.deepPurple),
            title: Text('Book Appointments'),
            subtitle: Text('Schedule with trusted specialists nearby.'),
            trailing: Icon(Icons.arrow_forward_ios),
            onTap: () {
              Navigator.push(
                context,
                PageRouteBuilder(
                  pageBuilder: (context, animation, secondaryAnimation) =>
                      BookedAppointmentsScreen(),
                  transitionsBuilder: (context, animation, secondaryAnimation, child) {
                    const begin = Offset(1.0, 0.0); // slide from right
                    const end = Offset.zero;
                    const curve = Curves.easeInOut;

                    final tween = Tween(begin: begin, end: end).chain(CurveTween(curve: curve));
                    final offsetAnimation = animation.drive(tween);

                    return SlideTransition(position: offsetAnimation, child: child);
                  },
                ),
              );
            },
          ),
          Divider(),

          ListTile(
            leading: Icon(Icons.local_hospital, color: Colors.deepPurple),
            title: Text('24/7 Emergency Guidance'),
            subtitle: Text('Access immediate care instructions in emergencies.'),
            trailing: Icon(Icons.arrow_forward_ios),
            onTap: () {
              Navigator.push(
                context,
                PageRouteBuilder(
                  pageBuilder: (context, animation, secondaryAnimation) =>
                      EmergencyGuidanceScreen(),
                  transitionsBuilder: (context, animation, secondaryAnimation, child) {
                    const begin = Offset(1.0, 0.0); // slide from right
                    const end = Offset.zero;
                    const curve = Curves.easeInOut;

                    final tween = Tween(begin: begin, end: end).chain(CurveTween(curve: curve));
                    final offsetAnimation = animation.drive(tween);

                    return SlideTransition(position: offsetAnimation, child: child);
                  },
                ),
              );
            },          ),
          Divider(),
        ],
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
