import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:google_sign_in/google_sign_in.dart';
import 'package:parking_go/User/Services/authentication.dart';
import 'package:toast/toast.dart';

class ProfileScreen extends StatefulWidget {
  const ProfileScreen({Key? key}) : super(key: key);

  @override
  _ProfileScreenState createState() => _ProfileScreenState();
}

class _ProfileScreenState extends State<ProfileScreen> {
  late double w, h;
  TextEditingController oldPassword = new TextEditingController();
  TextEditingController changePassword = new TextEditingController();
  bool googleSignIn = false;

  void checkMethod() async {
    bool signInMethod = await GoogleSignIn().isSignedIn();
    setState(() {
      googleSignIn = signInMethod;
    });
  }

  @override
  void initState() {
    SystemChrome.setEnabledSystemUIOverlays([]);
    checkMethod();
    super.initState();
  }

  void _changePassword() async {
    try {
      if (oldPassword.text.isEmpty) {
        Toast.show("Old password is required!", context,
            backgroundColor: Colors.green, textColor: Colors.white);
        return;
      }
      if (changePassword.text.isEmpty) {
        Toast.show("New password is required!", context,
            backgroundColor: Colors.green, textColor: Colors.white);
        return;
      }
      if (oldPassword.text.length < 8) {
        Toast.show("Old password length must be atleast 8 character!", context,
            backgroundColor: Colors.green, textColor: Colors.white);
        return;
      }
      if (changePassword.text.isEmpty) {
        Toast.show("New password length must be atleast 8 character!", context,
            backgroundColor: Colors.green, textColor: Colors.white);
        return;
      }
      await showProgressDialog(context);
      User user = await FirebaseAuth.instance.currentUser!;
      AuthenticationService as = new AuthenticationService();
      bool login = await as.handleLogin(
          context: context, email: user.email!, password: oldPassword.text!);
      if (login) {
        await user.updatePassword(changePassword.text);
        Navigator.pop(context);
        oldPassword.text = '';
        changePassword.text = '';
        Toast.show("Password changed successfully!", context,
            backgroundColor: Colors.green, textColor: Colors.white);
      } else {
        Toast.show("Incorrect password!", context,
            backgroundColor: Colors.green, textColor: Colors.white);
      }
    } catch (e) {
      Toast.show("Failed to change password!", context,
          backgroundColor: Colors.green, textColor: Colors.white);
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
                  color: Colors.green,
                  height: h * .08,
                  child: Row(
                    children: [
                      SizedBox(
                        width: 10,
                      ),
                      GestureDetector(
                        onTap: () {
                          Navigator.pop(context);
                        },
                        child: Icon(
                          Icons.arrow_back,
                          color: Colors.white,
                        ),
                      ),
                      SizedBox(
                        width: 15,
                      ),
                      Text(
                        "Profile",
                        style: TextStyle(
                            fontWeight: FontWeight.bold,
                            color: Colors.white,
                            fontSize: 24),
                      ),
                    ],
                  )),
              SizedBox(
                height: h * .05,
              ),
              Center(
                  child: Text(
                "User Profile",
                style: TextStyle(fontSize: 24, color: Colors.green),
              )),
              SizedBox(
                height: h * .04,
              ),
              Center(
                child: CircleAvatar(
                  radius: w * .2,
                  backgroundColor: Colors.white,
                  backgroundImage: Image.network(
                    FirebaseAuth.instance.currentUser!.photoURL == null
                        ? 'https://upload.wikimedia.org/wikipedia/commons/thumb/1/12/User_icon_2.svg/640px-User_icon_2.svg.png'
                        : FirebaseAuth.instance.currentUser!.photoURL!,
                  ).image,
                ),
              ),
              SizedBox(
                height: h * .04,
              ),
              Padding(
                padding: const EdgeInsets.all(20),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      "Name : ${FirebaseAuth.instance.currentUser!.displayName == null ? "No Name" : FirebaseAuth.instance.currentUser!.displayName}",
                      style:
                          TextStyle(fontWeight: FontWeight.w300, fontSize: 18),
                    ),
                    SizedBox(
                      height: h * .05,
                    ),
                    Text(
                      "Email : ${FirebaseAuth.instance.currentUser!.email}",
                      style:
                          TextStyle(fontWeight: FontWeight.w300, fontSize: 18),
                    ),
                    SizedBox(
                      height: h * .05,
                    ),
                    inputItem("Password", oldPassword),
                    SizedBox(
                      height: h * .05,
                    ),
                    inputItem("New Password", changePassword),
                    SizedBox(
                      height: h * .05,
                    ),
                    Center(
                      child: SizedBox(
                        width: w * .4,
                        height: 50,
                        child: ElevatedButton(
                            onPressed: () {
                              _changePassword();
                            },
                            child: Text(
                              'Submit',
                              style: TextStyle(
                                  color: Colors.white,
                                  fontWeight: FontWeight.bold,
                                  fontSize: 18,
                                  letterSpacing: .9),
                            ),
                            style: ElevatedButton.styleFrom(
                              primary: googleSignIn
                                  ? Colors.grey
                                  : Color(0Xff41B546),
                            )),
                      ),
                    )
                  ],
                ),
              )
            ],
          ),
        ),
      ),
    );
  }

  Widget inputItem(String hint, TextEditingController controller) {
    return Row(
      children: [
        Container(
          width: w * .3,
          child: Text(
            hint,
            style: TextStyle(fontWeight: FontWeight.w300, fontSize: 18),
          ),
        ),
        SizedBox(
          width: 10,
        ),
        textFeild(hint, controller, false)
      ],
    );
  }

  Widget textFeild(String hint, TextEditingController controller, bool obsure) {
    return Container(
      height: 39,
      color: Color(0xffE0DFDF),
      width: w * .5,
      child: TextField(
        obscureText: obsure,
        enabled: !googleSignIn,
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

  showProgressDialog(BuildContext context) {
    AlertDialog alert = AlertDialog(
      title: Text("Changing Password"),
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
