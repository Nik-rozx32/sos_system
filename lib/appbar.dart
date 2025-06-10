import 'package:flutter/material.dart';
import 'package:sos_system/profile.dart';

class Topbar extends StatelessWidget implements PreferredSizeWidget 00000000.0.0. {
  const Topbar({super.key});

  @override
  Widget build(BuildContext context) {
    return AppBar(
      
        title: const Text('SOS'),
        leading: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Image.asset('lib/images/engine-warning.png'),
        ),
        actions: [
          Padding(
            padding: const EdgeInsets.all(8.0),
            child: IconButton(
              icon: const Icon(Icons.person_2_outlined),
              onPressed: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(builder: (context) => const ProfPage()),
                );
              },
            ),
          )
        ],
    );
  }
  @override
  Size get preferredSize => Size.fromHeight(56.0);
}