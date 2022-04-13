import 'package:flutter/material.dart';
import 'package:parking_go/User/Services/authentication.dart';

import 'package:toast/toast.dart';

import 'dashboard.dart';

class SignupScreen extends StatefulWidget {
  const SignupScreen({Key? key}) : super(key: key);

  @override
  _SignupScreenState createState() => _SignupScreenState();
}

class _SignupScreenState extends State<SignupScreen> {
  late double w, h;
  TextEditingController emailController = new TextEditingController();
  TextEditingController userName = new TextEditingController();
  TextEditingController passwordController = new TextEditingController();
  TextEditingController confirmPasswordController = new TextEditingController();

  void signUp(BuildContext context, bool google) async {
    if (!google) {
      if (userName.text.isEmpty) {
        Toast.show("Full name is required!", context);
        return;
      }
      if (emailController.text.isEmpty) {
        Toast.show("Email is required!", context);
        return;
      }
      if (passwordController.text.isEmpty) {
        Toast.show("Password is required!", context);
        return;
      }
      if (confirmPasswordController.text.isEmpty) {
        Toast.show("Confirm password is required!", context);
        return;
      }
      if (passwordController.text.toString().trim() !=
          confirmPasswordController.text.toString().trim()) {
        Toast.show("Passwords are not same!", context);
        return;
      }
    }
    showSignupDialog(context);
    AuthenticationService auth = new AuthenticationService();
    bool signUp = false;
    if (!google)
      signUp = await auth.handleSignUp(
          context: context,
          name: userName.text,
          email: emailController.text,
          password: passwordController.text);
    else
      signUp = await auth.googleAuth(true, context);
    if (signUp) {
      Navigator.of(context, rootNavigator: true).pop();
      //navigate to home
      Navigator.pushReplacement(
          context, MaterialPageRoute(builder: (context) => DashboardScreen()));
      return;
    }
    Navigator.of(context, rootNavigator: true).pop();
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
                height: h * .02,
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
                height: h * .05,
              ),
              Container(
                  margin: EdgeInsets.only(left: w * .13, bottom: 10),
                  child: Text(
                    "Full Name",
                    style: TextStyle(
                        color: Color(0xff979797),
                        fontWeight: FontWeight.w800,
                        fontSize: 18),
                  )),
              textFeild("Enter your name", userName, false),
              Container(
                  margin: EdgeInsets.only(left: w * .13, bottom: 10, top: 15),
                  child: Text(
                    "Email",
                    style: TextStyle(
                        color: Color(0xff979797),
                        fontWeight: FontWeight.w800,
                        fontSize: 18),
                  )),
              textFeild("Enter your email", emailController, false),
              Container(
                  margin: EdgeInsets.only(left: w * .13, bottom: 10, top: 15),
                  child: Text(
                    "Password",
                    style: TextStyle(
                        color: Color(0xff979797),
                        fontWeight: FontWeight.w800,
                        fontSize: 18),
                  )),
              textFeild("Enter your password", passwordController, true),
              Container(
                  margin: EdgeInsets.only(left: w * .13, bottom: 10, top: 15),
                  child: Text(
                    "Confirm Password",
                    style: TextStyle(
                        color: Color(0xff979797),
                        fontWeight: FontWeight.w800,
                        fontSize: 18),
                  )),
              textFeild(
                  "Confirm your password", confirmPasswordController, true),
              SizedBox(
                height: h * .05,
              ),
              Center(
                child: SizedBox(
                  width: w * .4,
                  height: 50,
                  child: ElevatedButton(
                      onPressed: () {
                        signUp(context, false);
                      },
                      child: Text(
                        'SignUp',
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
                height: h * .03,
              ),
              Center(
                child: Text(
                  "OR",
                  style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
                ),
              ),
              SizedBox(
                height: h * .02,
              ),
              GestureDetector(
                  onTap: () {
                    signUp(context, true);
                  },
                  child: Center(
                      child: Image.asset(
                    'assets/google_signup.png',
                    width: w * .6,
                    height: h * .08,
                  )))
            ],
          ),
        ),
      ),
    );
  }

  Widget textFeild(
      String hint, TextEditingController controller, bool obscure) {
    return Container(
      height: 39,
      color: Color(0xffE0DFDF),
      width: w * .8,
      margin: EdgeInsets.only(left: w * .13),
      child: TextField(
        controller: controller,
        obscureText: obscure,
        decoration: InputDecoration(
            border: InputBorder.none,
            filled: true,
            hintStyle: TextStyle(color: Colors.black45),
            hintText: hint,
            fillColor: Color(0xffE0DFDF)),
      ),
    );
  }

  showSignupDialog(BuildContext context) {
    AlertDialog alert = AlertDialog(
      title: Text("Creating your account"),
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
