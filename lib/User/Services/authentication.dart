import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:google_sign_in/google_sign_in.dart';
import 'package:shared_preferences/shared_preferences.dart';

class AuthenticationService {
  //Signup the user
  Future<bool> handleSignUp(
      {required String name,
      required String email,
      required String password,
      required BuildContext context}) async {
    try {
      await FirebaseAuth.instance
          .createUserWithEmailAndPassword(email: email, password: password);
      await createUser(email, name);
      SharedPreferences sharedPreferences =
          await SharedPreferences.getInstance();
      sharedPreferences.setString("userEmail", email);
      return true;
    } on FirebaseAuthException catch (e) {
      Navigator.of(context, rootNavigator: true).pop();
      if (e.code == 'weak-password') {
        await errorDialog(context, "Weak password isn't allowed");
      } else if (e.code == 'email-already-in-use') {
        await errorDialog(context, "Account already exist please login");
      } else {
        await errorDialog(context, "Failed to create account");
      }
      return false;
    } catch (e) {
      Navigator.of(context, rootNavigator: true).pop();
      await errorDialog(context, e.toString());
      return false;
    }
  }

  // login the user
  Future<bool> handleLogin(
      {required BuildContext context,
      required String email,
      required String password}) async {
    try {
      await FirebaseAuth.instance
          .signInWithEmailAndPassword(email: email, password: password);
      SharedPreferences sharedPreferences =
          await SharedPreferences.getInstance();
      sharedPreferences.setString("userEmail", email);
      return true;
    } on FirebaseAuthException catch (e) {
      print("Error login ${e.code}");
      Navigator.of(context, rootNavigator: true).pop();
      if (e.code == 'user-not-found') {
        await errorDialog(context, "This $email isn't  registered.");
        print('No user found for that email.');
      } else if (e.code == 'wrong-password') {
        await errorDialog(context, "Incorrect password.");
      } else if (e.code == "invalid-email") {
        await errorDialog(context, "You've entered invalid email ");
      } else {
        await errorDialog(context, "Failed to login check your credentials.");
      }
      return false;
    } catch (e) {
      Navigator.of(context, rootNavigator: true).pop();
      await errorDialog(context, e.toString());
      return false;
    }
  }

  // google auth
  Future<bool> googleAuth(bool create, BuildContext context) async {
    try {
      UserCredential cred = await signInWithGoogle();
      User? user = cred.user;
      if (create) await createUser(user!.email!, user!.displayName!);
      SharedPreferences sharedPreferences =
          await SharedPreferences.getInstance();
      sharedPreferences.setString("userEmail", user!.email!);
      return true;
    } catch (e) {
      Navigator.of(context, rootNavigator: true).pop();
      print("error ---> $e");
      errorDialog(context, e.toString());
      return false;
    }
  }

  // google
  Future<UserCredential> signInWithGoogle() async {
    // Trigger the authentication flow
    final GoogleSignInAccount? googleUser = await GoogleSignIn().signIn();

    // Obtain the auth details from the request
    final GoogleSignInAuthentication? googleAuth =
        await googleUser?.authentication;

    // Create a new credential
    final credential = GoogleAuthProvider.credential(
      accessToken: googleAuth?.accessToken,
      idToken: googleAuth?.idToken,
    );

    // Once signed in, return the UserCredential
    return await FirebaseAuth.instance.signInWithCredential(credential);
  }

  Future<void> createUser(String email, String name) async {
    try {
      await FirebaseFirestore.instance.collection("Users").doc(email).set({
        "email": email,
        "username": name,
        "joinedOn": DateTime.now().toString()
      });
    } catch (e) {
      print("Failed creating user $e");
    }
  }

  errorDialog(BuildContext context, String msg) {
    AlertDialog alert = AlertDialog(
      title: Text("Failed"),
      content: Padding(
        padding: const EdgeInsets.fromLTRB(12.0, 0.0, 12.0, 12.0),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(
              msg,
              style: TextStyle(fontSize: 16),
            ),
            SizedBox(
              height: 20,
            ),
            SizedBox(
              height: 40,
              child: RaisedButton(
                shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(20)),
                color: Color(0xff01702E),
                onPressed: () {
                  Navigator.of(context, rootNavigator: true).pop();
                },
                child: Text(
                  "Okay",
                  style: TextStyle(color: Colors.white),
                ),
              ),
            )
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
