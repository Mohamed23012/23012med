import  'dart:async';
import 'dart:convert'; // Import for JSON encoding/decoding
import 'package:flutter/foundation.dart';
import 'package:flutter_internet_signal/flutter_internet_signal.dart';
import 'package:flutter_internet_speed_test/flutter_internet_speed_test.dart';
import 'package:dart_ping/dart_ping.dart';
import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart'; // Import for
import 'package:intl/intl.dart';
import 'package:http/http.dart' as http;
import 'package:geolocator/geolocator.dart';
import 'package:geocoding/geocoding.dart';
import 'package:speed_test_dart/classes/server.dart';
import 'package:connectivity_plus/connectivity_plus.dart';
import 'package:telephony/telephony.dart';
import 'package:network_info_plus/network_info_plus.dart';
import 'package:device_info_plus/device_info_plus.dart';

class NetworkProvider with ChangeNotifier {
  final FlutterInternetSpeedTest speedTest = FlutterInternetSpeedTest();
  final DeviceInfoPlugin deviceInfo = DeviceInfoPlugin();
  double _downloadSpeed = 0;
  double _uploadSpeed = 0;
  double _ping = 0;
  double _jitter = 0;
  double _packetLoss = 0;
  String? _city = "---";
  String? _place = "---";
  String? _ip = "---";
  String? _asn = "---";
  String? _operator;
  String? _wifiName;
  String? _networkType = ''; // Placeholder for network technology information
  String? _location;
  double? _lat = 0;
  double? _lon = 0;
  String? _device = '---';
  String? _signalStrengthValue = null;
  static String? comment = null;
// Variable to store ISP information
  bool isTesting = false; // Track whether the test is running
  List<Server> bestServersList = [];
  Telephony telephony = Telephony.instance;
  double get downloadSpeed => _downloadSpeed;
  double get uploadSpeed => _uploadSpeed;
  double get ping => _ping;
  double? get lat => _lat;
  double? get lon => _lon;
  double get jitter => _jitter;
  double get packetLoss => _packetLoss;
  String? get city => _city;
  String? get place => _place;
  String? get ip => _ip;
  String? get asn => _asn;
  String? get networkType => _networkType;
  String? get operator => _operator;
  String? get location => _location;
  String? get signalStrengthValue => _signalStrengthValue;
  String? get wifiName => _wifiName;

  bool _isCancelled = false;
  
  Future<void> startTest() async {
    if (isTesting) return;

    isTesting = true;
    Completer<void> testCompleter = Completer<void>();

    await speedTest.startTesting(
      useFastApi: true,
      // useFastApi: false,      
      // downloadTestServer: 'http://104.154.91.24/files/test_file_1MB.txt', 
      // uploadTestServer: 'http://104.154.91.24/', 
      // fileSizeInBytes: 1048576,
      
      onStarted: () {
        print("Speed test started");
      },
      onCompleted: (TestResult download, TestResult upload) {
        _downloadSpeed = download.transferRate;
        _uploadSpeed = upload.transferRate;

        isTesting = false;
        if (!testCompleter.isCompleted) {
          testCompleter.complete();
        }
        notifyListeners();
      },
      onProgress: (double percent, TestResult data) {
        if (data.type == TestType.download) {
          _downloadSpeed = data.transferRate;
        } else {
          _uploadSpeed = data.transferRate;
        }

        notifyListeners();
      },
      onError: (String errorMessage, String speedTestError) {
        print("Error: $errorMessage, SpeedTestError: $speedTestError");

        if (!testCompleter.isCompleted) {
          testCompleter.complete();
        }
        notifyListeners();
      },
      onDefaultServerSelectionDone: (Client? client) {
        if (client != null) {
          _place = client.location?.country;
          _city = client.location?.city;
          _ip = client.ip;
          _asn = client.asn;
        }
        notifyListeners();
      },
      onCancel: () {
        print("Test canceled");

        isTesting = false;
        if (!testCompleter.isCompleted) {
          testCompleter.complete();
        }
        notifyListeners();
      },
    );

    await testCompleter.future;
  }

  void stopTest() {
    if (isTesting) {
      speedTest.cancelTest(); // Annule le test en cours
      _isCancelled = true;
      isTesting = false;
    }

    // Réinitialiser les variables de test si nécessaire
    _downloadSpeed = 0;
    _uploadSpeed = 0;
    _ping = 0;
    _jitter = 0;
    _packetLoss = 0;

    notifyListeners(); // Mettre à jour l'interface utilisateur
  }


  Future<void> networkmetrics() async {
    final ping = Ping('8.8.8.8', count: 4); // Pinging Google's DNS server

    List<double> pingTimes = [];
    int lostPackets = 0;

    ping.stream.listen((event) {
      if (event.response != null) {
        pingTimes.add(event.response!.time!.inMilliseconds.toDouble());
      } else if (event.error != null) {
        lostPackets += 1;
      }
    }).onDone(() {
      double averagePing = pingTimes.isNotEmpty
          ? pingTimes.reduce((a, b) => a + b) / pingTimes.length
          : 0.0;
      double jitter = _calculateJitter(pingTimes);
      double packetLoss = (lostPackets / pingTimes.length) * 100;

      _ping = averagePing;
      _jitter = jitter;
      _packetLoss = packetLoss;
      notifyListeners();
    });
  }


  Future<void> storeDataTest() async {
    if (_isCancelled) {
      print("Test annulé - données non enregistrées.");
      _isCancelled = false;
      return;
    }

    final prefs = await SharedPreferences.getInstance();
    // Obtenir depuis SharedPreferences

    final now = DateTime.now();
    final dateFormat = DateFormat('yyyy-MM-dd');
    final timeFormat = DateFormat('HH:mm:ss');

    final dateTimeFormat = DateFormat(
        'yyyy-MM-dd HH:mm:ss'); // Format: Year-Month-Day Hour:Minute:Second
    final dateTimeString = dateTimeFormat.format(now);

    final dateString = dateFormat.format(now);
    final timeString = timeFormat.format(now); // Convert time to string

    String? cnx = _networkType;
    if (networkType == wifiName) {
      cnx = "WiFi";
    }

    final data = {
      "index_name": "qualitynet",
      "document": {
        'downloadSpeed': _downloadSpeed,
        'uploadSpeed': _uploadSpeed,
        'ping': _ping,
        'jitter': _jitter,
        'packetLoss': _packetLoss,
        'server_city': _city,
        'server_country': _place,
        'ip_address': _ip,
        'asn': _asn,
        'date': dateString,
        'time': timeString,
        'timestamp': dateTimeString,
        'location': {"lat": _lat, "lon": _lon},
        'place': _location,
        'signalStrengthValue': _signalStrengthValue,
        'networkType': cnx,
        'operator': _operator,
        'device': _device,
        'comments': comment,
      }
    };

    final url = Uri.parse(
        'http://104.154.91.24:8000/api/insert_data/'); // Replace with your endpoint
    try {
     final response = await http.post(
        url,
        headers: {
          'Content-Type': 'application/json',
        
        },
        body: jsonEncode(data),
      );

      if (response.statusCode == 201) {
        print('Data inserted successfully: ${response.body}');
      } else {
        print('Failed to insert data: ${response.body}');
      }
    } catch (e) {
      print('Error: $e');
    }
    await prefs.setString(dateTimeString, jsonEncode(data)); // Store data
  }

  double _calculateJitter(List<double> pingTimes) {
    if (pingTimes.length < 2) return 0.0;

    double totalDifference = 0.0;
    for (int i = 1; i < pingTimes.length; i++) {
      totalDifference += (pingTimes[i] - pingTimes[i - 1]).abs();
    }
    return totalDifference / (pingTimes.length - 1);
  }

  Future<void> storeDataPlaint({
    required String complaint,
    required double rating,
  }) async {
    final prefs = await SharedPreferences.getInstance();

    // Récupérer la date et l'heure actuelles
    final now = DateTime.now();
    final dateFormat = DateFormat('yyyy-MM-dd');
    final timeFormat = DateFormat('HH:mm:ss');

    final dateTimeFormat = DateFormat(
        'yyyy-MM-dd HH:mm:ss'); // Format: Year-Month-Day Hour:Minute:Second
    final dateTimeString = dateTimeFormat.format(now);

    final dateString = dateFormat.format(now);
    final timeString = timeFormat.format(now); // Convert time to string

    // Préparer les données pour la plainte
    final data = {
      "index_name": "complaints",
      "document": {
        'complaint': complaint,
        'rating': rating,
        'date': dateString,
        'time': timeString,
        'timestamp': dateTimeString,
        'operator': _operator ?? 'Unknown',
        'networkType': _networkType ?? 'Unknown',
        'location': {"lat": _lat, "lon": _lon},
        'place': _location ?? 'Unknown',
        'device': _device ?? 'Unknown',
      },
    };

    final url = Uri.parse(
        'http://104.154.91.24:8000/api/insert_data?index_name=complaints'); // Remplacez par votre endpoint
    try {
      final response = await http.post(
        url,
        headers: {
          'Content-Type': 'application/json',
        },
        body: jsonEncode(data),
      );

      if (response.statusCode == 201) {
        print('Complaint inserted successfully: ${response.body}');
      } else {
        print('Failed to insert complaint: ${response.body}');
      }
    } catch (e) {
      print('Error: $e');
    }

    // Enregistrer la plainte localement dans SharedPreferences
    await prefs.setString(dateTimeString, jsonEncode(data));
  }

  Future<void> retrieveLocation() async {
    try {
      // Check and request location permissions
      bool serviceEnabled = await Geolocator.isLocationServiceEnabled();
      if (!serviceEnabled) {
        print('Location services are disabled.');
        return;
      }
      notifyListeners();

      LocationPermission permission = await Geolocator.checkPermission();
      if (permission == LocationPermission.denied) {
        permission = await Geolocator.requestPermission();
        if (permission == LocationPermission.deniedForever) {
          print('Location permissions are permanently denied.');
          return;
        } else if (permission == LocationPermission.denied) {
          print('Location permission denied.');
          return;
        }
      }

      // Get the location data
      Position position = await Geolocator.getCurrentPosition(
        locationSettings: LocationSettings(
          accuracy: LocationAccuracy
              .high, // equivalent   to desiredAccuracy: LocationAccuracy.high
        ),
      );

      // Use the position to get a placemark
      List<Placemark> placemarks = await placemarkFromCoordinates(
        position.latitude,
        position.longitude,
      );

      if (placemarks.isNotEmpty) {
        Placemark place = placemarks.first;
        print('Country: ${place.country}');
        print('Administrative Area: ${place.administrativeArea}');
        print('SubAdministrative Area: ${place.subAdministrativeArea}');
        print('Locality: ${place.locality}');
        print('SubLocality: ${place.subLocality}');
        print('Thoroughfare: ${place.thoroughfare}');
        print('SubThoroughfare: ${place.subThoroughfare}');
        print('Postal Code: ${place.postalCode}');
        print('Name: ${place.name}');
        print('Latitude: ${position.latitude}');
        print('Longitude: ${position.longitude}');
        _lat = position.latitude;
        _lon = position.longitude;
        _location =
            "${place.thoroughfare ?? 'N/A'} ${place.subAdministrativeArea ?? 'N/A'}";
      } else {
        print('No placemarks found.');
      }
    } catch (e) {
      print('Error retrieving location: $e');
    }
  }

Future<void> fetchOperatorInfo() async {
  final FlutterInternetSignal internetSignal = FlutterInternetSignal();

  try {
    // Retrieve operator name
    final operatorName = await telephony.simOperatorName;

    // Fetch mobile and WiFi signal strengths
    final int? mobileSignal = await internetSignal.getMobileSignalStrength();
    final int? wifiSignal = await internetSignal.getWifiSignalStrength();

    _signalStrengthValue = mobileSignal != null
        ? '$mobileSignal dBm'
        : (wifiSignal != null ? '$wifiSignal dBm' : 'Unknown');

    print('Signal Strength: $_signalStrengthValue');

    // Get network type
    NetworkType dataNetworkType = await telephony.dataNetworkType;
    _networkType = _getNetworkTypeDescription(dataNetworkType);

    // WiFi and ISP detection
    String ispName = 'Unknown ISP';
    var connectivityResult = await Connectivity().checkConnectivity();
    if (connectivityResult == ConnectivityResult.wifi) {
      String? wifiName = await NetworkInfo().getWifiName();
      _wifiName = wifiName?.replaceAll('"', '') ?? 'WiFi';

      // Fetch ISP information
      final response = await http.get(Uri.parse('http://ip-api.com/json/'));
      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        ispName = data['isp'] ?? 'UNKNOWN ISP';
      } else {
        print('Failed to fetch ISP info');
      }
    }

    print('WiFi Name: $_wifiName');
    print('ISP Name: $ispName');

    // Update operator and network type
    _operator = connectivityResult == ConnectivityResult.wifi
        ? ispName
        : (operatorName ?? 'N/A');
    _networkType = connectivityResult == ConnectivityResult.wifi
        ? _wifiName ?? 'WiFi'
        : _networkType;
  } catch (e) {
    print('Error retrieving operator info: $e');
  }
}

String _getNetworkTypeDescription(NetworkType dataNetworkType) {
  switch (dataNetworkType) {
    case NetworkType.EDGE:
      return '2G';
    case NetworkType.HSPAP:
      return '3G';
    case NetworkType.LTE:
      return '4G';
    case NetworkType.NR:
      return '5G';
    case NetworkType.IWLAN:
      return 'WiFi';
    case NetworkType.UNKNOWN:
      return 'No Network';
    default:
      return 'Unknown';
  }
}

  Future<void> getAndroidInfo() async {
    try {
      AndroidDeviceInfo androidInfo = await deviceInfo.androidInfo;
      _device = androidInfo.model;
      print('sssss${_device}');
    } catch (e) {
      print('Failed to get Android device info: $e');
    }
    notifyListeners();
  }
}
