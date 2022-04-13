import 'package:flutter/material.dart';
import 'package:parking_go/User/Services/authentication.dart';
import 'package:parking_go/User/forgot_password.dart';

import 'package:toast/toast.dart';

import 'dashboard.dart';

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
    AuthenticationService auth = new AuthenticationService();
    bool login = false;
    if (!google)
      login = await auth.handleLogin(
          context: context, email: email.text, password: password.text);
    else
      login = await auth.googleAuth(false, context);
    if (login) {
      Navigator.of(context, rootNavigator: true).pop();
      Navigator.pushReplacement(
          context, MaterialPageRoute(builder: (context) => DashboardScreen()));
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
              Container(
                margin: EdgeInsets.only(left: w * .13, top: 15),
                alignment: Alignment.topLeft,
                child: GestureDetector(
                  onTap: () {
                    Navigator.push(
                        context,
                        MaterialPageRoute(
                            builder: (context) => PasswordResetScreen()));
                  },
                  child: Text(
                    "Forgot Password?",
                    style: TextStyle(color: Colors.blue),
                  ),
                ),
              ),
              SizedBox(
                height: h * .06,
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
                child: Text(
                  "OR",
                  style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
                ),
              ),
              SizedBox(
                height: 10,
              ),
              GestureDetector(
                  onTap: () {
                    login(context, true);
                  },
                  child: Center(
                    child: Image.asset(
                      'assets/google_signin.png',
                      width: w * .6,
                      height: h * .08,
                    ),
                  ))
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
