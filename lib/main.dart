import 'package:flutter/material.dart';
//import './screens/home.dart';
import './screens/home2.dart';


void main() => runApp(SafeZone());

class SafeZone extends StatelessWidget {
  // This widget is the root of your application.
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
       // Disable the debug Banner shown on top right
      
      title: 'Safe Zone',
      theme: ThemeData(
        // This is the theme of your application.
        //
        // Try running your application with "flutter run". You'll see the
        // application has a blue toolbar. Then, without quitting the app, try
        // changing the primarySwatch below to Colors.green and then invoke
        // "hot reload" (press "r" in the console where you ran "flutter run",
        // or simply save your changes to "hot reload" in a Flutter IDE).
        // Notice that the counter didn't reset back to zero; the application
        // is not restarted.
        primaryColor: Colors.red,
        accentColor: Colors.orange,
         textTheme: TextTheme(
          title: TextStyle(
            fontSize: 20.0,
            color: Colors.red,
            //decorationStyle: TextDecorationStyle.solid
          )
        ),
        canvasColor: Colors.amber

      ),
      /* routes: <String,WidgetBuilder>{
         '/Home': (BuildContext context) => new GoogleMapWidget(),
         '/News': (BuildContext context) => new News(),
         '/Store_Locator': (BuildContext context) => new StoreLocator(),
         '/Health': (BuildContext context) => new Health(),
         '/Learning': (BuildContext context) => new Learning(),
      }, */
     // home: new HomeWidget(), //home page displayed
      home :TabbedAppBarSample(),
    );
  }
}


