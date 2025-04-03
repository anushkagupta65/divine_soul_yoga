import 'package:divine_soul_yoga/src/api_service/apiservice.dart';
import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

class Userprovider extends ChangeNotifier {
  ApiService apiService = ApiService();
  Map<String, dynamic>? _profileData;
  bool _isLoading = false;
  String? _errorMessage;

  Map<String, dynamic>? get profileData => _profileData;
  bool get isLoading => _isLoading;
  String? get errorMessage => _errorMessage;

  Future<void> fetchProfileData() async {
    _isLoading = true;
    _errorMessage = null;
    notifyListeners();

    try {
      final result = await apiService.postProfileData();
      debugPrint("Full API Response: ${result.toString()}"); // Detailed logging
      if (result['success']) {
        debugPrint(
            "Subscription Status from API: ${result['data']['user']['subscription_status']}");
        _profileData = result['data'];
        SharedPreferences prefs = await SharedPreferences.getInstance();
        prefs.setString(
            'subscriptionCheck', result['data']['user']['subscription_status']);
        debugPrint(
            "Stored subscriptionCheck in SharedPreferences: ${result['data']['user']['subscription_status']}");
        notifyListeners();
      } else {
        _errorMessage = result['message'];
        _isLoading = false;
        notifyListeners();
      }
    } catch (e) {
      _isLoading = false;
      _errorMessage = 'Something went wrong: $e';
      notifyListeners();
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }
}
