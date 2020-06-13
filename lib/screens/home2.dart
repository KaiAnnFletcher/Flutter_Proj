// Copyright 2017 The Chromium Authors. All rights reserved.
// Use of this source code is governed by a BSD-style license that can be
// found in the LICENSE file.

import 'package:Flutter_Proj/screens/restaurantsScreen.dart';
import 'package:Flutter_Proj/screens/churchesScreen.dart';
import 'package:Flutter_Proj/screens/storesScreen.dart';
import 'package:Flutter_Proj/screens/testCentersScreen.dart';
import 'package:flutter/material.dart';

import 'churchesScreen.dart';
import 'restaurantsScreen.dart';
import 'storesScreen.dart';
import 'testCentersScreen.dart';
//import 'package:google_maps_flutter/google_maps_flutter.dart';

class TabbedAppBarSample extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: DefaultTabController(
        length: choices.length,
        child: Scaffold(
          appBar: PreferredSize(
            preferredSize: Size.fromHeight(100.0),
            child: AppBar(
              leading: Image.asset('assets/images/coronaicon.jpg'),
              title: const Text('Safe Zone',
                  style: TextStyle(color: Colors.amber),
                  textAlign: TextAlign.center),
              //backgroundColor: Theme.of(context).canvasColor,
              // backgroundColor: Colors.red,
              centerTitle: true,
              bottom: TabBar(
                isScrollable: true,
                //indicatorSize: TabBarIndicatorSize.label,
                labelColor: Colors.black,

                tabs: choices.map((Choice choice) {
                  return Tab(
                    text: choice.title,
                    icon: Icon(choice.icon),
                  );
                }).toList(),
              ),
            ),
          ),
          body: TabBarView(
            children: choices.map((Choice choice) {
              return Padding(
                padding: const EdgeInsets.all(16.0),
                child: ChoiceCard(choice: choice),
              );
            }).toList(),
          ),
        ),
      ),
    );
  }
}

class Choice {
  const Choice({this.title, this.icon});

  final String title;
  final IconData icon;
}

const List<Choice> choices = const <Choice>[
  const Choice(title: 'Test center', icon: Icons.fitness_center),
  const Choice(title: 'Restaurent', icon: Icons.restaurant),
  const Choice(title: 'Store', icon: Icons.store),
  const Choice(title: 'Church', icon: Icons.home),
  //const Choice(title: 'TRAIN', icon: Icons.directions_railway),
  //const Choice(title: 'WALK', icon: Icons.directions_walk),
];

class ChoiceCard extends StatelessWidget {
  const ChoiceCard({Key key, this.choice}) : super(key: key);

  final Choice choice;

  @override
  Widget build(BuildContext context) {
    // final TextStyle textStyle = Theme.of(context).textTheme.title;
    
    if (choice.title.startsWith('Restaurent')) {
      return Card(
        color: Colors.white,
        child: Container(
          child: RestaurantWidget(),
          //Icon(choice.icon, size: 128.0, color: textStyle.color),
          //Text(choice.title, style: textStyle),
        ),
      );
    }
    if (choice.title.startsWith('Store')) {
      return Card(
        color: Colors.white,
        child: Container(
          child: StoreWidget(),
          //Icon(choice.icon, size: 128.0, color: textStyle.color),
          //Text(choice.title, style: textStyle),
        ),
      );
    }
    if (choice.title.startsWith('Church')) {
      return Card(
        color: Colors.white,
        child: Container(
          child: ChurchWidget(),
          //Icon(choice.icon, size: 128.0, color: textStyle.color),
          //Text(choice.title, style: textStyle),
        ),
      );
    }
    else
      return Card(
        color: Colors.white,
        child: Container(
          child: TestCenterWidget(),
          //Icon(choice.icon, size: 128.0, color: textStyle.color),
          //Text(choice.title, style: textStyle),
        ),
      );
    

  }
}
