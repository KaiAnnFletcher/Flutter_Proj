import 'package:Flutter_Proj/model/busyHours.dart';
import 'package:Flutter_Proj/model/geometry.dart';
import 'package:Flutter_Proj/model/hoursOpen.dart';
import 'package:Flutter_Proj/model/quietHours.dart';

class DensityModel {
  String name;
  String formattedAddress;
  Geometry geometry;
  List<HoursOpen> hoursOpen;
  List<BusyHours> busyHours;
  List<QuietHours> quietHours;

  DensityModel(
      {this.name,
      this.formattedAddress,
      this.geometry,
      this.hoursOpen,
      this.busyHours,
      this.quietHours});
}