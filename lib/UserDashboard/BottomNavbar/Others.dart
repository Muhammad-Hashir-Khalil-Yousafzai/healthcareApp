import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:healthcare/Doctor%20Dashboard/Catagories/FindCases/FindCases.dart';
import 'package:healthcare/UserDashboard/BottomNavbar/Others/BookAppointments.dart';
import 'package:healthcare/UserDashboard/BottomNavbar/Others/BookedAppointments.dart';
import 'package:healthcare/UserDashboard/BottomNavbar/Others/DoctorDiaries.dart';
import 'package:healthcare/UserDashboard/BottomNavbar/Others/DoctorReelsScreen.dart';
import 'package:healthcare/UserDashboard/BottomNavbar/Others/EmergencyGuidance.dart';
import 'package:healthcare/UserDashboard/BottomNavbar/Others/FindCases.dart';
import 'package:healthcare/UserDashboard/BottomNavbar/Others/HealthBot.dart';
import 'package:healthcare/UserDashboard/BottomNavbar/Others/PatientsDiaries.dart';
import 'package:healthcare/UserDashboard/BottomNavbar/Others/TopDoctors.dart';
import 'package:healthcare/UserDashboard/Home/Home.dart';
import 'message.dart';
import 'AI_Features.dart';
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
        MaterialPageRoute(builder: (context) => AiFeaturesScreen()),
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
            leading: Icon(Icons.person, color: Colors.deepPurple),
            title: Text('Find Me a Doctor!'),
            subtitle: Text('Let doctors discover and respond to your case voluntarily.'),
            trailing: Icon(Icons.arrow_forward_ios),
            onTap: () {
              Navigator.push(
                context,
                PageRouteBuilder(
                  pageBuilder: (context, animation, secondaryAnimation) =>
                      FindCasesPage(),
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
            leading: Icon(Icons.article, color: Colors.deepPurple),
            title: Text("Doctor's Digest"),
            subtitle: Text('Health articles of professionals for healthy lifestyles'),
            trailing: Icon(Icons.arrow_forward_ios),
            onTap: () {
              Navigator.push(
                context,
                PageRouteBuilder(
                  pageBuilder: (context, animation, secondaryAnimation) =>
                      DoctorDiaries(),
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
            leading: Icon(Icons.campaign, color: Colors.deepPurple),
            title: Text('Share Your Health Story'),
            subtitle: Text('Share your real lide recovery story to help others.'),
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
            title: Text('Health Shorts'),
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
            title: Text('Booked Appointments'),
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
            icon: Icon(Icons.smart_toy),
            label: 'Ai Features',
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
