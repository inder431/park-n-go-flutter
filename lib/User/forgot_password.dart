import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:parking_go/User/Services/authentication.dart';

import 'package:toast/toast.dart';

import 'dashboard.dart';

class PasswordResetScreen extends StatefulWidget {
  const PasswordResetScreen({Key? key}) : super(key: key);

  @override
  _PasswordResetScreenState createState() => _PasswordResetScreenState();
}

class _PasswordResetScreenState extends State<PasswordResetScreen> {
  late double w, h;
  TextEditingController email = new TextEditingController();

  Future<void> resetPassword() async {
    try {
      if (email.text.isEmpty) {
        Toast.show(
            "Enter email to receive instruction how to reset your password!",
            context,
            textColor: Colors.white,
            backgroundColor: Colors.green);
        return;
      }
      await FirebaseAuth.instance.sendPasswordResetEmail(email: email.text);
      email.text = "";
      Toast.show("Please check your email!", context,
          textColor: Colors.white,
          backgroundColor: Colors.green,
          duration: Toast.LENGTH_LONG);
      FocusScope.of(context).unfocus();
    } catch (e) {
      print("Error sending password reset email ${e.toString().split(']')[1]}");
      Toast.show(
          "Failed to send password reset email, ${e.toString().split(']')[1]}",
          context,
          textColor: Colors.white,
          backgroundColor: Colors.green,
          duration: Toast.LENGTH_LONG);
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
              Container(
                  margin: EdgeInsets.only(left: 14, top: 36),
                  alignment: Alignment.topLeft,
                  child: GestureDetector(
                      onTap: () {
                        Navigator.of(context).pop();
                      },
                      child: Icon(Icons.arrow_back))),
              SizedBox(
                height: h * .03,
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
              SizedBox(
                height: h * .06,
              ),
              Center(
                child: SizedBox(
                  width: w * .4,
                  height: 50,
                  child: ElevatedButton(
                      onPressed: () async {
                        FocusScope.of(context).unfocus();
                        showResetDialog(context);
                        await resetPassword();
                        Navigator.pop(context);
                      },
                      child: Text(
                        'Reset',
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

  showResetDialog(BuildContext context) {
    AlertDialog alert = AlertDialog(
      title: Text("Sending Reset Email"),
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
