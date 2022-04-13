import 'package:cloud_firestore/cloud_firestore.dart';

class ReservationModel {
  String? resId;
  String? hour;
  String? min;
  String? amountBeforeTax;
  String? gst;
  String? qst;
  String? totalAmount;
  String? slotId;
  String? uid;
  int? status;
  DateTime? dateTime;
  ReservationModel(
      {this.resId,
      this.hour,
      this.min,
      this.amountBeforeTax,
      this.gst,
      this.qst,
      this.totalAmount,
      this.slotId}) {
    dateTime = DateTime.now();
  }

  ReservationModel.fromJson(Map<String, dynamic> json) {
    resId = json['resId'];
    hour = json['hour'];
    min = json['min'];
    amountBeforeTax = json['amountBeforeTax'];
    gst = json['gst'];
    qst = json['qst'];
    totalAmount = json['totalAmount'];
    slotId = json['slotId'];
    uid = json['uid'];
    status = json['status'];
    dateTime = (json['date'] as Timestamp).toDate();
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = new Map<String, dynamic>();
    data['resId'] = this.resId;
    data['hour'] = this.hour;
    data['min'] = this.min;
    data['amountBeforeTax'] = this.amountBeforeTax;
    data['gst'] = this.gst;
    data['qst'] = this.qst;
    data['totalAmount'] = this.totalAmount;
    data['slotId'] = this.slotId;
    data['uid'] = this.uid;
    data['status'] = this.status;
    data['date'] = this.dateTime;
    return data;
  }
}
