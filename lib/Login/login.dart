import 'dart:convert';
import 'package:android_intent/android_intent.dart';
import 'package:connectivity/connectivity.dart';
import 'package:flutter/material.dart';
import 'package:http/http.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:progress_hud/progress_hud.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:geolocator/geolocator.dart';

class LoginPage extends StatefulWidget {
  LoginPage({Key key, this.title}) : super(key: key);
  final String title;

  @override
  _LoginPageState createState() => _LoginPageState();
}

class _LoginPageState extends State<LoginPage> {
  final TextEditingController username = TextEditingController();
  final TextEditingController password = TextEditingController();
  bool _passwordVisible = true;
  bool checkValue = false;
  ProgressHUD progressHUD;


  // Login API Method

  Future<dynamic> _loginuser() async {
    progressHUD.state.show();
    var connectivityResult = await (Connectivity().checkConnectivity());
    if (connectivityResult == ConnectivityResult.mobile ||
        connectivityResult == ConnectivityResult.wifi) {
      String user = username.text.trim();
      String pass = password.text.trim();


      if(user == "mohfw_loc" && pass == "123456"){
        progressHUD.state.dismiss();

        SharedPreferences prefs = await SharedPreferences.getInstance();
        prefs.setString("username", "mohfw_loc");
        prefs.setString("uname", "20000001");
        prefs.setString("defaultUrl", "abc");
        prefs.setString("uatmessage", "uat message");

        // _getMainMenu();
        return Navigator.pushReplacementNamed(context, "/stockDetail");
      } else {
        progressHUD.state.dismiss();
        return showDialog(
            context: context,
            builder: (BuildContext context) {
              return AlertDialog(
                backgroundColor: Color(0xffffffff),
                title: Text("Please Enter Valid Username and Password",
                    textAlign: TextAlign.center,
                    style: TextStyle(fontSize: 13, color: Color(0xff000000))),
                actions: <Widget>[
                  new FlatButton(
                    child: new Text("Close"),
                    onPressed: () {
                      Navigator.of(context).pop();
                    },
                  )
                ],
              );
            });
      }

    } else {
      progressHUD.state.dismiss();
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

  Future _gpsService() async {
    if (!(await Geolocator().isLocationServiceEnabled())) {
      print("gps disabled");
      _checkGps();
      return null;
    } else {
      print("gps enabled");
      fetchLocation();
      return true;
    }
  }


  Future _checkGps() async {
    if (!(await Geolocator().isLocationServiceEnabled())) {
      if (Theme.of(context).platform == TargetPlatform.android) {
        showDialog(
            context: context,
            builder: (BuildContext context) {
              return AlertDialog(
                title: Text("Can't get current location"),
                content:
                const Text('Please make sure you enable GPS and try again'),
                actions: <Widget>[
                  FlatButton(
                      child: Text('Ok'),
                      onPressed: () {
                        final AndroidIntent intent = AndroidIntent(
                            action:
                            'android.settings.LOCATION_SOURCE_SETTINGS');
                        intent.launch();
                        Navigator.of(context, rootNavigator: true).pop();
                        // _gpsService();
                      })
                ],
              );
            });
      }
    }
  }
  Future<void> fetchLocation() async {
    ServiceStatus serviceStatus =
    await PermissionHandler().checkServiceStatus(PermissionGroup.location);
    bool enabled = (serviceStatus == ServiceStatus.enabled);
    print("serviceStatus enabled..  " + enabled.toString());
    _requestPerms();
  }

  void _requestPerms() async {
    final PermissionStatus permission = await PermissionHandler()
        .checkPermissionStatus(PermissionGroup.location);
    print("permission ..  " + permission.toString());

    switch (permission) {
      case PermissionStatus.granted:
        print('Granted');
        print("Login");
        _loginuser();
        break;
      case PermissionStatus.denied:
        print('denied');
        print("ask again");
        requestLocationPermission();
        break;
      case PermissionStatus.neverAskAgain:
        print('neverAskAgain');
        print('show dialog.');
        showNeverAskDialog();
        break;
    }
    // _updateStatus(permission);
  }
  void showNeverAskDialog() {
    showDialog(
        context: context,
        builder: (BuildContext context) {
          return AlertDialog(
            title: Text("Login denied!"),
            content: const Text(
                'Please make sure you enable location permission and try again'),
            actions: <Widget>[
              FlatButton(
                  child: Text('Ok'),
                  onPressed: () async {
                    Navigator.of(context, rootNavigator: true).pop();
                    await PermissionHandler().openAppSettings();
                  })
            ],
          );
        });
  }


  Future<bool> requestLocationPermission({Function onPermissionDenied}) async {
    var granted = await _requestPermission(PermissionGroup.location);
    return granted;
  }
  Future<bool> _requestPermission(PermissionGroup permission) async {
    final PermissionHandler _permissionHandler = PermissionHandler();
    var result = await _permissionHandler.requestPermissions([permission]);

    switch (result[permission]) {
      case PermissionStatus.granted:
        print('Granted 1');
        print("Login 1");

        // _updateStatus(result[permission]);
        // getAddress();
        _loginuser();
        return true;
        break;
      case PermissionStatus.denied:
        print('denied 1');
        print("ask again 1");
        // _updateStatus(result[permission]);
        return false;
        break;
      case PermissionStatus.neverAskAgain:
        print('neverAskAgain 1');
        print('show dialog. 1');
        // _updateStatus(result[permission]);
        return false;
        break;
      default:
        return false;
    }

  }





  @override
  void initState() {
    progressHUD = new ProgressHUD(
      backgroundColor: Colors.black12,
      color: Colors.white,
      containerColor: Color.fromRGBO(75, 172, 198, 1),
      borderRadius: 5.0,
      loading: false,
      text: 'Loading...',
    );
    super.initState();
    getCredential();
  }


// Get Store Value of particular User

  getCredential() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    setState(() {
      checkValue = prefs.getBool("check");
      if (checkValue != null) {
        if (checkValue) {
          username.text = prefs.getString("username");
          password.text = prefs.getString("password");
        } else {
          username.clear();
          password.clear();
          prefs.clear();
        }
      } else {
        checkValue = false;
      }
    });
  }

  // Launcher Method
  _launchURL() async {
    const url = 'https://www.cdac.in/';
    if (await canLaunch(url)) {
      await launch(url);
    } else {
      throw 'Could not launch $url';
    }
  }

  // Empty TextFields

  Widget _entryField(String title,
      {TextEditingController controller,
        IconButton suffixIcon,
        bool obscureText}) {
    return Container(
      margin: EdgeInsets.symmetric(vertical: 10),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: <Widget>[
          Text(
            title,
            style: TextStyle(
                fontWeight: FontWeight.w500,
                fontSize: 15,
                fontFamily: 'Open Sans'),
          ),
          SizedBox(
            height: 10,
          ),
          TextField(
            obscureText: obscureText,
            controller: controller,
            decoration: InputDecoration(
                border: InputBorder.none,
                fillColor: Color(0xfff3f3f4),
                filled: true,
                suffixIcon: suffixIcon),
          ),
        ],
      ),
    );
  }

  // Submission Button

  Widget _submitButton() {
    return GestureDetector(
        onTap: () async {
          _gpsService();
          // _loginuser();
        },
        child: Container(
          width: MediaQuery.of(context).size.width,
          padding: EdgeInsets.symmetric(vertical: 10),
          alignment: Alignment.center,
          decoration: BoxDecoration(
              borderRadius: BorderRadius.all(Radius.circular(5)),
              boxShadow: <BoxShadow>[
                BoxShadow(
                    color: Colors.grey.shade200,
                    offset: Offset(2, 4),
                    blurRadius: 5,
                    spreadRadius: 2)
              ],
              color: Colors.blue),
          child: Text(
            'Login',
            style: TextStyle(
                fontSize: 20, color: Colors.white, fontFamily: 'Open Sans'),
          ),
        ));
  }




// Get Title Widget

  Widget _title() {
    return RichText(
      textAlign: TextAlign.center,
      text: new TextSpan(
        // Note: Styles for TextSpans must be explicitly defined.
        // Child text spans will inherit styles from parent
        style: new TextStyle(
          fontSize: 14.0,
          color: Colors.black,
        ),
        children: <TextSpan>[
          TextSpan(
              text: 'Welcome To \n',
              style: TextStyle(
                  color: Color(0xff2d0e3e),
                  fontSize: 25,
                  fontFamily: 'Open Sans',
                  fontWeight: FontWeight.bold)),
          new TextSpan(
              text: 'Health Facility Identifier',
              style: new TextStyle(
                  fontSize: 25,
                  fontWeight: FontWeight.bold,
                  fontFamily: 'Open Sans',
                  color: Color(0xffC6426E))),
          new TextSpan(
              text: '',
              style: new TextStyle(
                  fontSize: 25,
                  fontWeight: FontWeight.bold,
                  fontFamily: 'Open Sans',
                  color: Color(0xff2d0e3e))),
        ],
      ),
    );
  }


  Widget _emailPasswordWidget() {
    return Column(
      children: <Widget>[
        _entryField(
          "Username",
          controller: username,
          obscureText: false,
        ),
        _entryField(
          "Password",
          controller: password,
          obscureText: _passwordVisible,
          suffixIcon: IconButton(
            icon: Icon(
              _passwordVisible ? Icons.visibility : Icons.visibility_off,
              color: Color(0xff2e1b3e),
            ),
            onPressed: () {
              setState(() {
                _passwordVisible = !_passwordVisible;
              });
            },
          ),
        ),
      ],
    );
  }

  @override
  // Main Screen
  Widget build(BuildContext context) {
    final height = MediaQuery.of(context).size.height;
    return Scaffold(
      body: Stack(
        children: <Widget>[
          new Center(
            child: SingleChildScrollView(
              scrollDirection: Axis.vertical,
              child: Container(
                child: Padding(
                    padding: const EdgeInsets.all(36.0),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.center,
                      mainAxisAlignment: MainAxisAlignment.center,
                      mainAxisSize: MainAxisSize.max,
                      children: <Widget>[
                        Container(
                          height: 130.0,
                          width: 130.0,
                          // margin: const EdgeInsets.only(bottom:60),
                          child: new Image(
                            image: AssetImage("assets/images/locationsearch.jpg"),
                            fit: BoxFit.contain,
                          ),
                          // child: new Image(image: AssetImage("assets/images/img8.png"),fit: BoxFit.contain,),
                        ),
                        SizedBox(height: height * .001),
                        _title(),
                        SizedBox(height: 50),
                        _emailPasswordWidget(),
                        SizedBox(height: 15),
                        _submitButton(),
                        SizedBox(height: 10),
                        // _bottomRegistrationtitle()
                        // _divider(),
                      ],
                    )),
              ),
            ),
          ),
          progressHUD
        ],
      ),

      // bottom footer app
      bottomSheet: Container(
        width: MediaQuery.of(context).size.width,
        height: 35,
        color: Colors.transparent,
        child: Container(
          margin: const EdgeInsets.only(bottom: 8),
          child: new Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: <Widget>[
              Text('Designed & Developed by ',
                  style: TextStyle(
                      fontFamily: 'Open Sans', color: Color(0xff283643))),
              GestureDetector(
                  onTap: _launchURL,
                  child: Text("C-DAC",
                      style: TextStyle(
                          decoration: TextDecoration.underline,
                          color: Color(0xffC6426E)))),
            ],
          ),
          color: Colors.transparent,
        ),
      ),
    );
  }
}
