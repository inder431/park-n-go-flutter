import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/cupertino.dart';
import 'package:google_sign_in/google_sign_in.dart';
import 'package:parking_go/common/models/ReservationModel.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:toast/toast.dart';

import '../../common/models/parking_model.dart';

class ParkingService {
  Future<ParkingModel?> loadParking() async {
    try {
      ParkingModel pkm = new ParkingModel();
      pkm.parkingFloors = [];
      DocumentSnapshot ds = await FirebaseFirestore.instance
          .collection('Parking')
          .doc('parking')
          .get();
      if (ds.exists)
        return ParkingModel.fromJson(ds.data() as Map<String, dynamic>);
      else
        return pkm;
    } catch (e) {
      print("Error getting parking $e");
      return null;
    }
  }

  // update,create
  Future<bool> updateParking(ParkingModel pkm) async {
    try {
      FirebaseFirestore.instance
          .collection('Parking')
          .doc('parking')
          .set(pkm.toJson(), SetOptions(merge: true));
      return true;
    } catch (e) {
      print("Error updating parking $e");
      return false;
    }
  }

  Future<void> makeReservation(
      BuildContext context, ParkingModel pkm, ReservationModel rsm) async {
    try {
      SharedPreferences sharedPreferences =
          await SharedPreferences.getInstance();
      rsm.uid = sharedPreferences.getString("userEmail");
      for (int i = 0; i < pkm.parkingFloors!.length; i++) {
        for (int j = 0; j < pkm.parkingFloors![i].parkingSlots!.length; j++) {
          int status = pkm.parkingFloors![i].parkingSlots![j].status!;
          if (status == 1) {
            // selected
            pkm.parkingFloors![i].parkingSlots![j].status = 2;
            break;
          }
        }
      }
      await updateParking(pkm);
      await FirebaseFirestore.instance
          .collection('Reservation')
          .add(rsm.toJson());
    } catch (e) {
      Toast.show("Error making your reservation $e", context);
      print("Error making your reservation $e");
    }
  }

  Future<void> cancelledReservation(
      BuildContext context, ReservationModel rsm) async {
    try {
      SharedPreferences sharedPreferences =
          await SharedPreferences.getInstance();
      rsm.uid = sharedPreferences.getString("userEmail");
      await FirebaseFirestore.instance
          .collection('Reservation')
          .add(rsm.toJson());
    } catch (e) {
      Toast.show("Error cancelling your reservation $e", context);
      print("Error cancelling your reservation $e");
    }
  }
}
