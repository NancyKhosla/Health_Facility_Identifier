import 'dart:convert';
import 'dart:io';
import 'package:http/io_client.dart';



String user ="admin";
String password ="adminabc";


String basicAuth1 = 'Basic ' + base64Encode(utf8.encode('$user:$password'));
Map<String,String> headers = {'content-type':'text/plain','authorization':basicAuth1};


bool trustSelfSigned = true;
HttpClient httpClient = new HttpClient()
  ..badCertificateCallback = ((X509Certificate cert, String host, int port) => trustSelfSigned);
IOClient ioClient = new IOClient(httpClient);

