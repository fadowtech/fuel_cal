import 'package:flutter/material.dart';
import 'package:connectivity_plus/connectivity_plus.dart';
import 'package:fuel_cal/no_internet_page.dart';

class ConnectivityWrapper extends StatefulWidget {
  final Widget child;
  
  const ConnectivityWrapper({super.key, required this.child});

  @override
  State<ConnectivityWrapper> createState() => _ConnectivityWrapperState();
}

class _ConnectivityWrapperState extends State<ConnectivityWrapper> {
  bool _hasInternet = true;
  final Connectivity _connectivity = Connectivity();

  @override
  void initState() {
    super.initState();
    _checkInitial();
    _connectivity.onConnectivityChanged.listen((List<ConnectivityResult> results) {
      final hasInternet = !results.contains(ConnectivityResult.none) && results.isNotEmpty;
      if (_hasInternet != hasInternet) {
        setState(() {
          _hasInternet = hasInternet;
        });
      }
    });
  }

  Future<void> _checkInitial() async {
    final results = await _connectivity.checkConnectivity();
    setState(() {
      _hasInternet = !results.contains(ConnectivityResult.none) && results.isNotEmpty;
    });
  }

  void _retry() {
    _checkInitial();
  }

  @override
  Widget build(BuildContext context) {
    if (!_hasInternet) {
      return Directionality(
        textDirection: TextDirection.ltr,
        child: NoInternetPage(onRetry: _retry),
      );
    }
    return widget.child;
  }
}
