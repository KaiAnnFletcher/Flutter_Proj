import 'package:Flutter_Proj/model/busyHours.dart';
import 'package:Flutter_Proj/model/densityModel.dart';
import 'package:Flutter_Proj/model/geometry.dart';
import 'package:Flutter_Proj/model/hoursOpen.dart';
import 'package:Flutter_Proj/model/quietHours.dart';

class StoreList {
  List<Stores> stores;

  StoreList({this.stores});

  StoreList.fromJson(Map<String, dynamic> json) {
    if (json['stores'] != null) {
      stores = new List<Stores>();
      json['stores'].forEach((v) {
        stores.add(new Stores.fromJson(v));
      });
    }
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = new Map<String, dynamic>();
    if (this.stores != null) {
      data['stores'] = this.stores.map((v) => v.toJson()).toList();
    }
    return data;
  }
}

class Stores extends DensityModel {
  String name;
  String formattedAddress;
  Geometry geometry;
  List<HoursOpen> hoursOpen;
  List<BusyHours> busyHours;
  List<QuietHours> quietHours;

  Stores(
      {this.name,
      this.formattedAddress,
      this.geometry,
      this.hoursOpen,
      this.busyHours,
      this.quietHours});

  Stores.fromJson(Map<String, dynamic> json) {
    name = json['name'];
    formattedAddress = json['formatted_address'];
    geometry = json['geometry'] != null
        ? new Geometry.fromJson(json['geometry'])
        : null;
    if (json['hours_open'] != null) {
      hoursOpen = new List<HoursOpen>();
      json['hours_open'].forEach((v) {
        hoursOpen.add(new HoursOpen.fromJson(v));
      });
    }
    if (json['busy-hours'] != null) {
      busyHours = new List<BusyHours>();
      json['busy-hours'].forEach((v) {
        busyHours.add(new BusyHours.fromJson(v));
      });
    }
    if (json['quiet-hours'] != null) {
      quietHours = new List<QuietHours>();
      json['quiet-hours'].forEach((v) {
        quietHours.add(new QuietHours.fromJson(v));
      });
    }
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = new Map<String, dynamic>();
    data['name'] = this.name;
    data['formatted_address'] = this.formattedAddress;
    if (this.geometry != null) {
      data['geometry'] = this.geometry.toJson();
    }
    if (this.hoursOpen != null) {
      data['hours_open'] = this.hoursOpen.map((v) => v.toJson()).toList();
    }
    if (this.busyHours != null) {
      data['busy-hours'] = this.busyHours.map((v) => v.toJson()).toList();
    }
    if (this.quietHours != null) {
      data['quiet-hours'] = this.quietHours.map((v) => v.toJson()).toList();
    }
    return data;
  }
}




