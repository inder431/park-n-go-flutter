import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:parking_go/User/Services/authentication.dart';
import 'package:parking_go/admin/home.dart';

import 'package:shared_preferences/shared_preferences.dart';
import 'package:toast/toast.dart';

class SigninScreen extends StatefulWidget {
  const SigninScreen({Key? key}) : super(key: key);

  @override
  _SigninScreenState createState() => _SigninScreenState();
}

class _SigninScreenState extends State<SigninScreen> {
  late double w, h;
  TextEditingController email = new TextEditingController();
  TextEditingController password = new TextEditingController();

  void login(BuildContext context, bool google) async {
    if (!google) {
      if (email.text.isEmpty) {
        Toast.show("Email is required!", context);
        return;
      }
      if (password.text.isEmpty) {
        Toast.show("Password is required!", context);
        return;
      }
    }
    showLoginDialog(context);
    bool login = await firebaseLogin();
    Navigator.of(context, rootNavigator: true).pop();
    if (login) {
      SharedPreferences sharedPreferences =
          await SharedPreferences.getInstance();
      sharedPreferences.setString("login", "1");
      Navigator.pushReplacement(
          context, MaterialPageRoute(builder: (context) => AdminHome()));
    } else {
      Toast.show("Incorrect Credentials!", context, gravity: Toast.CENTER);
    }
  }

  firebaseLogin() async {
    try {
      DocumentSnapshot ds =
          await FirebaseFirestore.instance.collection('admin').doc('id').get();
      Map<String, dynamic> data = ds.data() as Map<String, dynamic>;
      return (data['id'] == email.text.toString().trim() &&
          data['password'] == password.text.toString().trim());
    } catch (e) {
      print("Error loggin admin $e");
      return false;
    }
  }

  @override
  Widget build(BuildContext context) {
    w = MediaQuery.of(context).size.width;
    h = MediaQuery.of(context).size.height;
    return Scaffold(
      backgroundColor: Colors.white,
      resizeToAvoidBottomInset: true,
      body: Container(
        width: w,
        height: h,
        child: SingleChildScrollView(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              SizedBox(
                height: h * .1,
              ),
              Center(
                child: Text(
                  "Welcome To Park'n Go",
                  style: TextStyle(
                      color: Color(0xff41B546),
                      fontWeight: FontWeight.w700,
                      fontSize: 26),
                ),
              ),
              SizedBox(
                height: h * .1,
              ),
              Container(
                  margin: EdgeInsets.only(left: w * .13, bottom: 10),
                  child: Text(
                    "Email",
                    style: TextStyle(
                        color: Color(0xff979797),
                        fontWeight: FontWeight.w800,
                        fontSize: 18),
                  )),
              textFeild("Enter your email", email, false),
              Container(
                  margin: EdgeInsets.only(left: w * .13, bottom: 10, top: 43),
                  child: Text(
                    "Password",
                    style: TextStyle(
                        color: Color(0xff979797),
                        fontWeight: FontWeight.w800,
                        fontSize: 18),
                  )),
              textFeild("Enter your password", password, true),
              SizedBox(
                height: h * .08,
              ),
              Center(
                child: SizedBox(
                  width: w * .4,
                  height: 50,
                  child: ElevatedButton(
                      onPressed: () {
                        login(context, false);
                      },
                      child: Text(
                        'LOGIN',
                        style: TextStyle(
                            color: Colors.white,
                            fontWeight: FontWeight.bold,
                            fontSize: 18,
                            letterSpacing: .9),
                      ),
                      style: ElevatedButton.styleFrom(
                        primary: Color(0Xff41B546),
                      )),
                ),
              ),
              SizedBox(
                height: h * .04,
              ),
              Center(
                child: GestureDetector(
                  onTap: () {},
                  child: Text(
                    "Forgot Password?",
                    style: TextStyle(color: Colors.blue),
                  ),
                ),
              )
            ],
          ),
        ),
      ),
    );
  }

  Widget textFeild(String hint, TextEditingController controller, bool obsure) {
    return Container(
      height: 39,
      color: Color(0xffE0DFDF),
      width: w * .8,
      margin: EdgeInsets.only(left: w * .13),
      child: TextField(
        obscureText: obsure,
        controller: controller,
        decoration: InputDecoration(
            border: InputBorder.none,
            filled: true,
            hintStyle: TextStyle(color: Colors.black45),
            hintText: hint,
            fillColor: Color(0xffE0DFDF)),
      ),
    );
  }

  showLoginDialog(BuildContext context) {
    AlertDialog alert = AlertDialog(
      title: Text("Logging in"),
      content: Padding(
        padding: const EdgeInsets.fromLTRB(12.0, 0.0, 12.0, 12.0),
        child: Row(
          children: [
            CircularProgressIndicator(
                valueColor:
                    new AlwaysStoppedAnimation<Color>(Color(0xff01702E))),
            SizedBox(
              width: 10,
            ),
            Text("Please wait...")
          ],
        ),
      ),
    );
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (BuildContext context) {
        return alert;
      },
    );
  }
}
