import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:flutter/services.dart';
import 'package:vibration/vibration.dart';
import 'components/appbar.dart';

class SosPage extends StatefulWidget {
  final Stream<QuerySnapshot> contactsStream;
  
  const SosPage({super.key, required this.contactsStream});
  
  @override
  State<SosPage> createState() => _SosPageState();
}

class _SosPageState extends State<SosPage> {
  static const platform = MethodChannel("sms_sender");
  static const vibrationChannel = MethodChannel("vibration_control");

  bool _isSending = false;
  List<String> phoneNumbers = [];

  Future<void> _sendSOS() async {
    if (_isSending || phoneNumbers.isEmpty) return;

    setState(() => _isSending = true);

    try {
      if (await Vibration.hasVibrator()) {
        Vibration.vibrate();
      }

      if (await Permission.sms.request().isGranted) {
        await _sendMessage();
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text('SOS Alert sent successfully')),
          );
        }
      } else {
        _showSnackBar('SMS permission denied');
      }
    } catch (e) {
      _showSnackBar('Failed to send SOS Alert: $e');
    } finally {
      if (mounted) setState(() => _isSending = false);
    }
  }

  Future<void> _sendMessage() async {
    if (phoneNumbers.isEmpty) {
      debugPrint("No contacts found.");
      return;
    }

    String message = "\ud83d\udea8 SOS ALERT! I need help immediately! \ud83d\udea8";

    for (String number in phoneNumbers) {
      try {
        await platform.invokeMethod("sendSMS", {
          "phoneNumber": number,
          "message": message,
          "triggerVibration": true,
        });

        try {
          await vibrationChannel.invokeMethod("triggerRemoteVibration", {
            "phoneNumber": number,
            "pattern": [0, 500, 200, 500, 200, 500, 500, 500, 200, 500, 200, 500, 200, 500, 200, 500, 200, 500],
            "amplitude": 400,
          });
        } catch (vibrationError) {
          debugPrint("Failed to trigger remote vibration: $vibrationError");
        }

        debugPrint("SOS SMS sent to $number");
      } catch (e) {
        debugPrint("Failed to send SMS to $number: $e");
      }
    }
  }

  void _showSnackBar(String message) {
    if (mounted) {
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(message)));
    }
  }

  @override
  Widget build(BuildContext context) {
    double buttonSize = MediaQuery.of(context).size.width * 0.6;

    return Scaffold(
      backgroundColor: const Color.fromARGB(255, 45, 43, 43),
      appBar: Topbar(),
      body: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          StreamBuilder<QuerySnapshot>(
            stream: widget.contactsStream,
            builder: (context, snapshot) {
              if (snapshot.hasError) {
                return const Text('Error loading contacts', style: TextStyle(color: Colors.red));
              }

              if (snapshot.connectionState == ConnectionState.waiting) {
                return const Text('Loading contacts...', style: TextStyle(color: Colors.white));
              }

              phoneNumbers = snapshot.data?.docs
                      .map((doc) => doc['contact']?.toString() ?? '')
                      .where((number) => number.isNotEmpty)
                      .toList() ??
                  [];

              return Text(
                "Contacts Loaded: \${phoneNumbers.length}",
                style: const TextStyle(color: Colors.white70),
              );
            },
          ),

          const SizedBox(height: 20),

          Center(
            child: GestureDetector(
              onTap: _isSending ? null : _sendSOS,
              child: Container(
                alignment: Alignment.center,
                height: buttonSize,
                width: buttonSize,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  color: Colors.red,
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withOpacity(0.2),
                      spreadRadius: 5,
                      blurRadius: 10,
                      offset: const Offset(0, 3),
                    ),
                  ],
                ),
                child: _isSending
                    ? const CircularProgressIndicator(color: Colors.white)
                    : Text(
                        'SOS',
                        style: GoogleFonts.geo(
                          textStyle: const TextStyle(
                            fontSize: 50,
                            color: Colors.white,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
