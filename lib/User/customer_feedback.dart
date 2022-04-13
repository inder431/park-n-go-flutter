import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_rating_bar/flutter_rating_bar.dart';

class CustomerFeedbackScreen extends StatefulWidget {
  const CustomerFeedbackScreen({Key? key}) : super(key: key);

  @override
  _CustomerFeedbackScreenState createState() => _CustomerFeedbackScreenState();
}

class _CustomerFeedbackScreenState extends State<CustomerFeedbackScreen> {
  late double w, h;
  TextEditingController feedbackController = new TextEditingController();
  @override
  void initState() {
    SystemChrome.setEnabledSystemUIOverlays([]);
    super.initState();
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
        padding: EdgeInsets.only(left: 14),
        child: SingleChildScrollView(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Container(
                  margin: EdgeInsets.only(top: 36),
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
                child: Image.asset(
                  'assets/logo.png',
                  width: w * .3,
                  height: w * .3,
                ),
              ),
              SizedBox(
                height: 20,
              ),
              Center(
                child: Text(
                  "Park'n Go",
                  style: TextStyle(
                      fontFamily: 'ropasans',
                      color: Colors.black,
                      fontSize: 24),
                ),
              ),
              SizedBox(
                height: h * .1,
              ),
              Text(
                "Rate This App",
                style: TextStyle(
                    fontFamily: 'ropasans', color: Colors.black, fontSize: 24),
              ),
              SizedBox(
                height: h * .01,
              ),
              RatingBar.builder(
                initialRating: 0,
                minRating: 1,
                direction: Axis.horizontal,
                allowHalfRating: true,
                itemCount: 5,
                itemPadding: EdgeInsets.symmetric(horizontal: 4.0),
                itemBuilder: (context, _) => Icon(
                  Icons.star,
                  color: Colors.amber,
                ),
                onRatingUpdate: (rating) {
                  print(rating);
                },
              ),
              SizedBox(
                height: h * .03,
              ),
              textFeild("Lave A Comment", feedbackController),
              SizedBox(
                height: h * .08,
              ),
              Center(
                child: SizedBox(
                  width: w * .8,
                  height: 60,
                  child: ElevatedButton(
                      onPressed: () {},
                      child: Text(
                        'Submit',
                        style: TextStyle(
                            color: Colors.white,
                            fontWeight: FontWeight.bold,
                            fontSize: 24,
                            letterSpacing: .9),
                      ),
                      style: ElevatedButton.styleFrom(
                        primary: Color(0xff41B546),
                      )),
                ),
              ),
              SizedBox(
                height: h * .04,
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget textFeild(String hint, TextEditingController controller) {
    return Container(
      color: Color(0xffE0DFDF),
      width: w * .8,
      child: TextField(
        minLines: 4,
        keyboardType: TextInputType.multiline,
        maxLines: null,
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
}
