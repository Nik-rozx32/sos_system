import 'package:flutter/material.dart';

class IntructPage extends StatelessWidget {
  const IntructPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body:SafeArea(
        child: Center(
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 20),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(children: [
                  Icon(Icons.info),
                  SizedBox(width:5),
                  Text('Instructions',style:TextStyle(fontWeight: FontWeight.bold,fontSize:24,)),
                ],),
                SizedBox(height: 20),
                Text('1.Add your emergency contacts under MENU ADD CONTACT',),
                SizedBox(height: 20),
                Text('2.Press the SOS Widget or the SOS Button on the homepage in case of an EMERGENCY. On pressing the button, an SOS message along with the link of your CURRENT LOCATION on google maps will be sent as an SMS to your added emergency contacts',),
                SizedBox(height: 20),
                Text('3.We recommend you to always keep your GPS turned ON so that your device has enough information about your location in case of an emergency which in turn enables the app to fetch your location very quickly otherwise it may take few more seconds (not more than 10 sec)',),
                SizedBox(height: 20),
                Text('4.We recommend you to use SOS Alert Widget and always keep GPS turned ON so that you can send SOS Alert in just one tap. You can adjust the size of the widget as per your requirements',),
              ]
            ),
          ),
        ),
      )
    );
  }
}
