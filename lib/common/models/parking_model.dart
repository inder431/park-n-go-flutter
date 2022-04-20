class ParkingModel {
  List<ParkingFloors>? parkingFloors;

  ParkingModel({this.parkingFloors});

  ParkingModel.fromJson(Map<String, dynamic> json) {
    if (json['parkingFloors'] != null) {
      parkingFloors = <ParkingFloors>[];
      json['parkingFloors'].forEach((v) {
        parkingFloors!.add(new ParkingFloors.fromJson(v));
      });
    }
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = new Map<String, dynamic>();
    if (this.parkingFloors != null) {
      data['parkingFloors'] =
          this.parkingFloors!.map((v) => v.toJson()).toList();
    }
    return data;
  }
}

class ParkingFloors {
  String? floorName;
  String? floorId;
  List<ParkingSlots>? parkingSlots;
  int? status;
  ParkingFloors({this.floorName, this.floorId, this.parkingSlots, this.status});

  ParkingFloors.fromJson(Map<String, dynamic> json) {
    floorName = json['floorName'];
    floorId = json['floorId'];
    status = json['status'];
    if (json['parking_slots'] != null) {
      parkingSlots = <ParkingSlots>[];
      json['parking_slots'].forEach((v) {
        parkingSlots!.add(new ParkingSlots.fromJson(v));
      });
    }
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = new Map<String, dynamic>();
    data['floorName'] = this.floorName;
    data['floorId'] = this.floorId;
    data['status'] = this.status;
    if (this.parkingSlots != null) {
      data['parking_slots'] =
          this.parkingSlots!.map((v) => v.toJson()).toList();
    }
    return data;
  }
}

class ParkingSlots {
  bool selected = false;
  String? slotId;
  String? slotName;
  int? status;

  ParkingSlots({this.slotId, this.slotName, this.status});

  ParkingSlots.fromJson(Map<String, dynamic> json) {
    slotId = json['slotId'];
    slotName = json['slotName'];
    status = json['status'];
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = new Map<String, dynamic>();
    data['slotId'] = this.slotId;
    data['slotName'] = this.slotName;
    data['status'] = this.status;
    return data;
  }
}
