import 'package:flutter/material.dart';
import 'package:google_nav_bar/google_nav_bar.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'home.dart';
import 'add_contact.dart';
import 'sos.dart';
import 'instruction.dart';

class NaviBar extends StatefulWidget {
  const NaviBar({super.key});

  @override
  State<NaviBar> createState() => _NaviBarState();
}

class _NaviBarState extends State<NaviBar> {
  int _selectedIndex = 0;
  List<String> phoneNumbers = [];

  // Firestore Stream for real-time contact updates
  final Stream<QuerySnapshot> contactsStream =
      FirebaseFirestore.instance.collection('contacts').snapshots();

  // Function to add a new contact to Firestore
  Future<void> updateContacts(String name, String contact) async {
    try {
      await FirebaseFirestore.instance.collection('contacts').add({
        'name': name,
        'contact': contact,
      });
      debugPrint("Contact added: $name - $contact");
    } catch (e) {
      debugPrint("Error adding contact: $e");
    }
  }

  @override
  void initState() {
    super.initState();
    _fetchContacts(); // Fetch contacts on initialization
  }

  Future<void> _fetchContacts() async {
    FirebaseFirestore.instance.collection('contacts').get().then((snapshot) {
      setState(() {
        phoneNumbers = snapshot.docs
            .map((doc) => doc['contact']?.toString() ?? '')
            .where((number) => number.isNotEmpty)
            .toList();
      });
    }).catchError((error) {
      debugPrint("Error fetching contacts: $error");
    });
  }

  @override
  Widget build(BuildContext context) {
    final List<Widget> _screens = [
      const Home_Page(),
      SosPage(contactsStream: contactsStream),
      ContPage(onContactsUpdated: updateContacts),
      IntructPage(),
    ];

    return Scaffold(
      body: _screens[_selectedIndex], // Show selected screen
      bottomNavigationBar: Container(
        color: Colors.black,
        padding: const EdgeInsets.symmetric(vertical: 8),
        child: GNav(
          backgroundColor: Colors.black,
          color: Colors.white,
          activeColor: Colors.blue,
          gap: 8,
          padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
          selectedIndex: _selectedIndex,
          onTabChange: (index) {
            setState(() {
              _selectedIndex = index;
            });
          },
          tabs: const [
            GButton(icon: Icons.home, text: 'Home'),
            GButton(icon: Icons.sos, text: 'SOS'),
            GButton(icon: Icons.person_add, text: 'Add Contact'),
            GButton(icon: Icons.info, text: 'Instructions'),
          ],
        ),
      ),
    );
  }
}
