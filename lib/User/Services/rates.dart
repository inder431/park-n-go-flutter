import 'package:cloud_firestore/cloud_firestore.dart';

class RatesService {
  Future<Map?> getParkingRates() async {
    try {
      var snapshot =
          await FirebaseFirestore.instance.collection('ParkingRates').get();
      return (snapshot.docs[0].data() as Map)['rates'];
    } catch (e) {
      print("Error getting parking rates $e");
      return null;
    }
  }
}
