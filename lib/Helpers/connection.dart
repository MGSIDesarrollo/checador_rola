import 'package:connectivity_plus/connectivity_plus.dart';

class ConnectivityService {
  static final ConnectivityService _instance = ConnectivityService._();

  factory ConnectivityService() => _instance;

  ConnectivityService._();

  ConnectivityResult _connectivityResult = ConnectivityResult.none;
  ConnectivityResult get connectivityResult => _connectivityResult;

  Stream<ConnectivityResult> get connectivityStream async* {
    await for (var result in Connectivity().onConnectivityChanged) {
      _connectivityResult = result[0];
      yield _connectivityResult;
    }
  }
}
