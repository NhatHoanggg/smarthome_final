import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:firebase_database/firebase_database.dart';
import 'package:smarthome_final/page/changepw_page.dart';
import 'package:smarthome_final/page/fandetail_page.dart';
import 'package:smarthome_final/page/lightdetail_page.dart';
import 'package:smarthome_final/page/login_page.dart';
import 'package:smarthome_final/util/smart_device_box.dart';

class HomePage extends StatefulWidget {
  const HomePage({super.key});

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  User? user;
  final DatabaseReference _databaseReference = FirebaseDatabase.instance.ref().child('devices_command');
  final DatabaseReference _tempRef = FirebaseDatabase.instance.ref().child('Temp');
  final DatabaseReference _moistureRef = FirebaseDatabase.instance.ref().child('Moisture');

  double temperature = 0;
  double moisture = 0;

  @override
  void initState() {
    super.initState();
    _getCurrentUser();
    _initializeFirebase();
    _activateListeners();
  }

  void _initializeFirebase() async {
    await Firebase.initializeApp();
    _databaseReference.onValue.listen((event) {
      final data = event.snapshot.value as Map?;
      if (data != null) {
        setState(() {
          data.forEach((deviceName, deviceData) {
            final command = deviceData['command'] ?? '';
            final powerStatus = deviceData['powerStatus'] ?? false;
            _updateDeviceState(deviceName, powerStatus);
            if (command.isNotEmpty) {
              _processCommand(deviceName, command);
            }
          });
        });
      }
    });
  }


  // Handle when receive sensor value
  void _activateListeners() {
    _tempRef.onValue.listen((event) {
      final temp = event.snapshot.value;
      if (temp != null) {
        setState(() {
          temperature = temp is double ? temp : (temp as int).toDouble();
        });
      }
    });

    _moistureRef.onValue.listen((event) {
      final moist = event.snapshot.value;
      if (moist != null) {
        setState(() {
          moisture = moist is double ? moist : (moist as int).toDouble();
        });
      }
    });
  }


  // Handle when receive command
  void _processCommand(String deviceName, String command) {
    switch (command) {
      case 'bat den':
        _turnOnDevice(deviceName);
        break;
      case 'tat den':
        _turnOffDevice(deviceName);
        break;
      case 'bat quat':
        _turnOnDevice(deviceName);
        break;
      case 'tat quat':
        _turnOffDevice(deviceName);
        break;
      case 'bat tv':
        _turnOnDevice(deviceName);
        break;
      case 'tat tv':
        _turnOffDevice(deviceName);
        break;
      case 'ON':
        _turnOnDevice(deviceName);
        break;
      case 'OFF':
        _turnOffDevice(deviceName);
        break;
      default:
        print('Lệnh không được hỗ trợ: $command');
    }
  }

  void _turnOnDevice(String deviceName) {
    _updateDeviceState(deviceName, true);
  }

  void _turnOffDevice(String deviceName) {
    _updateDeviceState(deviceName, false);
  }

  // Update device state
  void _updateDeviceState(String deviceName, bool powerStatus) {
    final index = mySmartDevices.indexWhere((device) => device['smartDeviceName'] == deviceName);
    if (index != -1) {
      setState(() {
        mySmartDevices[index]['powerStatus'] = powerStatus;
      });
    }
  }

  // Display user
  void _getCurrentUser() {
    setState(() {
      user = FirebaseAuth.instance.currentUser;
    });
  }

  
  final double horizontalPadding = 40;
  final double verticalPadding = 25;

  // List smart devices
  List<Map<String, dynamic>> mySmartDevices = [
    {"smartDeviceName": "Light", "iconPath": "lib/icons/light-bulb.png", "powerStatus": false, "detailPage": const LightDetailPage()},
    {"smartDeviceName": "Venti", "iconPath": "lib/icons/ventilation.png", "powerStatus": false, "detailPage": const LightDetailPage()},
    {"smartDeviceName": "TV", "iconPath": "lib/icons/smart-tv.png", "powerStatus": false, "detailPage": const LightDetailPage()},
    {"smartDeviceName": "Fan", "iconPath": "lib/icons/fan.png", "powerStatus": false, "detailPage": const FanDetailPage()},
  ];

   // Handle power button switched
  void powerSwitchChanged(bool value, int index) {
    final deviceName = mySmartDevices[index]["smartDeviceName"];
    setState(() {
      if (deviceName == "Light") {
        _databaseReference.child(deviceName).update({
          "command": value ? "bat den" : "tat den", 
        });
      } else if (deviceName == "Fan"){
        _databaseReference.child(deviceName).update({
          "command": value ? "bat quat" : "tat quat", 
        });
      }
      else if (deviceName == "TV"){
        _databaseReference.child(deviceName).update({
          "command": value ? "bat tv" : "tat tv", 
        });
      }
      else if (deviceName == "Venti"){
        _databaseReference.child(deviceName).update({
          "command": value ? "ON" : "OFF", 
        });
      }
    });
  }


    // Handle detail device
  void showDeviceNotAvailableDialog(BuildContext context) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          backgroundColor: Colors.grey[300],
          title: const Text("Nothing To Adjust or Device is OFF!"),
          content: const Text("This device detail is not available."),
          actions: <Widget>[
            TextButton(
              onPressed: () {
                Navigator.of(context).pop();
              },
              child: const Text("OK"),
            ),
          ],
        );
      },
    );
  }




  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.grey[300],

      // Drawer detail
       drawer: Drawer(
        child: ListView(
          padding: EdgeInsets.zero,
          children: <Widget>[
            DrawerHeader(
              decoration: BoxDecoration(
                color: Colors.grey[300],
              ),
              child:
                  Text(
                    user?.displayName ?? 'No display name',
                    style: TextStyle(
                      color: Colors.grey.shade800,
                      fontSize: 50,
                      fontFamily: GoogleFonts.bebasNeue().fontFamily,
                    ),
                  ),
            ),
            ListTile(
              leading: const Icon(Icons.emoji_people),
              title: Text(
                'Smart Home',
                style: TextStyle(
                  color: Colors.grey.shade800,
                  fontSize: 30,
                  fontFamily: GoogleFonts.bebasNeue().fontFamily,
                ),
              ),
              onTap: () {
                Navigator.pop(context);
              },
            ),
            ListTile(
              leading: const Icon(Icons.settings),
              title: const Text('Change password'),
              onTap: () {
                Navigator.pop(context);
                Navigator.push(
                  context,
                  MaterialPageRoute(builder: (context) => const ChangePasswordPage()),
                );
              },
            ),
            ListTile(
              leading: const Icon(Icons.logout),
              title: const Text('Log out'),
              onTap: () {
                Navigator.pop(context); // close drawer
                Navigator.pushAndRemoveUntil(
                  context,
                  MaterialPageRoute(builder: (context) => const LoginPage()),
                  (route) => false, // remove all previous routes
                  
                );
              },
            ),
          ],
        ),
      ),


      // Body home_page
      body: SafeArea(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // app bar
            Padding(
              padding: EdgeInsets.symmetric(
                horizontal: horizontalPadding,
                vertical: verticalPadding,
              ),
              child: Builder(
                builder: (context) => IconButton(
                  onPressed: () {
                    Scaffold.of(context).openDrawer();
                  },
                  icon: Icon(
                    Icons.person,
                    size: 45,
                    color: Colors.grey[800],
                  ),
                ),
              ),
            ),

            const SizedBox(height: 10),

            // Welcome home
            Padding(
              padding: EdgeInsets.symmetric(horizontal: horizontalPadding),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    "Welcome Home,",
                    style: TextStyle(fontSize: 20, color: Colors.grey.shade800),
                  ),
                  Text(
                    user?.displayName ?? 'No display name',
                    style: TextStyle(
                      color: Colors.grey.shade800,
                      fontSize: 50,
                      fontFamily: GoogleFonts.bebasNeue().fontFamily,
                    ),
                  ),
                ],
              ),
            ),

            const SizedBox(height: 5),

            const Padding(
              padding: EdgeInsets.symmetric(horizontal: 40.0),
              child: Divider(
                thickness: 1,
                color: Color.fromARGB(255, 204, 204, 204),
              ),
            ),

            const SizedBox(height: 25),
            Padding(
              padding: EdgeInsets.symmetric(horizontal: horizontalPadding),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.start,
                children: [
                  // Temp
                  Row(
                    children: [
                      Image.asset(
                        'lib/icons/temparature.png',
                        height: 40,
                        color: Colors.grey.shade800,
                      ),
                      const SizedBox(width: 8), // Khoảng cách giữa biểu tượng và giá trị
                      Text(
                        '${temperature.toString()}°C',
                        style: TextStyle(
                          fontSize: 24,
                          color: Colors.grey.shade800,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(width: 40), 

                  // Moisture
                  Row(
                    children: [
                      Image.asset(
                        'lib/icons/moisturizing.png',
                        height: 40,
                        color: Colors.grey.shade800,
                      ),
                      const SizedBox(width: 8),
                      Text(
                        '${moisture.toString()}%',
                        style: TextStyle(
                          fontSize: 24,
                          color: Colors.grey.shade800,
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),

            const SizedBox(height: 30),
            // smart devices grid
            Padding(
              padding: EdgeInsets.symmetric(horizontal: horizontalPadding),
              child: Text(
                "Smart Devices",
                style: TextStyle(
                  fontWeight: FontWeight.bold,
                  fontSize: 24,
                  color: Colors.grey.shade800,
                ),
              ),
            ),
            const SizedBox(height: 10),

            Expanded(
              child: GridView.builder(
                itemCount: mySmartDevices.length,
                physics: const NeverScrollableScrollPhysics(),
                padding: const EdgeInsets.symmetric(horizontal: 25),
                gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                  crossAxisCount: 2,
                  childAspectRatio: 1 / 1.3,
                ),
                itemBuilder: (context, index) {
                  return InkWell(
                    onTap: () {
                      final deviceName = mySmartDevices[index]["smartDeviceName"];
                      final powerStatus = mySmartDevices[index]["powerStatus"];
                      if (powerStatus && (deviceName == 'Light' || deviceName == 'Fan')) {
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (context) => mySmartDevices[index]['detailPage'], 
                          ),
                        );
                      } else {
                        showDeviceNotAvailableDialog(context);
                      }
                    },
                    child: SmartDeviceBox(
                      smartDeviceName: mySmartDevices[index]["smartDeviceName"],
                      iconPath: mySmartDevices[index]["iconPath"],
                      powerOn: mySmartDevices[index]["powerStatus"],
                      onChanged: (value) => powerSwitchChanged(value, index),
                    ),
                  );
                },
              ),
            )
          ],
        ),
      ),
    );
  }
}
