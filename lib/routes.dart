

import 'package:flutter/material.dart';
import 'package:health_facility_identifier/Login/loggedIn.dart';
import 'package:health_facility_identifier/Login/login.dart';
import 'package:health_facility_identifier/home.dart';




// Navigation/Routing

final routes = {
  '/': (BuildContext context) => new IsLoggedIn(),
  '/login': (BuildContext context) => new LoginPage(),
  '/stockDetail': (BuildContext context) => new Homepage(),
};
