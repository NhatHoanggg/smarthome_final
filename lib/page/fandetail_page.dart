import 'package:firebase_database/firebase_database.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

class FanDetailPage extends StatefulWidget {
  const FanDetailPage({Key? key}) : super(key: key);

  @override
  _FanDetailPageState createState() => _FanDetailPageState();
}

class _FanDetailPageState extends State<FanDetailPage> {
  int _speed = 3; // Initial default speed
  final DatabaseReference _databaseReference = FirebaseDatabase.instance.ref();

  @override
  void initState() {
    super.initState();
    _databaseReference.child('Fan Value').onValue.listen((event) {
      setState(() {
        _speed = (event.snapshot.value as int?) ?? _speed;
      });
    });
  }

  void _setSpeed(int value) {
    setState(() {
      _speed = value;
    });
    _databaseReference.update({'Fan Value': _speed});
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.grey[300],
      appBar: AppBar(
        title: const Text('Fan Details'),
        backgroundColor: Colors.grey[300],
      ),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Text(
              'Fan Speed',
              style: GoogleFonts.bebasNeue(fontSize: 35),
            ),
            const SizedBox(height: 20),
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                for (int i = 1; i <= 4; i++)
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 8.0),
                    child: ElevatedButton(
                      onPressed: () {
                        _setSpeed(i);
                      },
                      style: ElevatedButton.styleFrom(
                        backgroundColor: _speed == i
                            ? const Color.fromARGB(255, 140, 136, 136)
                            : null,
                      ),
                      child: Text(
                        '$i',
                        style: const TextStyle(fontSize: 20),
                      ),
                    ),
                  )
              ],
            ),
          ],
        ),
      ),
    );
  }
}

