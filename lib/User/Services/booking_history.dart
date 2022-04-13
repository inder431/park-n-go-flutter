import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:parking_go/common/models/ReservationModel.dart';
import 'package:shared_preferences/shared_preferences.dart';

class BookingHistoryService {
  Future<List<ReservationModel>> getBookingHistory() async {
    List<ReservationModel> reservations = [];
    try {
      SharedPreferences sharedPreferences =
          await SharedPreferences.getInstance();
      String uid = sharedPreferences.getString("userEmail")!;
      QuerySnapshot snapshot = await FirebaseFirestore.instance
          .collection('Reservation')
          .where('uid', isEqualTo: uid)
          .get();
      if (snapshot.docs.length > 0) {
        for (DocumentSnapshot ds in snapshot.docs) {
          reservations.add(
              ReservationModel.fromJson(ds.data() as Map<String, dynamic>));
        }
      }
      return reservations;
    } catch (e) {
      print("Error making your reservation $e");
      return reservations;
    }
  }
}
