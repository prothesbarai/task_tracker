import 'dart:async';
import 'package:connectivity_plus/connectivity_plus.dart';
import 'package:flutter/material.dart';
import 'package:internet_connection_checker/internet_connection_checker.dart';

class NetworkProvider with ChangeNotifier {
  bool _isOnline = true;
  bool get isOnline => _isOnline;
  late StreamSubscription _connectivitySub;
  late StreamSubscription _internetStatusSub;

  NetworkProvider() {_init();}

  void _init() {
    // >>> First Time Check
    _checkConnection();
    // >>> For Wifi / Mobile connectivity
    _connectivitySub = Connectivity().onConnectivityChanged.listen((event) {_checkConnection();});
    // >>> For real internet status
    _internetStatusSub = InternetConnectionChecker().onStatusChange.listen((status) {
      bool connected = status == InternetConnectionStatus.connected;
      if (connected != _isOnline) {
        _isOnline = connected;
        notifyListeners();
      }
    });
  }

  // >> Retry Method For Button
  Future recheck() async {
    await _checkConnection();
  }

  Future _checkConnection() async {
    bool hasInternet = await InternetConnectionChecker().hasConnection;
    if (hasInternet != _isOnline) {
      _isOnline = hasInternet;
      notifyListeners();
    }
  }

  @override
  void dispose() {
    _connectivitySub.cancel();
    _internetStatusSub.cancel();
    super.dispose();
  }
}
