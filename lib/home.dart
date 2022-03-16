import 'dart:async';
import 'dart:convert';
import 'package:android_intent/android_intent.dart';
import 'package:connectivity/connectivity.dart';
import 'package:health_facility_identifier/MapScreen.dart';
import 'package:flutter/material.dart';
import 'package:geolocator/geolocator.dart';
import 'package:health_facility_identifier/url.dart';
import 'package:http/http.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:progress_hud/progress_hud.dart';
import 'package:searchable_dropdown/searchable_dropdown.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:url_launcher/url_launcher.dart';
import 'basicAuth.dart';

class Homepage extends StatefulWidget {
  Homepage({Key key, this.title}) : super(key: key);
  final String title;

  @override
  _MyHomePageState createState() => _MyHomePageState();
}

class _MyHomePageState extends State<Homepage> {
  String selectedValue;
  String selectedfacility;
  String selectedStore;
  String holder;
  String stateId;
  String facilityId;
  String storeid;
  String distName = "";
  String distid ="";
  String location = "";
  String storename = "";
  String storelevel = "";
  String owneraddress = "";
  String statefacname = "";
  String storeninno = "";
  String storeemail = "";
  var addressLat;
  var addressLng;
  List<dynamic> userid;
  String username = "";

  // String message = "Please select the drug name";
  Position _location = Position(latitude: 0.0, longitude: 0.0);
  List<dynamic> stateList = [];
  List<dynamic> facilityList = [];
  List<dynamic> storeList = [];
  ProgressHUD progressHUD;
  bool visibleStore = false;

  Future<List<dynamic>> _getStateList() async {
    var connectivityResult = await (Connectivity().checkConnectivity());
    if (connectivityResult == ConnectivityResult.mobile ||
        connectivityResult == ConnectivityResult.wifi) {
      progressHUD.state.show();

      Response response = await ioClient.post(state_List, headers: headers);
      if (response.statusCode == 200) {
        progressHUD.state.dismiss();
        Map<String, dynamic> list = json.decode(response.body);
        setState(() {
          stateList = list["dataValue"];
        });
        print("stateList.........." + stateList.toString());
      } else {
        progressHUD.state.dismiss();
        throw Exception('Failed to load data');
      }
    } else {
      return showDialog(
          context: context,
          builder: (BuildContext context) {
            return const AlertDialog(
              backgroundColor: Color(0xffffffff),
              title: Text("Please Check your Internet Connection",
                  textAlign: TextAlign.center,
                  style: TextStyle(fontSize: 16, color: Color(0xff000000))),
            );
          });
    }
  }

  Future<List<dynamic>> _getFacilityList() async {
    var connectivityResult = await (Connectivity().checkConnectivity());
    if (connectivityResult == ConnectivityResult.mobile ||
        connectivityResult == ConnectivityResult.wifi) {
      selectedfacility = null;
      selectedStore = null;
      progressHUD.state.show();

      final formData = jsonEncode({
        "primaryKeys": [stateId]
      });

      Response response =
      await ioClient.post(Facility_List, headers: headers, body: formData);
      if (response.statusCode == 200) {
        progressHUD.state.dismiss();
        Map<String, dynamic> list = json.decode(response.body);
        setState(() {
          facilityList = list["dataValue"];
        });
        print("facility list .........." + facilityList.toString());
      } else {
        progressHUD.state.dismiss();
        throw Exception('Failed to load data');
      }
    } else {
      return showDialog(
          context: context,
          builder: (BuildContext context) {
            return const AlertDialog(
              backgroundColor: Color(0xffffffff),
              title: Text("Please Check your Internet Connection",
                  textAlign: TextAlign.center,
                  style: TextStyle(fontSize: 16, color: Color(0xff000000))),
            );
          });
    }
  }

  Future<List<dynamic>> _getStoreList() async {
    var connectivityResult = await (Connectivity().checkConnectivity());
    if (connectivityResult == ConnectivityResult.mobile ||
        connectivityResult == ConnectivityResult.wifi) {
      progressHUD.state.show();

      final formData = jsonEncode({
        "primaryKeys": [stateId, facilityId]
      });

      Response response =
      await ioClient.post(store_List, headers: headers, body: formData);
      if (response.statusCode == 200) {
        progressHUD.state.dismiss();
        Map<String, dynamic> list = json.decode(response.body);
        setState(() {
          storeList = list["dataValue"];
        });

        print("storeList .........." + storeList.toString());
      } else {
        progressHUD.state.dismiss();
        throw Exception('Failed to load data');
      }
    } else {
      return showDialog(
          context: context,
          builder: (BuildContext context) {
            return const AlertDialog(
              backgroundColor: Color(0xffffffff),
              title: Text("Please Check your Internet Connection",
                  textAlign: TextAlign.center,
                  style: TextStyle(fontSize: 16, color: Color(0xff000000))),
            );
          });
    }
  }

  Future _saveCordinates() async {
    var connectivityResult = await (Connectivity().checkConnectivity());
    if (connectivityResult == ConnectivityResult.mobile ||
        connectivityResult == ConnectivityResult.wifi) {
      progressHUD.state.show();


      print("lati.." + _location.latitude.toString());
      print("longi.." + _location.longitude.toString());
      var requestData = {
        "stateid": "$stateId".trim(),
        "storeid": "$storeid".trim(),

        "storename": "$storename".trim(),
        "storelevel": "$storelevel".trim(),
        "distid": "$distid".trim(),
        "districtname": "$distName".trim(),
        "location": "$location".trim(),
        "owneraddress": "$owneraddress".trim(),
        "dwhtypeid": "$facilityId".trim(),
        "statefacname": "$statefacname".trim(),
        "storeninno": "$storeninno".trim(),
        "latitude": "${_location.latitude}".trim(),
        "longitude": "${_location.longitude}".trim(),
        "storeemail": "$storeemail".trim()
      };

      String paramnetsString = getPrettyJSONString(requestData);
      print("paramnetsString.." + paramnetsString);

      final formData = jsonEncode({
        "hospitalCode": "998",
        "seatId": '20000001',
        "modeFordata": "ADD",
        "moduleName": "Central Dashboard",
        "processName": "State Store Mst Geo Coordinate",
        "inputDataJson": paramnetsString
      });
      Response response = await ioClient.post(save_cordinates,
          headers: headers, body: formData);
      print("url.." + save_cordinates);
      print("header.." + headers.toString());
      print("formdata..." + formData);
      print(" response .. " + response.body.toString());
      print("responsecode..." + response.statusCode.toString());
      Map<String, dynamic> list = json.decode(response.body);
      print("......" + list["msg"]);
      // print(list["msg"] == "SUCCESS: Qr Affix successfully !");
      String message = list["msg"];

      if (response.statusCode == 200 && message.startsWith("SUCCESS")) {
        progressHUD.state.dismiss();
        return showDialog(
            barrierDismissible: false,
            context: context,
            builder: (BuildContext context) {
              return WillPopScope(
                child: AlertDialog(
                  backgroundColor: Color(0xffffffff),
                  title: Text(message,
                      textAlign: TextAlign.center,
                      style: TextStyle(fontSize: 16, color: Color(0xff000000))),
                  actions: [
                    new FlatButton(
                        child: new Text("OK"),
                        onPressed: () {
                          setState(() {
                            selectedStore=null;
                            selectedfacility=null;
                            selectedValue=null;
                            visibleStore=false;
                          });

                          Navigator.pop(context);
                        }),
                  ],
                ),
                onWillPop: () async {
                  return false;
                },
              );
            });
      } else {
        progressHUD.state.dismiss();
        showDialog(
            barrierDismissible: false,
            context: context,
            builder: (BuildContext context) {
              return WillPopScope(
                child: AlertDialog(
                  backgroundColor: Color(0xffffffff),
                  title: Text(message,
                      textAlign: TextAlign.center,
                      style: TextStyle(fontSize: 16, color: Color(0xff000000))),
                  actions: <Widget>[
                    new FlatButton(
                      child: new Text("Close"),
                      onPressed: () {
                        Navigator.pop(context);
                        // Navigator.pop(context);
                      },
                    ),
                  ],
                ),
                onWillPop: () async {
                  return false;
                },
              );
            });
      }
    } else {
      return showDialog(
          context: context,
          builder: (BuildContext context) {
            return AlertDialog(
              backgroundColor: Color(0xffffffff),
              title: Text("Please Check your Internet Connection",
                  textAlign: TextAlign.center,
                  style: TextStyle(fontSize: 16, color: Color(0xff000000))),
            );
          });
    }
  }

  String getPrettyJSONString(jsonObject) {
    var encoder = new JsonEncoder.withIndent("     ");
    return encoder.convert(jsonObject);
  }

  _launchURL(String url) async {
    // var url = 'mailto:example@gmail.com';
    if (await canLaunch(url)) {
      await launch(url);
    } else {
      throw 'Could not launch $url';
    }
  }

  _launchCaller(String url) async {
    if (await canLaunch(url)) {
      await launch(url);
    } else {
      throw 'Could not launch $url';
    }
  }

  @override
  void initState() {
    progressHUD = ProgressHUD(
      backgroundColor: Colors.black12,
      color: Colors.white,
      containerColor: Color(0xFF2196F3),
      borderRadius: 5.0,
      loading: true,
      text: 'Loading...',
    );
    getCredentials();
    getLocation();
    _getStateList();
    super.initState();
  }

  Future<void> getCredentials() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    username = prefs.getString("username") ?? " ";
  }

  Future<void> getLocation() async {
    try {
      var serviceEnabled = await Geolocator().isLocationServiceEnabled();
      print("1..." + serviceEnabled.toString());
      if (serviceEnabled) {
        var geolocationStatus =
        await Geolocator().checkGeolocationPermissionStatus();
        print("2...." + geolocationStatus.toString());
        if (geolocationStatus == GeolocationStatus.granted ||
            geolocationStatus == GeolocationStatus.unknown) {
          _location = await Geolocator()
              .getCurrentPosition(desiredAccuracy: LocationAccuracy.high);
          print("3....." + _location.toString());
          return;
        }
      }
    } catch (e) {
      print(e);
    }
  }

  Widget _buildTitle(BuildContext context) {
    /*var horizontalTitleAlignment =
          Platform.isIOS ? CrossAxisAlignment.center : CrossAxisAlignment.start;*/
    return InkWell(
      // onTap: () => scaffoldKey.currentState.openDrawer(),
      child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 1.0),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            crossAxisAlignment: CrossAxisAlignment.center,
            children: <Widget>[
              Expanded(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: <Widget>[
                      const Text(
                        'Health Facility Identifier',
                        style: TextStyle(
                            color: Colors.white,
                            fontSize: 20,
                            fontWeight: FontWeight.w600,
                            fontStyle: FontStyle.normal,
                            fontFamily: 'Raleway'),
                      ),
                      Text(
                        'Welcome,' + username,
                        style: const TextStyle(
                            color: Colors.white,
                            fontSize: 15,
                            fontWeight: FontWeight.w600,
                            fontStyle: FontStyle.normal,
                            fontFamily: 'Raleway'),
                      ),
                    ],
                  )),
            ],
          )),
    );
  }

  Widget _buildBar(BuildContext context) {
    return AppBar(
      backgroundColor: Colors.blue,
      iconTheme: new IconThemeData(color: Colors.white),
      title: _buildTitle(context),
      actions: <Widget>[
        IconButton(
          icon: Icon(Icons.logout),
          color: Colors.white,
          // The "-" icon
          onPressed: () async {
            showDialog(
                barrierDismissible: false,
                context: context,
                builder: (BuildContext context) {
                  return WillPopScope(
                    child: AlertDialog(
                      backgroundColor: Color(0xffffffff),
                      title: const Text("Are you sure you want to logout ?",
                          textAlign: TextAlign.center,
                          style: TextStyle(
                              fontSize: 16, color: Color(0xff000000))),
                      actions: <Widget>[
                        FlatButton(
                          child: new Text("Cancel"),
                          onPressed: () {
                            Navigator.pop(context);
                          },
                        ),
                        FlatButton(
                          child: new Text("Logout"),
                          onPressed: () async {
                            SharedPreferences prefs =
                            await SharedPreferences.getInstance();
                            prefs.remove("username");
                            prefs.remove("password");
                            Navigator.of(context)
                                .popUntil((route) => route.isFirst);
                            Navigator.pushReplacementNamed(context, "/login");
                          },
                        ),
                      ],
                    ),
                    onWillPop: () async {
                      return false;
                    },
                  );
                });
          }, // The `_decrementCounter` function
        ),
      ],
    );
  }

  final StateNameLabel = const Text(
    'State Name:',
    style: TextStyle(color: Colors.black, fontWeight: FontWeight.normal),
  );

  final FacilityTypeLabel = const Text(
    'Facility Type:',
    style: TextStyle(color: Colors.black, fontWeight: FontWeight.normal),
  );

  final StoreNameLabel = const Text(
    'Store Name:',
    style: TextStyle(color: Colors.black, fontWeight: FontWeight.normal),
  );

  Widget build(BuildContext context) {
    return Scaffold(
        backgroundColor: Colors.white,
        appBar: _buildBar(context),
        body: Stack(children: <Widget>[
          Padding(
            padding: new EdgeInsets.all(10),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.start,
              crossAxisAlignment: CrossAxisAlignment.center,
              children: <Widget>[
                Padding(padding: new EdgeInsets.all(10)),
                Container(
                  alignment: Alignment.centerLeft,
                  padding: EdgeInsets.all(10),
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.start,
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: <Widget>[
                      StateNameLabel,
                      Padding(padding: new EdgeInsets.symmetric(vertical: 5)),
                      Container(
                        padding: EdgeInsets.symmetric(horizontal: 10.0),
                        height: 30,
                        decoration: BoxDecoration(
                          borderRadius: BorderRadius.circular(5.0),
                          border: Border.all(
                              color: Colors.black,
                              style: BorderStyle.solid,
                              width: 0.50),
                        ),
                        child: SearchableDropdown(
                          hint: Text('Please choose State name'),
                          underline: SizedBox(),
                          items: stateList.map((item) {
                            return DropdownMenuItem<String>(
                              value: item.toString(),
                              child: Text(
                                item[1],
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
                              String updatedString = selectedValue.substring(
                                  1, selectedValue.length - 1);
                              List<String> result = updatedString.split(',');
                              stateId = result[0];
                              print("stateId... " + stateId);

                              visibleStore = false;
                              _getFacilityList();
                            });
                          },
                        ),
                      ),
                    ],
                  ),
                ),
                Container(
                  alignment: Alignment.centerLeft,
                  padding: EdgeInsets.all(10),
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.start,
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: <Widget>[
                      FacilityTypeLabel,
                      Padding(padding: new EdgeInsets.symmetric(vertical: 5)),
                      Container(
                        padding: EdgeInsets.symmetric(horizontal: 10.0),
                        height: 30,
                        decoration: BoxDecoration(
                          borderRadius: BorderRadius.circular(5.0),
                          border: Border.all(
                              color: Colors.black,
                              style: BorderStyle.solid,
                              width: 0.50),
                        ),
                        child: SearchableDropdown(
                          hint: Text('Please choose Facility Type'),
                          underline: SizedBox(),
                          items: facilityList.map((item) {
                            return DropdownMenuItem<String>(
                              value: item.toString(),
                              child: Text(
                                item[1],
                                style: const TextStyle(
                                    fontFamily: 'Poppins', fontSize: 13),
                              ),
                            );
                          }).toList(),
                          isExpanded: true,
                          value: selectedfacility,
                          isCaseSensitiveSearch: false,
                          onChanged: (value) async {
                            setState(() {
                              selectedfacility = value;
                              String updatedString = selectedfacility.substring(
                                  1, selectedfacility.length - 1);
                              List<String> result = updatedString.split(',');
                              facilityId = result[0];
                              print("facilityId... " + facilityId);
                              selectedStore = null;
                              visibleStore = false;
                              _getStoreList();
                            });
                          },
                        ),
                      ),
                    ],
                  ),
                ),
                Container(
                  alignment: Alignment.centerLeft,
                  padding: EdgeInsets.all(10),
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.start,
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: <Widget>[
                      StoreNameLabel,
                      Padding(padding: new EdgeInsets.symmetric(vertical: 5)),
                      Container(
                        padding: EdgeInsets.symmetric(horizontal: 10.0),
                        height: 30,
                        decoration: BoxDecoration(
                          borderRadius: BorderRadius.circular(5.0),
                          border: Border.all(
                              color: Colors.black,
                              style: BorderStyle.solid,
                              width: 0.50),
                        ),
                        child: SearchableDropdown(
                          hint: Text('Please choose Store Name'),
                          underline: SizedBox(),
                          items: storeList.map((item) {
                            return DropdownMenuItem<String>(
                              value: item.toString(),
                              child: Text(
                                item[2],
                                style: const TextStyle(
                                    fontFamily: 'Poppins', fontSize: 13),
                              ),
                            );
                          }).toList(),
                          isExpanded: true,
                          value: selectedStore,
                          isCaseSensitiveSearch: false,
                          onChanged: (value) async {
                            setState(() {
                              selectedStore = value;
                              if (selectedStore.length > 0) {
                                visibleStore = true;
                                String updatedString = selectedStore.substring(
                                    1, selectedStore.length - 1);
                                List<String> result = updatedString.split(',');
                                storeid = result[1];
                                storename = result[2];
                                storelevel = result[3];
                                owneraddress = result[7];
                                statefacname = result[9];
                                storeninno = result[10];
                                storeemail = result[13];
                                distName = result[5];
                                location = result[6];
                                distid=result[4];
                                // String abc = result[6].trim();
                                // List<String> addresslatLng = abc.split(' ');
                                // print("addresslatLng..." +addresslatLng.toString());
                                // addressLat = addresslatLng[0];
                                // addressLng= addresslatLng[1];
                                print("0.." +
                                    result[0] +
                                    " \n" +
                                    "1.." +
                                    result[1] +
                                    " \n" +
                                    "2.." +
                                    result[2] +
                                    " \n" +
                                    "3.." +
                                    result[3] +
                                    " \n" +
                                    "4.." +
                                    result[4] +
                                    " \n" +
                                    "5.." +
                                    result[5]);
                                print("6.." +
                                    result[6] +
                                    " \n" +
                                    "7.." +
                                    result[7] +
                                    " \n" +
                                    "8.." +
                                    result[8] +
                                    " \n" +
                                    "9.." +
                                    result[9] +
                                    " \n" +
                                    "10.." +
                                    result[10] +
                                    " \n" +
                                    "11.." +
                                    result[11]);
                                print("12.." +
                                    result[12] +
                                    " \n" +
                                    "13.." +
                                    result[13]);

                                print("store id... " + storeid);
                                print("distName... " + distName);
                                print("email... " + storeemail);
                                print("address... " +
                                    owneraddress +
                                    " .... location " +
                                    location);
                              }
                            });
                          },
                        ),
                      ),
                    ],
                  ),
                ),
                Visibility(
                    visible: visibleStore,
                    child: Container(
                        margin: const EdgeInsets.only(
                            left: 0, right: 0, top: 20, bottom: 10),
                        padding: const EdgeInsets.all(20.0),
                        decoration: BoxDecoration(
                            borderRadius:
                            BorderRadius.all(new Radius.circular(10.0)),
                            boxShadow: const [
                              BoxShadow(
                                  color: Color(0xffd2c8c8),
                                  blurRadius: 2.0,
                                  spreadRadius: 1.0,
                                  offset: Offset(1.0, 3.0))
                            ],
                            color: Color(0xffeeeeee)),
                        child: Column(
                            mainAxisAlignment: MainAxisAlignment.start,
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: <Widget>[
                              Container(
                                  margin: EdgeInsets.only(top: 6, bottom: 6),
                                  child: Row(
                                    mainAxisAlignment: MainAxisAlignment.start,
                                    children: <Widget>[
                                      Text("Dist Name:  ",
                                          style: new TextStyle(
                                            color: Colors.black,
                                            fontWeight: FontWeight.bold,
                                          )),
                                      Expanded(
                                          child: Text(distName,
                                              style: TextStyle(
                                                  fontFamily: 'Poppins',
                                                  fontSize: 15,
                                                  fontWeight:
                                                  FontWeight.w500))),
                                    ],
                                  )),
                              Container(
                                  margin: EdgeInsets.only(top: 6, bottom: 6),
                                  child: Row(
                                    mainAxisAlignment: MainAxisAlignment.start,
                                    children: <Widget>[
                                      Text("Address:  ",
                                          style: new TextStyle(
                                            color: Colors.black,
                                            fontWeight: FontWeight.bold,
                                          )),
                                      Expanded(
                                          child: Text(owneraddress,
                                              style: const TextStyle(
                                                  fontFamily: 'Poppins',
                                                  fontSize: 15,
                                                  fontWeight:
                                                  FontWeight.w500))),
                                    ],
                                  )),
                              GestureDetector(
                                  onTap: () {
                                    // print("destlat.." +addressLat);
                                    // print("destlong.." +addressLng);
                                    // navigationToMap(
                                    //     addressLat, addressLng
                                    // );
                                  },
                                  child: Container(
                                      margin:
                                      EdgeInsets.only(top: 6, bottom: 6),
                                      child: Row(
                                        mainAxisAlignment:
                                        MainAxisAlignment.start,
                                        children: <Widget>[
                                          // Icon(Icons.location_on),
                                          Text("Location: ",
                                              style: new TextStyle(
                                                color: Colors.black,
                                                fontWeight: FontWeight.bold,
                                              )),
                                          Expanded(
                                              child: Text(location,
                                                  style: const TextStyle(
                                                      fontFamily: 'Poppins',
                                                      fontSize: 15,
                                                      fontWeight:
                                                      FontWeight.w500))),
                                        ],
                                      ))),
                              InkWell(
                                  onTap: () {
                                    _launchURL(
                                        'mailto:+${storeemail.toString()}');
                                  },
                                  child: Container(
                                      margin:
                                      EdgeInsets.only(top: 6, bottom: 6),
                                      child: Row(
                                          mainAxisAlignment:
                                          MainAxisAlignment.start,
                                          children: <Widget>[
                                            Icon(Icons.mail, size: 18),
                                            Expanded(
                                                child: Text(storeemail,
                                                    style: const TextStyle(
                                                        fontFamily: 'Poppins',
                                                        fontSize: 15,
                                                        fontWeight:
                                                        FontWeight.w500,
                                                        decoration:
                                                        TextDecoration
                                                            .underline,
                                                        color: Color(
                                                            0xff4b2b59)))),
                                          ]))),
                            ]))),
                // SizedBox(height: 15),
                // _saveButton(),
                // SizedBox(height: 10),

                new SizedBox(
                    width: double.infinity,
                    child: RaisedButton(

                        onPressed: selectedValue != null &&
                            selectedStore != null &&
                            selectedfacility != null?(){ //if buttonenabled == true then pass a function otherwise pass "null"
                          _saveCordinates();
                        }:null,
                        padding: EdgeInsets.all(10),

                        color: Colors.blue,
                        child: Text('SAVE',
                            style: TextStyle(
                                color: Colors.white,
                                fontStyle: FontStyle.normal,
                                fontFamily: 'Raleway',
                                fontWeight: FontWeight.w600)),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(24),
                        ))),

              ],
            ),
          ),
          progressHUD
        ]));
  }

  navigationToMap(var lat, var lng) {
    Navigator.push(
        context,
        MaterialPageRoute(
            builder: (context) => MapScreen(destLat: lat, destLong: lng)));
  }
}
