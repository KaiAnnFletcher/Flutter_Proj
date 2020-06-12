import 'package:Flutter_Proj/constants/constant.dart';

//import '../constant.dart';
import 'package:flutter/material.dart';

class Counter extends StatelessWidget {
  final int number;
  final Color color;
  final String title;
  const Counter({
    Key key,
    this.number,
    this.color, 
    this.title,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Column(
      children: <Widget>[
        Container(
          padding: EdgeInsets.all(4), //6
          height: 20,//25,
          width: 25,//35,
          decoration: BoxDecoration(
            shape: BoxShape.circle,
            color: color.withOpacity(.26),
          ),
          child: Container(
           
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              color: color,
              border: Border.all(
                color: color,
                width: 2,
              ),
            ),
          ),
        ),
        SizedBox(height: 5),
        Text(
          "$number",
          style: TextStyle(
            fontSize: 15,//20,
            color: color,
          ),
        ),
        Text(title, 
        style:  kSubTextStyle),
      ],
    );
  }
}

