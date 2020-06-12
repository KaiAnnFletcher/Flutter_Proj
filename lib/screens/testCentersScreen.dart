import 'dart:async';

import 'package:Flutter_Proj/constants/constant.dart';
import 'package:Flutter_Proj/model/indiaCases_rootnet.dart';
import 'package:Flutter_Proj/widgets/counter.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';

class GoogleMapWidget extends StatefulWidget {
  @override
  GoogleMapState createState() => GoogleMapState();
  /**const GoogleMapWidget({Key key, this.choice}) : super(key: key);

  final Choice choice; */
}

class GoogleMapState extends State<GoogleMapWidget> {
  Completer<GoogleMapController> _controller = Completer();
  Future<IndiaCasesRootNet> futureIndiaTotalCases;
  double zoomVal = 5.0;
  @override
  void initState() {
    super.initState();
    futureIndiaTotalCases =
        fetchIndiaTotalCasesRootNet(); //fetchIndiaTotalCases();
  }

  void _setMapStyle(GoogleMapController controller) async {
    String style = await DefaultAssetBundle.of(context)
        .loadString('assets/map_style.json');
    controller.setMapStyle(style);
  }

   Widget _zoomminusfunction() {

    return Align(
      alignment: Alignment.topLeft,
      child: IconButton(
            icon: Icon(FontAwesomeIcons.searchMinus,color:Colors.amberAccent),
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
            icon: Icon(FontAwesomeIcons.searchPlus,color:Colors.amberAccent),
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
    return Stack(
      children: <Widget>[
        //_buildTopRowContainer(),
        /* Align(
          alignment: Alignment.topLeft,
          child: FloatingActionButton(
            clipBehavior: Clip.hardEdge,

            child: buildBottomRowContainer(context),
            //onPressed: buildBottomRowContainer(context),
          ),
        ), */
        // buildBottomRowContainer(context),
        _buildGoogleMap(context),
        _zoomminusfunction(),
          _zoomplusfunction(),
          _buildContainer(),

        //SizedBox(width: 10.0,height: 300.0,
        //child:  buildBottomRowContainer(context),),
        //_buildContainer(),
        //_buildRowContainer(),
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
            target: LatLng(40.712776, -74.005974),//LatLng(20.5937, 78.9629),
            //target:LatLng(latlng[0],latlng[1]),
            zoom: 12,
          ),
          onMapCreated: (GoogleMapController controller) {
            _controller.complete(controller);
            // _setMapStyle(controller);
          },
          //zoomControlsEnabled: false,
          markers: {gramercyMarker, bernardinMarker, blueMarker},
        ));
  }
Future<void> _gotoLocation(double lat,double long) async {
    final GoogleMapController controller = await _controller.future;
    controller.animateCamera(CameraUpdate.newCameraPosition(CameraPosition(target: LatLng(lat, long), zoom: 15,tilt: 50.0,
      bearing: 45.0,)));
  }
  Widget _boxes(String _image, double lat,double long,String restaurantName) {
    return  GestureDetector(
        onTap: () {
          _gotoLocation(lat,long);
        },
        child:Container(
              child: new FittedBox(
                child: Material(
                    color: Colors.white,
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
                          child: Padding(
                            padding: const EdgeInsets.all(8.0),
                            child: myDetailsContainer1(restaurantName),
                          ),
                        ),

                      ],)
                ),
              ),
            ),
    );
  }
  @override
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

  /* Widget _buildTopRowContainer() {
    return Align(
      alignment: Alignment.topCenter,
      child: SizedBox(
        height: 100.0,
        child: ListView(
          scrollDirection: Axis.horizontal,
          children: <Widget>[
            // buildBarItem(CupertinoIcons.news,_newsFunction),

            buildBarItem(MyFlutterApp.newspaper, _newsFunction, 'News'),
            buildBarItem(
                MyFlutterApp.online_education, _learningFunction, 'e-Learning'),
            //buildBarItem(CupertinoIcons.book_solid,_learningFunction),
            //buildBarItem(MdiIcons.heart,_fitnessFunction),
            buildBarItem(Icons.store, _storeFunction, 'Store Locator'),
            buildBarItem(
                MyFlutterApp.diet_1_, _fitnessFunction, 'Healthy Meals'),
          ],
        ),
      ),
    );
  } */

  Widget buildBarItem(
      IconData iconArgument, Function functionName, String name) {
    return Container(
        width: 80.0,
        margin: EdgeInsets.all(4.0),
        color: Colors.white,
        child: Column(children: [
          IconButton(icon: Icon(iconArgument), onPressed: functionName),
          Text(
            name,
            style: TextStyle(
              fontSize: 10,
              color: Colors.black45,
            ),
          ),
        ])
        //child: Icon(icon),

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
                  "https://lh5.googleusercontent.com/p/AF1QipO3VPL9m-b355xWeg4MXmOQTauFAEkavSluTtJU=w225-h160-k-no",
                  40.738380, -73.988426,"Gramercy Tavern"),
            ),
            SizedBox(width: 10.0),
            Padding(
              padding: const EdgeInsets.all(8.0),
              child: _boxes(
                  "https://lh5.googleusercontent.com/p/AF1QipMKRN-1zTYMUVPrH-CcKzfTo6Nai7wdL7D8PMkt=w340-h160-k-no",
                  40.761421, -73.981667,"Le Bernardin"),
            ),
            SizedBox(width: 10.0),
            Padding(
              padding: const EdgeInsets.all(8.0),
              child: _boxes(
                  "https://images.unsplash.com/photo-1504940892017-d23b9053d5d4?ixlib=rb-1.2.1&ixid=eyJhcHBfaWQiOjEyMDd9&auto=format&fit=crop&w=500&q=60",
                  40.732128, -73.999619,"Blue Hill"),
            ),
          ],
        ),
      ),
    );
  }

  Widget myDetailsContainer1(String restaurantName) {
    return Column(
      mainAxisAlignment: MainAxisAlignment.spaceEvenly,
      children: <Widget>[
        Padding(
          padding: const EdgeInsets.only(left: 8.0),
          child: Container(
              child: Text(restaurantName,
            style: TextStyle(
                color: Colors.red,//Color(0xff6200ee),
                fontSize: 24.0,
                fontWeight: FontWeight.bold),
          )),
        ),
        SizedBox(height:5.0),
        Container(
              child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
            children: <Widget>[
              Container(
                  child: Text(
                "4.1",
                style: TextStyle(
                  color: Colors.black54,
                  fontSize: 18.0,
                ),
              )),
              Container(
                child: Icon(
                  FontAwesomeIcons.solidStar,
                  color: Colors.amber,
                  size: 15.0,
                ),
              ),
              Container(
                child: Icon(
                  FontAwesomeIcons.solidStar,
                  color: Colors.amber,
                  size: 15.0,
                ),
              ),
              Container(
                child: Icon(
                  FontAwesomeIcons.solidStar,
                  color: Colors.amber,
                  size: 15.0,
                ),
              ),
              Container(
                child: Icon(
                  FontAwesomeIcons.solidStar,
                  color: Colors.amber,
                  size: 15.0,
                ),
              ),
              Container(
                child: Icon(
                  FontAwesomeIcons.solidStarHalf,
                  color: Colors.amber,
                  size: 15.0,
                ),
              ),
               Container(
                  child: Text(
                "(946)",
                style: TextStyle(
                  color: Colors.black54,
                  fontSize: 18.0,
                ),
              )),
            ],
          )),
         /**  SizedBox(height:5.0),
        Container(
                  child: Text(
                "American \u00B7 \u0024\u0024 \u00B7 1.6 mi",
                style: TextStyle(
                  color: Colors.black54,
                  fontSize: 18.0,
                ),
              )),
              SizedBox(height:5.0),
        Container(
            child: Text(
          "Closed \u00B7 Opens 17:00 Thu",
          style: TextStyle(
              color: Colors.black54,
              fontSize: 18.0,
              fontWeight: FontWeight.bold),
        )),
        **/
      ],
    );
  }


  Marker gramercyMarker = Marker(
    markerId: MarkerId('gramercy'),
    position: LatLng(40.738380, -73.988426),
    infoWindow: InfoWindow(title: 'Total:100, deaths:20, recovered:80'),
    icon: BitmapDescriptor.defaultMarkerWithHue(
      BitmapDescriptor.hueYellow,
    ),
  );

  Marker bernardinMarker = Marker(
    markerId: MarkerId('bernardin'),
    position: LatLng(40.761421, -73.981667),
    infoWindow: InfoWindow(title: 'Total:100, deaths:20, recovered:80'),
    icon: BitmapDescriptor.defaultMarkerWithHue(
      BitmapDescriptor.hueYellow,
    ), 
  );
  Marker blueMarker = Marker(
    markerId: MarkerId('bluehill'),
    position: LatLng(40.732128, -73.999619),
    infoWindow: InfoWindow(
        title: 'Total:100, deaths:20, recovered:80', snippet: 'Covid cases'),
    icon: BitmapDescriptor.defaultMarkerWithHue(
      BitmapDescriptor.hueYellow,
    ), 
  );
}
