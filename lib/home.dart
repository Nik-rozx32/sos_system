// import 'package:flutter/material.dart';
// import 'profile.dart';

// // ignore: camel_case_types
// class Sos_page extends StatelessWidget {
//   const Sos_page({super.key});

//   @override
//   Widget build(BuildContext context) {
//     return Scaffold(
//       appBar: AppBar(
//         title: const Text('SOS'),
//         leading: Padding(
//           padding: const EdgeInsets.all(16.0),
//           child: Image.asset('lib/images/engine-warning.png'),
//         ),
//         actions: [
//           Padding(
//             padding: const EdgeInsets.all(8.0),
//             child: IconButton(
//               icon: const Icon(Icons.person_2_outlined),
//               onPressed: () {
//                 Navigator.push(
//                   context,
//                   MaterialPageRoute(builder: (context) => const Prof_page()),
//                 );
//               },
//             ),
//           )
//         ],
//       ),
//       body: Padding(
//         padding: const EdgeInsets.symmetric(horizontal: 25.0,vertical: 15),
//         child: Container(
//           decoration: BoxDecoration(
//             color: Colors.blue,
//             borderRadius: BorderRadius.circular(8),
//           ),
//           child: const Text('Alert Msg'),
//         ),
//       ),

//     );
//   }
// }

import 'package:flutter/material.dart';
import 'package:permission_handler/permission_handler.dart' as perm;
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:telephony/telephony.dart';



class Home_Page extends StatefulWidget {
  const Home_Page({super.key});

  @override
  State<Home_Page> createState() => _Home_PageState();
}

class _Home_PageState extends State<Home_Page> {
  @override
  void initState() {
    super.initState();
    _requestPermissions();
  }

  Future<void> _requestPermissions() async {
    var status = await perm.Permission.sms.status;
    if (!status.isGranted) {
      await perm.Permission.sms.request();
    }
  }

  @override
  Widget build(BuildContext context) {
    return const MaterialApp(
      debugShowCheckedModeBanner: false,
      home: SosPage(),
    );
  }
}

// ✅ Create the Home Page (SOS Receiver)
class SosPage extends StatefulWidget {
  const SosPage({super.key});

  @override
  State<SosPage> createState() => _SosPageState();
}

class _SosPageState extends State<SosPage> {
  GoogleMapController? _mapController;
  LatLng? _senderLocation; // ✅ Sender's location
  final Telephony telephony = Telephony.instance;

  @override
  void initState() {
    super.initState();
    _listenForSms();
  }

  // ✅ Listen for Incoming SMS and Extract Location
  void _listenForSms() {
    telephony.listenIncomingSms(
      onNewMessage: (SmsMessage message) {
        _extractLocationFromSms(message.body ?? ""); // Extract location from SMS content
      },
      onBackgroundMessage: _backgroundMessageHandler,
    );
  }

  // ✅ Background SMS Handler
  static void _backgroundMessageHandler(SmsMessage message) {
    // This handles SMS in the background if needed
  }

  // ✅ Extract Latitude & Longitude from SMS
  void _extractLocationFromSms(String message) {
    RegExp regex = RegExp(r"(-?\d+\.\d+),\s*(-?\d+\.\d+)"); // Matches lat,lng format
    Match? match = regex.firstMatch(message);

    if (match != null) {
      double latitude = double.parse(match.group(1)!);
      double longitude = double.parse(match.group(2)!);

      setState(() {
        _senderLocation = LatLng(latitude, longitude);
      });

      _mapController?.animateCamera(CameraUpdate.newLatLng(_senderLocation!));

      Fluttertoast.showToast(msg: "Location Received: $latitude, $longitude");
    } else {
      Fluttertoast.showToast(msg: "Invalid Location Data in SMS");
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text("SOS Receiver App")),
      body: Column(
        children: [
          // ✅ Google Map Section
          Expanded(
            flex: 2,
            child: _senderLocation == null
                ? const Center(child: Text("Waiting for SOS Message..."))
                : GoogleMap(
                    onMapCreated: (GoogleMapController controller) {
                      _mapController = controller;
                    },
                    initialCameraPosition: CameraPosition(
                      target: _senderLocation!,
                      zoom: 15,
                    ),
                    markers: {
                      Marker(
                        markerId: const MarkerId("sender_location"),
                        position: _senderLocation!,
                        infoWindow: const InfoWindow(title: "Sender's Location"),
                      ),
                    },
                  ),
          ),
        ],
      ),
    );
  }
}
