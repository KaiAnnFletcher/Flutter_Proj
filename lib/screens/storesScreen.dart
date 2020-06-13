import 'dart:async';
import 'dart:collection';
import 'dart:convert';

import 'package:Flutter_Proj/constants/constant.dart';
import 'package:Flutter_Proj/model/indiaCases_rootnet.dart';
import 'package:Flutter_Proj/widgets/counter.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';

import '../model/stores.dart';

Future<String> _loadARestauranttAsset() async {
  return await rootBundle.loadString('api/stores.json');
}

Future<StoreList> loadRestaurant() async {
  await wait(15);
  String jsonString = await _loadARestauranttAsset();
  final jsonResponse = json.decode(jsonString);
  return new StoreList.fromJson(jsonResponse);
}

Future wait(int seconds) {
  return new Future.delayed(Duration(seconds: seconds), () => {});
}

class StoreWidget extends StatefulWidget {
  @override
  StoreState createState() => StoreState();
  /**const GoogleMapWidget({Key key, this.choice}) : super(key: key);

  final Choice choice; */
}

class StoreState extends State<StoreWidget> {
  Completer<GoogleMapController> _controller = Completer();
  Future<IndiaCasesRootNet> futureIndiaTotalCases;
  static StoreList _storeList;
  static Set<Marker> markerSet;
  static var today;
  bool _loaded = false;
  double zoomVal = 5.0;
  @override
  void initState() {
    super.initState();
    futureIndiaTotalCases =
        fetchIndiaTotalCasesRootNet(); //fetchIndiaTotalCases();
    loadRestaurant().then((s) => setState(() {
          _storeList = s;
          _loaded = true;
        }));
    if (_storeList == null) return null;
    markerSet = createMarkerSetFromJsonData(_storeList);
    today = findTodayWeekday();
  }

  Set<Marker> createMarkerSetFromJsonData(StoreList list) {
    Set<Marker> markerSet = new HashSet<Marker>();
    if (list == null) return markerSet;
    for (var i = 0; i < list.stores.length; i++) {
      markerSet.add(Marker(
        markerId: MarkerId(_storeList.stores[i].name),
        position: LatLng(double.parse(_storeList.stores[i].geometry.lat),
            double.parse(_storeList.stores[i].geometry.lng)),
        infoWindow: InfoWindow(title: _storeList.stores[i].formattedAddress),
        icon: BitmapDescriptor.defaultMarkerWithHue(
          BitmapDescriptor.hueOrange,
        ),
      ));
    }
    return markerSet;
  }

  static String findTodayWeekday() {
    print(DateTime.parse('1969-07-20 20:18:04Z').weekday);
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
     if(_storeList == null) {
      return SizedBox(
                child: CircularProgressIndicator(
                  backgroundColor: Colors.amber,
                  strokeWidth: 10,
                ),
                height: 20.0,
                width: 20.0,
              );
    } else
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
        width: MediaQuery.of(context).size.width,
        child: GoogleMap(
          mapType: MapType.normal,
          initialCameraPosition: CameraPosition(
            target: LatLng(
                double.parse(_storeList.stores[0].geometry.lat),
                double.parse(_storeList.stores[0].geometry
                    .lng)), 
            zoom: 12,
          ),
          onMapCreated: (GoogleMapController controller) {
            _controller.complete(controller);
            
          },
          zoomControlsEnabled: false,
          markers: createMarkerSetFromJsonData(_storeList),
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

  Widget _boxes(String _image, Stores store) {
    var currentHour= DateTime.now().hour;
      Color customColor = Colors.red;
      String hourStatus = "Busy Hour";
      /* if(map.containsKey(church.name)) {
          customColor = Colors.green;
          hourStatus = "Quiet Hour";
      } */
       if(store.busyHours.contains(currentHour)){
         hourStatus ="Busy Hour";
         customColor = Colors.red;
      }  else {
        hourStatus ="Queit Hour";
         customColor = Colors.green;
      }
    return GestureDetector(
      onTap: () {
        _gotoLocation(
            double.parse(store.geometry.lat), double.parse(store.geometry.lng));
      },
      child: Container(
        child: new FittedBox(
          child: Material(
              color: customColor,
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
                    width: 200,
                    child: Padding(
                      padding: const EdgeInsets.all(8.0),
                      child: storeDetailsContainer(store,hourStatus),
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
                  "https://lh5.googleusercontent.com/p/AF1QipPBQ8AYzjMK8ivgd5gC2qj1LRLmmt-xi4EprK0m=w108-h108-n-k-no",
                  _storeList.stores[0]), 
            ),
            SizedBox(width: 10.0),
            Padding(
              padding: const EdgeInsets.all(8.0),
              child: _boxes(
                  "https://lh5.googleusercontent.com/p/AF1QipO8qPRg9SqQWKYsxlcJRKHIqs6EkJ6me0CZW7NP=w108-h108-n-k-no",
                  _storeList.stores[
                      1]), 
            ),
            SizedBox(width: 10.0),
            Padding(
              padding: const EdgeInsets.all(8.0),
              child: _boxes(
                  "https://lh5.googleusercontent.com/p/AF1QipObRlxdndVweV8jlB3tp33PqsORblasqA1rUt4E=w108-h108-n-k-no",
                  _storeList.stores[
                      2]), 
            ),
            SizedBox(width: 10.0),
            Padding(
              padding: const EdgeInsets.all(8.0),
              child: _boxes(
                  "https://lh5.googleusercontent.com/p/AF1QipNZupw6idK-83MSVV9dzrSfgJYhIaEVPjYQI20W=w108-h108-n-k-no",
                  _storeList.stores[
                      3]), 
            ),
          ],
        ),
      ),
    );
  }

  Widget storeDetailsContainer(Stores store,String hourStatus) {
    return Column(
      mainAxisAlignment: MainAxisAlignment.spaceEvenly,
      children: <Widget>[
        Padding(
          padding: const EdgeInsets.only(left: 8.0),
          child: Container(
              width: 180,
              child: Text(
                store.name, textAlign: TextAlign.center,
                //softWrap: true,
                style: TextStyle(
                    color: Colors.black, //Color(0xff6200ee),
                    fontSize: 24.0,
                    fontWeight: FontWeight.bold),
              )),
        ),
        Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: <Widget>[
            Container(
              child: Text(
                'Delivery:',
                //textAlign: TextAlign.right,
                style: TextStyle(
                  color: Colors.black,
                  fontSize: 18.0,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
            Container(
              child: Text(
                ' Yes',
                style: TextStyle(
                  color: Colors.orange,
                  fontSize: 18.0,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
          ],
        ),
        SizedBox(height: 5.0),
        Container(
            child: Text(
          "Open Timings: ${store.hoursOpen[0].monday}",
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
        Container(
            padding: EdgeInsets.all(0.0),
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
                  showDialog(
                      context: context,
                      builder: (BuildContext context) =>
                          _buildHourDetailsDialog(context, store));
                })),
      ],
    );
  }

  Widget _buildHourDetailsDialog(BuildContext context, Stores store) {
    if(store == null){
    return CircularProgressIndicator();
  }else
    return new AlertDialog(
      backgroundColor: Colors.black38,
      title: Text(
        '$today Timings ',
        style: TextStyle(color: Colors.amber, fontWeight: FontWeight.bold),
      ),
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
                  return "${store.busyHours[0].monday.sublist(0).toString()}";
                  break;
                case "Tuesday":
                  return "${store.busyHours[0].tuesday.sublist(0).toString()}";
                  break;
                case "Wednesday":
                  return "${store.busyHours[0].wednesday.sublist(0).toString()}";
                  break;
                case "Thursday":
                  return "${store.busyHours[0].thursday.sublist(0).toString()}";
                  break;
                case "Friday":
                  return "${store.busyHours[0].friday.sublist(0).toString()}";
                  break;
                case "Saturday":
                  return "${store.busyHours[0].saturday.sublist(0).toString()}";
                  break;
                case "Sunday":
                  return "${store.busyHours[0].sunday.sublist(0).toString()}";
                  break;
                  default: "";
                  break;
              }
            })(),
            textAlign: TextAlign.center,
            style: TextStyle(color: Colors.redAccent),
          ),
          SizedBox(
            height: 5,
          ),
          Text(
            'QuietHours Today',
            textAlign: TextAlign.center,
            style: TextStyle(color: Colors.green, fontWeight: FontWeight.bold),
          ),
          Text(
            (() {
              if (DateTime.now().weekday == 1) {
                return "${store.quietHours[0].monday.sublist(0).toString()}";
              }
              if (DateTime.now().weekday == 2) {
                return "${store.quietHours[0].tuesday.sublist(0).toString()}";
              }
              if (DateTime.now().weekday == 3) {
                return "${store.quietHours[0].wednesday.sublist(0).toString()}";
              }
              if (DateTime.now().weekday == 4) {
                return "${store.quietHours[0].thursday.sublist(0).toString()}";
              }
              if (DateTime.now().weekday == 5) {
                return "${store.quietHours[0].friday.sublist(0).toString()}";
              }
              if (DateTime.now().weekday == 6) {
                return "${store.quietHours[0].saturday.sublist(0).toString()}";
              }
              if (DateTime.now().weekday == 7) {
                return "${store.quietHours[0].saturday.sublist(0).toString()}";
              }
              else
              return "";
              
            })(),
            textAlign: TextAlign.center,
            style: TextStyle(
              color: Colors.green,
            ),
          ),
         
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
