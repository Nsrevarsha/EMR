import 'package:flutter/material.dart';
import 'package:health_app/screens/patientsScreen.dart';
import 'package:health_app/screens/homepage.dart';
import 'package:health_app/screens/profileScreen.dart';

class MyHome extends StatefulWidget {
  const MyHome({super.key});

  @override
  State<MyHome> createState() => _MyHomeState();
}

class _MyHomeState extends State<MyHome> {
  Widget activepage = HomePage();
  String title = '';
  int _selectedIndex = 0;
  @override
  Widget build(BuildContext context) {
    if (_selectedIndex == 0) {
      activepage = HomePage();
    }
    if (_selectedIndex == 1) {
      activepage = PatientListScreen();
    }
    if (_selectedIndex == 2) {
      activepage = ProfilePage();
    }
    return Scaffold(
      bottomNavigationBar: BottomNavigationBar(
        type: BottomNavigationBarType.fixed,
        elevation: 10,
        // backgroundColor: Theme.of(context).colorScheme.secondaryContainer,
        selectedFontSize: 15,
        unselectedFontSize: 11,
        onTap: (index) {
          setState(() {
            _selectedIndex = index;
          });
        },
        currentIndex: _selectedIndex,
        items: const [
          BottomNavigationBarItem(
            icon: Icon(Icons.home),
            label: 'Home',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.medical_information_outlined),
            label: 'Patients',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.person_2_outlined),
            label: 'My Profile',
          ),
        ],
      ),
      body: activepage,
    );
  }
}
