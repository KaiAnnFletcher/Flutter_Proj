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
    //futureIndiaTotalCases =        fetchIndiaTotalCasesRootNet(); //fetchIndiaTotalCases();
        if(mounted) { // Added this check prevent error which occurs when widget is not present in the parent tree.
    loadRestaurant().then((s) => setState(() {
          _storeList = s;
          _loaded = true;
        }));
    if (_storeList == null) return null;
    markerSet = createMarkerSetFromJsonData(_storeList);
    today = findTodayWeekday();
  }
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
    
    switch (DateTime.now().weekday) {
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
String getHourStatus (Stores store) {
      var currentHour = DateTime.now().hour;
    
    switch (today) {
                case "Monday": if(store.busyHours[0].monday.contains(currentHour))
                  return "Busy Hour";
                  else
                  return "Quiet Hour";
                  break;
                case "Tuesday":
                  if(store.busyHours[0].tuesday.contains(currentHour)){
                  return "Busy Hour";
                  }
                  else{
                  return "Quiet Hour";
                      }
                  break;
                  case "Wednesday":
                  if(store.busyHours[0].wednesday.contains(currentHour)){
                  return "Busy Hour";
                  }
                  else{
                  return "Quiet Hour";
                      }
                  break;
                  case "Thursday":
                  if(store.busyHours[0].thursday.contains(currentHour)){
                  return "Busy Hour";
                  }
                  else{
                  return "Quiet Hour";
                      }
                  break;
                  case "Friday":
                  if(store.busyHours[0].friday.contains(currentHour)){
                  return "Busy Hour";
                  }
                  else{
                  return "Quiet Hour";
                      }
                  break;
                  case "Saturday":
                  if(store.busyHours[0].saturday.contains(currentHour)){
                  return "Busy Hour";
                  }
                  else{
                  return "Quiet Hour";
                      }
                  break;
                  case "Sunday":
                  if(store.busyHours[0].sunday.contains(currentHour)){
                  return "Busy Hour";
                  }
                  else{
                  return "Quiet Hour";
                      }
                  break;
                  default: "";
                  break;

  }
  }
  Widget _boxes(String _image, Stores store) {
    Color customColor = Colors.red;
      String hourStatus = getHourStatus(store);
      if(hourStatus == "Quiet Hour"){
        customColor = Colors.green;
      } else {
        customColor = Colors.red;
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
                  "https://d2xpeceo701ble.cloudfront.net/~/media/images/pages/2017/macys-herald-sq/macys_768_opt.jpg?vs=1&d=20170623T184348Z",
                  _storeList.stores[0]), 
            ),
            SizedBox(width: 10.0),
            Padding(
              padding: const EdgeInsets.all(8.0),
              child: _boxes(
                  "https://specials-images.forbesimg.com/imageserve/5daedd54616a45000704463c/960x0.jpg?cropX1=0&cropX2=2400&cropY1=15&cropY2=1617",
                  _storeList.stores[
                      1]), 
            ),
            SizedBox(width: 10.0),
            Padding(
              padding: const EdgeInsets.all(8.0),
              child: _boxes(
                  "https://fashionweekdaily.com/wp-content/uploads/2019/11/shutterstock_485085631.jpg",
                  _storeList.stores[
                      2]), 
            ),
            SizedBox(width: 10.0),
            Padding(
              padding: const EdgeInsets.all(8.0),
              child: _boxes(
                  "https://s3-media0.fl.yelpcdn.com/bphoto/OWUg4d-58VCoaGClRVoolw/348s.jpg",
                  _storeList.stores[
                      3]), 
            ),
          ],
        ),
      ),
    );
  }

  Widget storeDetailsContainer(Stores store,String hourStatus) {
    String hoursOpen = [].toString();
    hoursOpen = getOpenHour(store);
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
          "Open Timings: ${hoursOpen}",
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
          hourStatus == null ? 'BusyHour': hourStatus,
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
                    color: Colors.deepPurple,
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
    String todayValue = "Today";
    todayValue = today;
    if(store == null){
    return CircularProgressIndicator();
  }else
    return new AlertDialog(
      backgroundColor: Colors.black38,
      title: Text(
        '${todayValue == null ? 'Today':todayValue} Timings ',
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
            getBusyHourTimingDetails(store) == null? '':getBusyHourTimingDetails(store),
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
            getQuietHourTimingDetails(store) == null?'' :getQuietHourTimingDetails(store),
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
   String getOpenHour (Stores store) {
    switch (today) {
                case "Monday":
                  return "${store.hoursOpen[0].monday.toString()}";
                  break;
                case "Tuesday":
                  return "${store.hoursOpen[0].tuesday.toString()}";
                  break;
                  case "Wednesday":
                  return "${store.hoursOpen[0].wednesday.toString()}";
                  break;
                  case "Thursday":
                  return "${store.hoursOpen[0].thursday.toString()}";
                  break;
                  case "Friday":
                  return "${store.hoursOpen[0].friday.toString()}";
                  break;
                  case "Saturday":
                  return "${store.hoursOpen[0].saturday.toString()}";
                  break;
                  case "Sunday":
                  return "${store.hoursOpen[0].sunday.toString()}";
                  break;
                  default: "";
                  break;
              }
    
  }
   String getBusyHourTimingDetails (Stores store ){
   
              switch (today) {
                case "Monday":
                  return "${store.busyHours[0].monday.toString()}";
                  break;
                case "Tuesday":
                  return "${store.busyHours[0].tuesday.toString()}";
                  break;
                  case "Wednesday":
                  return "${store.busyHours[0].wednesday.toString()}";
                  break;
                  case "Thursday":
                  return "${store.busyHours[0].thursday.toString()}";
                  break;
                  case "Friday":
                  return "${store.busyHours[0].friday.toString()}";
                  break;
                  case "Saturday":
                  return "${store.busyHours[0].saturday.toString()}";
                  break;
                  case "Sunday":
                  return "${store.busyHours[0].sunday.toString()}";
                  break;
                  default: "";
                  break;
              }
            
  }
  String getQuietHourTimingDetails (Stores store ){
   
              switch (today) {
                case "Monday":
                  return "${store.quietHours[0].monday.toString()}";
                  break;
                case "Tuesday":
                  return "${store.quietHours[0].tuesday.toString()}";
                  break;
                  case "Wednesday":
                  return "${store.quietHours[0].wednesday.toString()}";
                  break;
                  case "Thursday":
                  return "${store.quietHours[0].thursday.toString()}";
                  break;
                  case "Friday":
                  return "${store.quietHours[0].friday.toString()}";
                  break;
                  case "Saturday":
                  return "${store.quietHours[0].saturday.toString()}";
                  break;
                  case "Sunday":
                  return "${store.quietHours[0].sunday.toString()}";
                  break;
                  default: "";
                  break;
              }
            
  }
 

}
