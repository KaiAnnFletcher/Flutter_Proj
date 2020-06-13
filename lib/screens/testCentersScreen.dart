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
import '../model/test_centers.dart';


Future<String> _loadATestCenterAsset() async {
  return await rootBundle.loadString('api/test_centers.json');
}

Future<TestCenterList> loadTestCenter() async {
  await wait(5);
  String jsonString = await _loadATestCenterAsset();
  final jsonResponse = json.decode(jsonString);
  
  return new TestCenterList.fromJson(jsonResponse);
}

Future wait(int seconds) {
  return new Future.delayed(Duration(seconds: seconds), () => {});
}

class TestCenterWidget extends StatefulWidget {
  @override
  TestCenterState createState() => TestCenterState();  
}

class TestCenterState extends State<TestCenterWidget> {
  Completer<GoogleMapController> _controller = Completer();
  Future<IndiaCasesRootNet> futureIndiaTotalCases;
  static TestCenterList _testcenterList;
  static Set<Marker> markerSet;
  bool _loaded = false;
  static var today ;
  double zoomVal = 5.0;
  @override
  void initState() {
    super.initState();
    futureIndiaTotalCases =
        fetchIndiaTotalCasesRootNet(); //fetchIndiaTotalCases();
        loadTestCenter().then((s) => setState(() {
          _testcenterList = s;
          _loaded = true;
        }));
        //if(_testcenterList == null) return ;
        markerSet = createMarkerSetFromJsonData(_testcenterList);
        today = findTodayWeekday();
  }
  Set<Marker> createMarkerSetFromJsonData(TestCenterList list){
    Set<Marker> markerSet = new HashSet<Marker>();
    if (list == null) return markerSet;
    for (var i = 0; i < list.testCenters.length;i++ ){
      markerSet.add(Marker(
   markerId: MarkerId(_testcenterList.testCenters[i].name),
    position: LatLng(double.parse(_testcenterList.testCenters[i].geometry.lat), double.parse(_testcenterList.testCenters[i].geometry.lng)),
    infoWindow: InfoWindow(title: _testcenterList.testCenters[i].formattedAddress),
    icon: BitmapDescriptor.defaultMarkerWithHue(
      BitmapDescriptor.hueOrange,
    ), 
    ));

    }
    return markerSet;
  }
  static String findTodayWeekday(){
    //print (DateTime.now().weekday);
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
            icon: Icon(FontAwesomeIcons.searchMinus,color:Colors.orange),
            onPressed: () {
              zoomVal--;
             _minus( zoomVal);
            }),
    );
 }
 Widget _zoomplusfunction() {
   
    return Align(
      alignment: Alignment.topRight,
      child: IconButton(
            icon: Icon(FontAwesomeIcons.searchPlus,color:Colors.orange),
            onPressed: () {
              zoomVal++;
              _plus(zoomVal);
            }),
    );
 }

 Future<void> _minus(double zoomVal) async {
    final GoogleMapController controller = await _controller.future;
    controller.animateCamera(CameraUpdate.newCameraPosition(CameraPosition(target: LatLng(40.712776, -74.005974), zoom: zoomVal)));
  }
  Future<void> _plus(double zoomVal) async {
    final GoogleMapController controller = await _controller.future;
    controller.animateCamera(CameraUpdate.newCameraPosition(CameraPosition(target: LatLng(40.712776, -74.005974), zoom: zoomVal)));
  }

  @override
  Widget build(BuildContext context) {
     if(_testcenterList == null) {
      return SizedBox(
                child: CircularProgressIndicator(
                  backgroundColor: Colors.black,
                  strokeWidth: 10,
                ),
                height: 50.0,
                width: 50.0,
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
        // height:MediaQuery.of(context).size.height ,
        //padding: EdgeInsets.all(10),
        width: MediaQuery.of(context).size.width,
        child: GoogleMap(
          mapType: MapType.normal,
          initialCameraPosition: CameraPosition(
            target: LatLng(double.parse(_testcenterList.testCenters[0].geometry.lat),double.parse(_testcenterList.testCenters[0].geometry.lng)),//(40.712776, -74.005974),//LatLng(20.5937, 78.9629),
            //target:LatLng(latlng[0],latlng[1]),
            zoom: 12,
          ),
          onMapCreated: (GoogleMapController controller) {
            _controller.complete(controller);
            // _setMapStyle(controller);
          },
          zoomControlsEnabled: false,
         // markers: {gramercyMarker, bernardinMarker, blueMarker},
         markers: createMarkerSetFromJsonData(_testcenterList),
        ));
  }
Future<void> _gotoLocation(double lat,double long) async {
    final GoogleMapController controller = await _controller.future;
    controller.animateCamera(CameraUpdate.newCameraPosition(CameraPosition(target: LatLng(lat, long), zoom: 15,tilt: 50.0,
      bearing: 45.0,)));
  }
  Widget _boxes(String _image, TestCenters testCenter){//, lat,double long,String restaurantName) {
    return  GestureDetector(
        onTap: () {
          _gotoLocation(double.parse(testCenter.geometry.lat),double.parse(testCenter.geometry.lng));
        },
        child:Container(
              child: new FittedBox(
                child: Material(
                    color: Colors.red,
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
                          ),),
                          Container(
                            width: 180,
                          
                          child: Padding(
                            padding: const EdgeInsets.all(8.0),
                            child: testDetailsContainer(testCenter),
                          ),
                        ),

                      ],)
                ),
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
        //color: Colors.red,
        margin: EdgeInsets.symmetric(vertical: 20.0),
        height: 150.0,
        child: ListView(
          scrollDirection: Axis.horizontal,
          children: <Widget>[
            SizedBox(width: 10.0),
            Padding(
              padding: const EdgeInsets.all(8.0),
              child: _boxes(
                  "https://encrypted-tbn0.gstatic.com/images?q=tbn%3AANd9GcSfzJq71hUyLqclpH2IpxqT12kpcxrttRi58uOCerEDtNYO6g-l&usqp=CAU",
                  _testcenterList.testCenters[0]),//"Gramercy Tavern"),
            ),
            SizedBox(width: 10.0),
            Padding(
              padding: const EdgeInsets.all(8.0),
              child: _boxes(
                  "https://encrypted-tbn0.gstatic.com/images?q=tbn%3AANd9GcQTvJfY7ZTGe81aoFhn7hMoctab2w_D3LY9_sjREFNdKRk1TmNr&usqp=CAU",
                  _testcenterList.testCenters[1]),//"Gramercy Tavern"),//40.761421, -73.981667,"Le Bernardin"),
            ),
            SizedBox(width: 10.0),
            Padding(
              padding: const EdgeInsets.all(8.0),
              child: _boxes(
                  "https://encrypted-tbn0.gstatic.com/images?q=tbn%3AANd9GcSYEJ0O6Nsj4oH8WoRkeaypwUDLQxRrB8cNxgODJqzH886kM19D&usqp=CAU",
                  _testcenterList.testCenters[2]),//"Gramercy Tavern"),//40.732128, -73.999619,"Blue Hill"),
            ),
            SizedBox(width: 10.0),
            Padding(
              padding: const EdgeInsets.all(8.0),
              child: _boxes(
                  "https://encrypted-tbn0.gstatic.com/images?q=tbn%3AANd9GcQISdNTSW5DqKMncnOV73KMLcNv_BFGXqrS-m-ybGIXwPTrwHec&usqp=CAU",
                  _testcenterList.testCenters[3]),//"Gramercy Tavern"),//40.732128, -73.999619,"Blue Hill"),
            ),
            
          ],
        ),
      ),
    );
  }

  Widget testDetailsContainer(TestCenters testCenter) {
    return Column(
      mainAxisAlignment: MainAxisAlignment.spaceEvenly,
      children: <Widget>[
        Padding(
          padding: const EdgeInsets.only(left: 8.0),
          child: Container(
            
              child: Text(testCenter.name,
              textAlign: TextAlign.center,
              softWrap: true,
            style: TextStyle(
                color: Colors.black,//Color(0xff6200ee),
                fontSize: 20.0,                
                fontWeight: FontWeight.bold),
          )),
        ),
        SizedBox(height:5.0),
        Container(
           child: Text(
          "Open Timings: ${testCenter.hoursOpen[0].monday}",
          textAlign: TextAlign.center,
          style: TextStyle(
            color: Colors.black54,
            fontSize: 15.0,
            fontWeight: FontWeight.w700,
          ),
        )),
        SizedBox(height: 5.0),
        Container(
            child: FlatButton(
                child: Text(
                  "Testing details",
                  style: TextStyle(
                      color: Colors.black87,
                      fontSize: 18.0,
                      fontWeight: FontWeight.bold,
                      decoration: TextDecoration.underline,
                      ),
                ),
                onPressed: () {
                  showDialog(context: context,
                  builder: (BuildContext context) => _buildHourDetailsDialog(context,testCenter));})),
      
              
            ],
         
    );
  }
Widget getTextWidgets(List<String> strings)
  {
    List<Widget> list = new List<Widget>();
    for(var i = 0; i < strings.length; i++){
        list.add(new Text(strings[i]));
    }
    return new Column(children: list);
  }
Widget _buildHourDetailsDialog(BuildContext context, TestCenters testCenter)  {
  if(testCenter == null){
    return CircularProgressIndicator();
  }else
    return new AlertDialog(
      backgroundColor: Colors.black38,
      
      title:  Text('Testing Details ', textAlign :TextAlign.center,style: TextStyle(color: Colors.amber, fontWeight: FontWeight.bold), ),
      content: Container(
        height: 180,
        //child: getTextWidgets(testCenter.testingDetails),
         child: Text(
            (() {
             if(testCenter.testingDetails != null)
              return "${testCenter.testingDetails.toString()}";
              else
              return "";
            })(),
            textAlign: TextAlign.center,
            style: TextStyle(color: Colors.green,),
          ), ),
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
