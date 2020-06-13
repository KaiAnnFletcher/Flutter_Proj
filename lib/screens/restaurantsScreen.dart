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
import 'package:Flutter_Proj/model/restaurants.dart';

Future<String> _loadARestauranttAsset() async {
  return await rootBundle.loadString('api/restaurants.json');
}

Future<RestaurantList> loadRestaurant() async {
  await wait(5);
  String jsonString = await _loadARestauranttAsset();
  final jsonResponse = json.decode(jsonString);
  return new RestaurantList.fromJson(jsonResponse);
}

Future wait(int seconds) {
  return new Future.delayed(Duration(seconds: seconds), () => {});
}

class RestaurantWidget extends StatefulWidget {
  @override
  RestaurantState createState() => RestaurantState();
  /**const GoogleMapWidget({Key key, this.choice}) : super(key: key);

  final Choice choice; */
}

class RestaurantState extends State<RestaurantWidget> {
  Completer<GoogleMapController> _controller = Completer();
  Future<IndiaCasesRootNet> futureIndiaTotalCases;
  static RestaurantList _restaurantList;
  static Set<Marker> markerSet;
  bool _loaded = false;
  double zoomVal = 5.0;
  static var today;
  static var now = DateTime.parse("1969-07-20 20:18:04Z");  
  @override
  void initState() {
    super.initState();
    futureIndiaTotalCases =
        fetchIndiaTotalCasesRootNet(); //fetchIndiaTotalCases();
        loadRestaurant().then((s) => setState(() {
          _restaurantList = s;
          _loaded = true;
        }));
        if(_restaurantList == null) return ;
        markerSet = createMarkerSetFromJsonData(_restaurantList);
        today = findTodayWeekday();
  }
   static String findTodayWeekday(){
    print (DateTime.parse('1969-07-20 20:18:04Z').weekday);
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
  Set<Marker> createMarkerSetFromJsonData(RestaurantList list){
    Set<Marker> markerSet = new HashSet<Marker>();
    for (var i = 0; i < list.restaurants.length;i++ ){
      markerSet.add(Marker(
   markerId: MarkerId(_restaurantList.restaurants[i].name),
    position: LatLng(double.parse(_restaurantList.restaurants[i].geometry.lat), double.parse(_restaurantList.restaurants[i].geometry.lng)),
    infoWindow: InfoWindow(title: _restaurantList.restaurants[i].formattedAddress),
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
            target: LatLng(double.parse(_restaurantList.restaurants[0].geometry.lat),double.parse(_restaurantList.restaurants[0].geometry.lng)),//(40.712776, -74.005974),//LatLng(20.5937, 78.9629),
            //target:LatLng(latlng[0],latlng[1]),
            zoom: 12,
          ),
          onMapCreated: (GoogleMapController controller) {
            _controller.complete(controller);
            // _setMapStyle(controller);
          },
          //zoomControlsEnabled: false,
         // markers: {gramercyMarker, bernardinMarker, blueMarker},
         markers: createMarkerSetFromJsonData(_restaurantList),
        ));
  }
Future<void> _gotoLocation(double lat,double long) async {
    final GoogleMapController controller = await _controller.future;
    controller.animateCamera(CameraUpdate.newCameraPosition(CameraPosition(target: LatLng(lat, long), zoom: 15,tilt: 50.0,
      bearing: 45.0,)));
  }
  Widget _boxes(String _image, Restaurant restaurant){//, lat,double long,String restaurantName) {
    return  GestureDetector(
        onTap: () {
          _gotoLocation(double.parse(restaurant.geometry.lat),double.parse(restaurant.geometry.lng));
        },
        child:Container(
          //color: Colors.,
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
                           // color: Colors.green,
                            width: 200,
                          child: Padding(
                            padding: const EdgeInsets.all(8.0),
                            child: restaurantDetailsContainer(restaurant),
                          ),
                        ),

                      ],)
                ),
              ),
            ),
    );
  }

  Widget _buildRowContainer(
      String hour) {
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
              number: 0,
              title: hour,
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
        color:Colors.red,
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
                  _restaurantList.restaurants[0]),//"Gramercy Tavern"),
            ),
            SizedBox(width: 10.0),
            Padding(
              padding: const EdgeInsets.all(8.0),
              child: _boxes(
                  "https://lh5.googleusercontent.com/p/AF1QipMKRN-1zTYMUVPrH-CcKzfTo6Nai7wdL7D8PMkt=w340-h160-k-no",
                  _restaurantList.restaurants[1]),//"Gramercy Tavern"),//40.761421, -73.981667,"Le Bernardin"),
            ),
            SizedBox(width: 10.0),
            Padding(
              padding: const EdgeInsets.all(8.0),
              child: _boxes(
                  "https://images.unsplash.com/photo-1504940892017-d23b9053d5d4?ixlib=rb-1.2.1&ixid=eyJhcHBfaWQiOjEyMDd9&auto=format&fit=crop&w=500&q=60",
                  _restaurantList.restaurants[2]),//"Gramercy Tavern"),//40.732128, -73.999619,"Blue Hill"),
            ),
            SizedBox(width: 10.0),
            Padding(
              padding: const EdgeInsets.all(8.0),
              child: _boxes(
                  "https://images.unsplash.com/photo-1504940892017-d23b9053d5d4?ixlib=rb-1.2.1&ixid=eyJhcHBfaWQiOjEyMDd9&auto=format&fit=crop&w=500&q=60",
                  _restaurantList.restaurants[3]),//"Gramercy Tavern"),//40.732128, -73.999619,"Blue Hill"),
            ),
            
          ],
        ),
      ),
    );
  }

  Widget restaurantDetailsContainer(Restaurant restaurant) {
    return Column(
      mainAxisAlignment: MainAxisAlignment.spaceEvenly,
      children: <Widget>[
        Padding(
          padding: const EdgeInsets.only(left: 8.0),
          child: Container(
              width:180,
              child: Text(restaurant.name,
              textAlign: TextAlign.center,
            style: TextStyle(
                color: Colors.black,//Color(0xff6200ee),
                fontSize: 24.0,
                fontWeight: FontWeight.bold),
          )),
        ),
        SizedBox(height:5.0),
        Container(
          child:  Row(
            children: <Widget>[
              Text('Delivery:',
                 style: TextStyle(
                  color: Colors.black,
                  fontSize: 15.0,
                  fontWeight: FontWeight.bold,
                ),
                ),
              Text(restaurant.delivery,
              style: TextStyle(
                  color: Colors.orange,
                  fontSize: 14.0,
                  fontWeight: FontWeight.bold,
                ),
              ),  
              SizedBox(width: 5,),
              Text('TakeAway:',
              style: TextStyle(
                  color: Colors.black,
                  fontSize: 15.0,
                  fontWeight: FontWeight.bold,
                ),),
                 Text(restaurant.takeaway,
              style: TextStyle(
                  color: Colors.orange,
                  fontSize: 14.0,
                  fontWeight: FontWeight.bold,
                ),
              ), 
            ],
          )
        ),     
          SizedBox(height:5.0),
        Container(
                  child: Text(
                "Open Timings: ${restaurant.hoursOpen[0].monday}",
                style: TextStyle(
                  color: Colors.black54,
                  fontSize: 15.0,
                  fontWeight: FontWeight.w700,
                ),
              )),
              SizedBox(height:5.0),
        Container(
            child: Text(
          "Busy Hour",
          style: TextStyle(
              color: Colors.black,
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
                  builder: (BuildContext context) => _buildHourDetailsDialog(context,restaurant));})),
      
      ],
    );
  }
  Widget _buildHourDetailsDialog(BuildContext context, Restaurant restaurant)  {
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
                  return "${restaurant.busyHours[0].monday.toString()}";
                  break;
                case "Tuesday":
                  return "${restaurant.busyHours[0].tuesday.toString()}";
                  break;
                  case "Wednesday":
                  return "${restaurant.busyHours[0].wednesday.toString()}";
                  break;
                  case "Thursday":
                  return "${restaurant.busyHours[0].thursday.toString()}";
                  break;
                  case "Friday":
                  return "${restaurant.busyHours[0].friday.toString()}";
                  break;
                  case "Saturday":
                  return "${restaurant.busyHours[0].saturday.toString()}";
                  break;
                  case "Sunday":
                  return "${restaurant.busyHours[0].sunday.toString()}";
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
                return "${restaurant.quietHours[0].monday.sublist(0).toString()}";
              }
              if (DateTime.parse('1969-07-20 20:18:04Z').weekday == 2) {
                return "${restaurant.quietHours[0].tuesday.sublist(0).toString()}";
              }
              if (DateTime.parse('1969-07-20 20:18:04Z').weekday == 3) {
                return "${restaurant.quietHours[0].wednesday.sublist(0).toString()}";
              }
              if (DateTime.parse('1969-07-20 20:18:04Z').weekday == 4) {
                return "${restaurant.quietHours[0].thursday.sublist(0).toString()}";
              }
              if (DateTime.parse('1969-07-20 20:18:04Z').weekday == 5) {
                return "${restaurant.quietHours[0].friday.sublist(0).toString()}";
              }
              if (DateTime.parse('1969-07-20 20:18:04Z').weekday == 6) {
                return "${restaurant.quietHours[0].saturday.sublist(0).toString()}";
              }

              return "${restaurant.quietHours[0].sunday.sublist(0).toString()}";
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
