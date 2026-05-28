import 'package:connectivity_plus/connectivity_plus.dart';

class NetworkInfo {
  final Connectivity _connectivity;

  NetworkInfo({Connectivity? connectivity}) : _connectivity = connectivity ?? Connectivity();

  Future<bool> get isConnected async {
    final results = await _connectivity.checkConnectivity();
    // In newer connectivity_plus, it returns a List<ConnectivityResult>
    for (var result in results) {
       if (result != ConnectivityResult.none) {
          return true;
       }
    }
    return false;
  }
}
