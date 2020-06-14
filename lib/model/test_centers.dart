import 'package:Flutter_Proj/model/densityModel.dart';
import 'package:Flutter_Proj/model/geometry.dart';
import 'package:Flutter_Proj/model/hoursOpen.dart';

class TestCenterList {
  List<TestCenters> testCenters = new List<TestCenters>();

  TestCenterList({this.testCenters});

  TestCenterList.fromJson(Map<String, dynamic> json) {
    if (json['test_centers'] != null) {
      //testCenters = new List<TestCenters>();
      json['test_centers'].forEach((v) {
        testCenters.add(new TestCenters.fromJson(v));
      });
    }
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = new Map<String, dynamic>();
    if (this.testCenters != null) {
      data['test_centers'] = this.testCenters.map((v) => v.toJson()).toList();
    }
    return data;
  }
}

class TestCenters extends DensityModel{
  String name;
  String formattedAddress;
  Geometry geometry;
  List<HoursOpen> hoursOpen;
  List<String> testingDetails;
  String uRL;

  TestCenters(
      {this.name,
      this.formattedAddress,
      this.geometry,
      this.hoursOpen,
      this.testingDetails,
      this.uRL});

  TestCenters.fromJson(Map<String, dynamic> json) {
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
    testingDetails = json['testing-details'].cast<String>();
    uRL = json['URL'];
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
    data['testing-details'] = this.testingDetails;
    data['URL'] = this.uRL;
    return data;
  }
}

