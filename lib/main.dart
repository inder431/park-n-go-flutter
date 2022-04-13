import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:parking_go/User/sigin.dart';
import 'package:parking_go/User/singup.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'User/dashboard.dart';
import 'admin/admin_main.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp();
  runApp(AdminApp());
}

class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      home: MyHomePage(),
    );
  }
}

class MyHomePage extends StatefulWidget {
  @override
  State<MyHomePage> createState() => _MyHomePageState();
}

class _MyHomePageState extends State<MyHomePage> {
  late double w, h;
  bool loading = true;

  Future<void> checkAuth() async {
    SharedPreferences sharedPreferences = await SharedPreferences.getInstance();
    if (sharedPreferences.getString("userEmail") != null) {
      Navigator.pushReplacement(
          context, MaterialPageRoute(builder: (context) => DashboardScreen()));
    }
    setState(() {
      loading = false;
    });
  }

  @override
  void initState() {
    SystemChrome.setEnabledSystemUIOverlays([]);
    checkAuth();
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    w = MediaQuery.of(context).size.width;
    h = MediaQuery.of(context).size.height;
    return Scaffold(
      backgroundColor: Colors.white,
      body: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: <Widget>[
          SizedBox(
            height: 58,
          ),
          Image.asset('assets/logo.png'),
          Text(
            "Park'n Go",
            style: TextStyle(
                fontFamily: 'ropasans', color: Color(0xff41B546), fontSize: 48),
          ),
          Spacer(),
          if (loading)
            Container(
              width: 30,
              height: 30,
              margin: EdgeInsets.only(bottom: h * .2),
              child: CircularProgressIndicator(
                color: Colors.green,
              ),
            ),
          if (!loading)
            Container(
              margin: EdgeInsets.only(left: 23, right: 23, bottom: 57),
              child: Row(
                children: [
                  SizedBox(
                    width: w * .4,
                    height: 50,
                    child: ElevatedButton(
                        onPressed: () {
                          Navigator.push(
                              context,
                              MaterialPageRoute(
                                  builder: (context) => SigninScreen()));
                        },
                        child: Text('SIGIN'),
                        style: ElevatedButton.styleFrom(
                          primary: Colors.green,
                        )),
                  ),
                  Spacer(),
                  SizedBox(
                    width: w * .4,
                    height: 50,
                    child: ElevatedButton(
                        onPressed: () {
                          Navigator.push(
                              context,
                              MaterialPageRoute(
                                  builder: (context) => SignupScreen()));
                        },
                        child: Text(
                          'REGISTER',
                          style: TextStyle(color: Colors.black),
                        ),
                        style: ElevatedButton.styleFrom(
                          primary: Color(0XffFBFBFB),
                        )),
                  ),
                ],
              ),
            ),
        ],
      ),
    );
  }
}
