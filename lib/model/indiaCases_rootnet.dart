//step -1 import the http package post adding it dependency in pubspec.yml
import 'dart:convert';

//import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;

// Step-2 Create a method and add a network Rest API call .
/**Future<http.Response> fetchIndiaTotalCases() {
  return http.get('https://covid-19india-api.herokuapp.com/v2.0/country_data');
            "total":91375,
            "recovered":34620,
            "deaths":2896,
            "active":53853
      
}
}**/

// Step-3 Create a model to convert the Json object into this modela and then use this model to build the widgets and populate data in them.
class Unofficalsummary {
  final int recovered;
  final int total;
  final int deaths;
  final int active;

  Unofficalsummary({this.recovered, this.active, this.deaths, this.total});

  factory Unofficalsummary.fromJson(Map<String, dynamic> json) {
    return Unofficalsummary(
      recovered: json['recovered'],
      total: json['total'],
      deaths: json['deaths'],
      active: json['active'],
    );
  }
}

class IndiaCasesRootNet {
  final bool status;
  final CasesData data;
  IndiaCasesRootNet({this.status, this.data});
  factory IndiaCasesRootNet.fromJson(Map<String, dynamic> json) {
    return IndiaCasesRootNet(
      status: json['status'],
      data: CasesData.fromJson(json['data']),
    );
  }
}

class CasesData {
  final Summary summary;
  final List<Unofficalsummary> unOffSummary;
  final List<Regional> regional;
  CasesData({this.summary, this.unOffSummary, this.regional});

  factory CasesData.fromJson(Map<String, dynamic> parsedJson) {
    List<Regional> regional = List<Regional>.from(
        parsedJson['regional'].map((i) => Regional.fromJson(i)));
    //regional = parsedJson['regional'].map((i)=>Regional.fromJson(i)).toList();

    List<Unofficalsummary> unOffSummary = List<Unofficalsummary>.from(
        parsedJson['unofficial-summary']
            .map((i) => Unofficalsummary.fromJson(i)));

    return CasesData(
        unOffSummary: unOffSummary,
        regional: regional,
        summary: Summary.fromJson(parsedJson['summary']));
  }
}

class Regional {
  final int discharged;
  final String loc;
  final int deaths;

  Regional({this.discharged, this.loc, this.deaths});

  factory Regional.fromJson(Map<String, dynamic> json) {
    return Regional(
      discharged: json['discharged'],
      loc: json['loc'],
      deaths: json['deaths'],
    );
  }
}

class Summary {
  final int total;
  final int deaths;
  Summary({this.total, this.deaths});
  factory Summary.fromJson(Map<String, dynamic> json) {
    return Summary(
      total: json['total'],
      deaths: json['deaths'],
    );
  }
}

//Step- 4 Add login in method created in step -2 to convert http response  into the model object as created above.
// import dart convert package.
Future<IndiaCasesRootNet> fetchIndiaTotalCasesRootNet() async {
  final response =
      await http.get('https://api.rootnet.in/covid19-in/stats/latest');
  //print(json.decode(response.body).cast<Map<String,dynamic>>());
  if (response.statusCode == 200) {
    // If the server did return a 200 OK response,
    // then parse the JSON.
    return IndiaCasesRootNet.fromJson(json.decode(response.body));
  } else {
    // If the server did not return a 200 OK response,
    // then throw an exception.
    throw Exception('Failed to load India toal cases');
  }
}
