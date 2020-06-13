import 'dart:async';
import 'dart:collection';
import 'dart:convert';

import 'package:Flutter_Proj/constants/constant.dart';
import 'package:Flutter_Proj/model/busyHours.dart';
import 'package:Flutter_Proj/model/indiaCases_rootnet.dart';
import 'package:Flutter_Proj/widgets/counter.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:Flutter_Proj/model/churches.dart';
import '../model/churches.dart';

Future<String> _loadAChurchAsset() async {
  return await rootBundle.loadString('api/churches.json');
}

Future<ChurchList> loadChurch() async {
  await wait(5);
  String jsonString = await _loadAChurchAsset();
  final jsonResponse = json.decode(jsonString);
  return new ChurchList.fromJson(jsonResponse);
}

Future wait(int seconds) {
  return new Future.delayed(Duration(seconds: seconds), () => {});
}

class ChurchWidget extends StatefulWidget {
  @override
  ChurchState createState() => ChurchState();
  /**const GoogleMapWidget({Key key, this.choice}) : super(key: key);

  final Choice choice; */
}

class ChurchState extends State<ChurchWidget> {
  Completer<GoogleMapController> _controller = Completer();
  Future<IndiaCasesRootNet> futureIndiaTotalCases;
  static ChurchList _churchList;
  static Set<Marker> markerSet;
  bool _loaded = false;
  //static var currentHourStatus;
  static var map = new HashMap();
  static var today;
  double zoomVal = 5.0;
  @override
  void initState() {
    super.initState();
    futureIndiaTotalCases =
        fetchIndiaTotalCasesRootNet(); //fetchIndiaTotalCases();
    loadChurch().then((s) => setState(() {
          _churchList = s;
          _loaded = true;
        }));
    if (_churchList == null) return;
    if(_loaded = true){
    markerSet = createMarkerSetFromJsonData(_churchList);
    today = findTodayWeekday();
    findCurrentHourStatus();
    }
  }
  void findCurrentHourStatus(){
    var currentHour = DateTime.parse('1969-07-20 20:18:04Z').hour;
    //var currentHourStatus = "Busy Hour";    
    for (var i =0; i< _churchList.churches.length;i++){
      if(!_churchList.churches[i].busyHours.contains(currentHour)){
         var currentHourStatus ="Quiet Hour";
         map.putIfAbsent(_churchList.churches[i].name,() => currentHourStatus);
      }
     
    }

  }
  static String findTodayWeekday(){
    
         switch (DateTime.parse('1969-07-20 20:18:04Z').weekday) {
        case 1:
          return "Monday";
          break;
        case 2:
          return "Tuesday";
          break;
        case 3:
          return "Wednesday";
          break;
          case 4:
          return "Thursday";
          break;
          case 5:
          return "Friday";
          break;
          case 6:
          return "Saturday";
          break;
          case 7:
          return "Sunday";
          break;
      }
  }

  Set<Marker> createMarkerSetFromJsonData(ChurchList list) {
    Set<Marker> markerSet = new HashSet<Marker>();
    for (var i = 0; i < list.churches.length; i++) {
      markerSet.add(Marker(
        markerId: MarkerId(_churchList.churches[i].name),
        position: LatLng(double.parse(_churchList.churches[i].geometry.lat),
            double.parse(_churchList.churches[i].geometry.lng)),
        infoWindow: InfoWindow(title: _churchList.churches[i].formattedAddress),
        icon: BitmapDescriptor.defaultMarkerWithHue(
          BitmapDescriptor.hueOrange,
        ),
      ));
    }
    return markerSet;
  }

  Widget _zoomminusfunction() {
    return Align(
      alignment: Alignment.topLeft,
      child: IconButton(
          icon: Icon(FontAwesomeIcons.searchMinus, color: Colors.orange),
          onPressed: () {
            zoomVal--;
            _minus(zoomVal);
          }),
    );
  }

  Widget _zoomplusfunction() {
    return Align(
      alignment: Alignment.topRight,
      child: IconButton(
          icon: Icon(FontAwesomeIcons.searchPlus, color: Colors.orange),
          onPressed: () {
            zoomVal++;
            _plus(zoomVal);
          }),
    );
  }

  Future<void> _minus(double zoomVal) async {
    final GoogleMapController controller = await _controller.future;
    controller.animateCamera(CameraUpdate.newCameraPosition(
        CameraPosition(target: LatLng(40.712776, -74.005974), zoom: zoomVal)));
  }

  Future<void> _plus(double zoomVal) async {
    final GoogleMapController controller = await _controller.future;
    controller.animateCamera(CameraUpdate.newCameraPosition(
        CameraPosition(target: LatLng(40.712776, -74.005974), zoom: zoomVal)));
  }

  @override
  Widget build(BuildContext context) {
    return Stack(
      children: <Widget>[
     
        _buildGoogleMap(context),
        _zoomminusfunction(),
        _zoomplusfunction(),
        _buildContainer(),

      ],
    );
  }

  Widget _buildGoogleMap(BuildContext context) {
    return Container(
        height: 420,
        // height:MediaQuery.of(context).size.height ,
        //padding: EdgeInsets.all(10),
        width: MediaQuery.of(context).size.width,
        child: GoogleMap(
          mapType: MapType.normal,
          initialCameraPosition: CameraPosition(
            target: LatLng(
                double.parse(_churchList.churches[0].geometry.lat),
                double.parse(_churchList.churches[0].geometry
                    .lng)), //(40.712776, -74.005974),//LatLng(20.5937, 78.9629),
            //target:LatLng(latlng[0],latlng[1]),
            zoom: 12,
          ),
          onMapCreated: (GoogleMapController controller) {
            _controller.complete(controller);
            // _setMapStyle(controller);
          },
          //zoomControlsEnabled: false,
          // markers: {gramercyMarker, bernardinMarker, blueMarker},
          markers: createMarkerSetFromJsonData(_churchList),
        ));
  }

  Future<void> _gotoLocation(double lat, double long) async {
    final GoogleMapController controller = await _controller.future;
    controller.animateCamera(CameraUpdate.newCameraPosition(CameraPosition(
      target: LatLng(lat, long),
      zoom: 15,
      tilt: 50.0,
      bearing: 45.0,
    )));
  }

  Widget _boxes(String _image, Churches church) {
    //, lat,double long,String restaurantName) {
      var currentHour= DateTime.parse("1969-07-20 20:18:04Z");
      Color customColor = Colors.red;
      String hourStatus = "Busy Hour";
      /* if(map.containsKey(church.name)) {
          customColor = Colors.green;
          hourStatus = "Quiet Hour";
      } */
       if(church.busyHours.contains(currentHour)){
         hourStatus ="Busy Hour";
         customColor = Colors.red;
      }  else {
        hourStatus ="Queit Hour";
         customColor = Colors.green;
      }
    return GestureDetector(
      onTap: () {
        _gotoLocation(double.parse(church.geometry.lat),
            double.parse(church.geometry.lng));
      },
      child: Container(
        child: new FittedBox(
          child: Material(
            
              color:  customColor,
              elevation: 14.0,
              borderRadius: BorderRadius.circular(24.0),
              shadowColor: Color(0x802196F3),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: <Widget>[
                  Container(
                    width: 180,
                    height: 200,
                    child: ClipRRect(
                      borderRadius: new BorderRadius.circular(24.0),
                      child: Image(
                        fit: BoxFit.fill,
                        image: NetworkImage(_image),
                      ),
                    ),
                  ),
                  Container(
                    width: 180,
                    child: Padding(
                      padding: const EdgeInsets.all(8.0),
                      child: churchDetailsContainer(church, Colors.black, hourStatus),
                    ),
                  ),
                ],
              )),
        ),
      ),
    );
  }

  Widget buildBottomRowContainer(BuildContext context) {
    return FutureBuilder<IndiaCasesRootNet>(
      future: futureIndiaTotalCases,
      builder: (context, snapshot) {
        if (snapshot.hasData) {
          return _buildRowContainer(
              snapshot.data.data.unOffSummary[0].active,
              snapshot.data.data.unOffSummary[0].recovered,
              snapshot.data.data.unOffSummary[0].total,
              snapshot.data.data.unOffSummary[0].deaths);
        } else if (snapshot.hasError) {
          return Text("${snapshot.error}");
        }

        // By default, show a loading spinner.
        return CircularProgressIndicator();
      },
    );
  }

  Widget _buildRowContainer(
      int activeCases, int recoveredCases, int totalCases, int deathCases) {
    return Align(
      alignment: Alignment.bottomCenter,
      child: Container(
        //height: 100,
        width: double.infinity,
        //padding: EdgeInsets.all(13),
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(20),
          color: Colors.white,
          boxShadow: [
            BoxShadow(
              offset: Offset(0, 4),
              blurRadius: 30,
              color: kShadowColor,
            ),
          ],
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: <Widget>[
            Counter(
              color: kInfectedColor,
              number: activeCases,
              title: "Infected",
            ),
            Counter(
              color: kDeathColor,
              number: deathCases,
              title: "Deaths",
            ),
            Counter(
              color: kRecovercolor,
              number: recoveredCases,
              title: "Recovered",
            ),
            Counter(
              color: Colors.blueAccent,
              number: totalCases,
              title: "Total",
            ),
          ],
        ),
      ),
    );
  }

 
  Widget _buildContainer() {
    return Align(
      alignment: Alignment.bottomLeft,
      child: Container(
        margin: EdgeInsets.symmetric(vertical: 20.0),
        height: 150.0,
        child: ListView(
          scrollDirection: Axis.horizontal,
          children: <Widget>[
            SizedBox(width: 10.0),
            Padding(
              padding: const EdgeInsets.all(8.0),
              child: _boxes(
                  "https://encrypted-tbn0.gstatic.com/images?q=tbn%3AANd9GcRgrvsMmU-dg8BWDnJkZW4n-AnboZoXzSVdqYXBahcvCfFk1EVG&usqp=CAU",
                  _churchList.churches[0]), //"Gramercy Tavern"),
            ),
            SizedBox(width: 10.0),
            Padding(
              padding: const EdgeInsets.all(8.0),
              child: _boxes(
                  "https://encrypted-tbn0.gstatic.com/images?q=tbn%3AANd9GcTS7rMcoorM8i0p-B0MbuIQzXoUHFbpldzyAc8UkqMQYLffqI55&usqp=CAU",
                  _churchList.churches[
                      1]), //"Gramercy Tavern"),//40.761421, -73.981667,"Le Bernardin"),
            ),
            SizedBox(width: 10.0),
            Padding(
              padding: const EdgeInsets.all(8.0),
              child: _boxes(
                  "https://encrypted-tbn0.gstatic.com/images?q=tbn%3AANd9GcTQ6YBA6RC0P3tjxUDd2yIAEUIom3NW53QYgK4H8OStnoosEfL1&usqp=CAU",
                  _churchList.churches[
                      2]), //"Gramercy Tavern"),//40.732128, -73.999619,"Blue Hill"),
            ),
            SizedBox(width: 10.0),
            Padding(
              padding: const EdgeInsets.all(8.0),
              child: _boxes(
                  "https://encrypted-tbn0.gstatic.com/images?q=tbn%3AANd9GcSbZEHqMgEkHlcgx7pT1wM_6D8uICKRb2c5WIidLu2FDWjvNE3C&usqp=CAU",
                  _churchList.churches[
                      3]), //"Gramercy Tavern"),//40.732128, -73.999619,"Blue Hill"),
            ),
          ],
        ),
      ),
    );
  }

  Widget churchDetailsContainer(Churches church, Color customColor,String hourStatus) {
    return Column(
      mainAxisAlignment: MainAxisAlignment.spaceEvenly,
      children: <Widget>[
        Padding(
          padding: const EdgeInsets.only(left: 8.0),
          child: Container(
              width: 180,
              child: Text(
                church.name,
                textAlign: TextAlign.center,
                style: TextStyle(
                    color: customColor, //Colors.red,//Color(0xff6200ee),
                    fontSize: 24.0,
                    fontWeight: FontWeight.bold),
              )),
        ),
        SizedBox(height: 5.0),
        Container(
            child: Text(
          "Open Timings: ${church.hoursOpen[0].monday}",
          textAlign: TextAlign.center,
          style: TextStyle(
            color: Colors.black54,
            fontSize: 15.0,
            fontWeight: FontWeight.w700,
          ),
        )),
        SizedBox(height: 5.0),
        Container(
            child: Text(
          hourStatus,
          style: TextStyle(
              color: Colors.black87,
              fontSize: 18.0,
              fontWeight: FontWeight.bold),
        )),
        SizedBox(height: 5.0),
        Container(
            child: FlatButton(
                child: Text(
                  "Timing details",
                  style: TextStyle(
                      color: Colors.black87,
                      fontSize: 18.0,
                      fontWeight: FontWeight.bold,
                      decoration: TextDecoration.underline,
                      ),
                ),
                onPressed: () {
                  showDialog(context: context,
                  builder: (BuildContext context) => _buildHourDetailsDialog(context,church));})),
      ],
    );
  }

  Widget _buildHourDetailsDialog(BuildContext context, Churches church)  {
    return new AlertDialog(
      backgroundColor: Colors.black38,
      
      title:  Text('$today Timings ',style: TextStyle(color: Colors.amber, fontWeight: FontWeight.bold), ),
      content: new Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: <Widget>[
          //var now = DateTime.parse('1969-07-20 20:18:04Z').day;
          Text(
            'BusyHours Today',
            textAlign: TextAlign.center,
            style: TextStyle(color: Colors.red, fontWeight: FontWeight.bold),
          ),
          Text(
            (() {
              switch (today) {
                case "Monday":
                  return "${church.busyHours[0].monday.sublist(0).toString()}";
                  break;
                case "Tuesday":
                  return "${church.busyHours[0].tuesday.sublist(0).toString()}";
                  break;
                  case "Wednesday":
                  return "${church.busyHours[0].wednesday.sublist(0).toString()}";
                  break;
                  case "Thursday":
                  return "${church.busyHours[0].thursday.sublist(0).toString()}";
                  break;
                  case "Friday":
                  return "${church.busyHours[0].friday.sublist(0).toString()}";
                  break;
                  case "Saturday":
                  return "${church.busyHours[0].saturday.sublist(0).toString()}";
                  break;
                  case "Sunday":
                  return "${church.busyHours[0].sunday.sublist(0).toString()}";
                  break;
              }

            })(),
            textAlign: TextAlign.center,
            style: TextStyle(color: Colors.redAccent),
          ),
          SizedBox(height: 5,),
          Text(
            'QuietHours Today',
            textAlign: TextAlign.center,
            style: TextStyle(color: Colors.green, fontWeight: FontWeight.bold),
          ),
          Text(
            (() {
              if (DateTime.parse('1969-07-20 20:18:04Z').weekday == 1) {
                return "${church.quietHours[0].monday.sublist(0).toString()}";
              }
              if (DateTime.parse('1969-07-20 20:18:04Z').weekday == 2) {
                return "${church.quietHours[0].tuesday.sublist(0).toString()}";
              }
              if (DateTime.parse('1969-07-20 20:18:04Z').weekday == 3) {
                return "${church.quietHours[0].wednesday.sublist(0).toString()}";
              }
              if (DateTime.parse('1969-07-20 20:18:04Z').weekday == 4) {
                return "${church.quietHours[0].thursday.sublist(0).toString()}";
              }
              if (DateTime.parse('1969-07-20 20:18:04Z').weekday == 5) {
                return "${church.quietHours[0].friday.sublist(0).toString()}";
              }
              if (DateTime.parse('1969-07-20 20:18:04Z').weekday == 6) {
                return "${church.quietHours[0].saturday.sublist(0).toString()}";
              }

              return "${church.quietHours[0].sunday.sublist(0).toString()}";
            })(),
            textAlign: TextAlign.center,
            style: TextStyle(color: Colors.green,),
          ),
          /*  if (DateTime.parse('1969-07-20 20:18:04Z').weekday == 1){
               // Text('Hello'),
               print( DateTime.parse('1969-07-20 20:18:04Z').weekday == 1 +'hello')
                //Text('${church.busyHours[0].monday.indexOf(1).toString()}',textAlign: TextAlign.justify,),
          } else
          Text('Hello'), */

          // _buildAboutText(),
          // _buildLogoAttribution(),
        ],
      ),
      actions: <Widget>[
        new FlatButton(
          onPressed: () {
            Navigator.of(context).pop();
          },
          textColor: Theme.of(context).primaryColor,
          child: const Text('Okay, got it!'),
        ),
      ],
    );
  }
}
