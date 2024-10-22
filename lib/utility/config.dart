import 'dart:io';
import 'package:network_info_plus/network_info_plus.dart';

class Config {
  static String master = 'http://192.168.1.237:5000'; // Default IP

  static String get serverUpload => '$master/upload';
  static String get ingredient => '$master/recommend_by_ingredients';
  static String get youmaylike => '$master/recommend_popular';
  static String get tag => '$master/recommend_by_tags';
  static String get uploadrecipe => '$master/upload-recipe';

  // Add method to update the Flask server IP dynamically
  static void setMaster(String newMasterIp) {
    master = 'http://$newMasterIp:5000';
  }
}

class FlaskServerFinder {
  static Future<String?> findFlaskServer(int port) async {
    // Get the WiFi IP address of the device
    final info = NetworkInfo();
    final wifiIP = await info.getWifiIP();

    if (wifiIP == null) return null;

    // Extract the subnet from the WiFi IP (e.g., "192.168.1")
    final subnet = wifiIP.substring(0, wifiIP.lastIndexOf('.'));

    // List to store all potential IP scanning futures
    List<Future<String?>> scanFutures = [];

    // Scan all possible IP addresses in the subnet
    for (int i = 1; i < 255; i++) {
      final testIP = '$subnet.$i';
      scanFutures.add(_checkFlaskServer(testIP, port));
    }

    // Wait for the first valid response or all failures
    try {
      final results = await Future.wait(scanFutures);
      return results.firstWhere((ip) => ip != null, orElse: () => null);
    } catch (e) {
      print('Error scanning network: $e');
      return null;
    }
  }

  static Future<String?> _checkFlaskServer(String ip, int port) async {
    try {
      final socket =
          await Socket.connect(ip, port, timeout: Duration(milliseconds: 500));
      await socket.close();

      // Try to make an HTTP request to verify it's actually a Flask server
      final url = Uri.parse('http://$ip:$port');
      final response = await HttpClient()
          .getUrl(url)
          .timeout(Duration(seconds: 1))
          .then((request) => request.close());

      if (response.statusCode == 200) {
        return ip;
      }
    } catch (e) {
      // Connection failed or timed out
    }
    return null;
  }
}
