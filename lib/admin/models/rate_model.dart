class RatingModel {
  List<Rates>? rates;

  RatingModel({this.rates});

  RatingModel.fromJson(Map<String, dynamic> json) {
    if (json['rates'] != null) {
      rates = <Rates>[];
      json['rates'].forEach((v) {
        rates!.add(new Rates.fromJson(v));
      });
    }
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = new Map<String, dynamic>();
    if (this.rates != null) {
      data['rates'] = this.rates!.map((v) => v.toJson()).toList();
    }
    return data;
  }
}

class Rates {
  String? time;
  String? price;
  String? rateId;

  Rates({this.time, this.price, this.rateId});

  Rates.fromJson(Map<String, dynamic> json) {
    time = json['time'];
    price = json['price'];
    rateId = json['rateId'];
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = new Map<String, dynamic>();
    data['time'] = this.time;
    data['price'] = this.price;
    data['rateId'] = this.rateId;
    return data;
  }
}
