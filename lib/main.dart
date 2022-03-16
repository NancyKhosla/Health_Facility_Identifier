import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:health_facility_identifier/home.dart';
import 'package:health_facility_identifier/routes.dart';
import 'package:searchable_dropdown/searchable_dropdown.dart';

void main() => runApp(MyApp());

class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'Health Facility Identifier',
      routes: routes,
      // home: Homepage(title: 'Health Facility Identifier'),
    );
  }
}

/*
class Homenew extends StatefulWidget {
  Homenew({Key key, this.title}) : super(key: key);
  final String title;

  @override
  _MyHomePageState createState() => _MyHomePageState();
}

class _MyHomePageState extends State<Homenew> {
  List<String> abc = ['A', 'B', 'C', 'D'];
  String selectedValue;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        backgroundColor: Colors.white,
        body: Stack(children: <Widget>[
          Column(
            mainAxisAlignment: MainAxisAlignment.start,
            crossAxisAlignment: CrossAxisAlignment.center,
            children: <Widget>[

              SearchableDropdown(
                hint: Text('Please choose State name'),
                underline: SizedBox(),
                items: abc.map((item) {
                  return DropdownMenuItem<String>(
                    value: item.toString(),
                    child: Text(
                      item,
                      style: const TextStyle(
                          fontFamily: 'Poppins', fontSize: 13),
                    ),
                  );
                }).toList(),
                isExpanded: true,
                value: selectedValue,
                isCaseSensitiveSearch: false,
                onChanged: (value) async {
                  setState(() {
                    selectedValue = value;


                  });
                },
              ),
              RaisedButton(onPressed: (){
                print(selectedValue);
                selectedValue= null;
                print(selectedValue);
                setState(() {
                  selectedValue = null;
                });

              }, child: Text("press"),)






            ],
          ),
        ]));
  }

}*/
