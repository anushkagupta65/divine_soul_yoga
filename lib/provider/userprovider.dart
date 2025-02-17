import 'package:divine_soul_yoga/api_service/apiservice.dart';
import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

class Userprovider extends ChangeNotifier {
  ApiService apiService = new ApiService();
  Map<String, dynamic>? _profileData; // Holds the profile data
  bool _isLoading = false; // Tracks loading state
  String? _errorMessage; // Holds error messages

  Map<String, dynamic>? get profileData => _profileData;
  bool get isLoading => _isLoading;
  String? get errorMessage => _errorMessage;
  Future<void> fetchProfileData() async {
    _isLoading = true;
    _errorMessage = null;
    notifyListeners(); // Notify UI about loading state

    try {
      final result =
          await apiService.postProfileData(); // Call your API function
      if (result['success']) {
        print("Result in Provider ${result['success']}");

        _profileData = result['data'];
        print('User Data.....> ${result['data']}');
        SharedPreferences prefs = await SharedPreferences.getInstance();
        prefs.setString('subscriptionCheck', result['data']['user']['subscription_status']);
        print("profile Data in provider${_profileData.toString()} ");
        notifyListeners();
        // Update profile data
      } else {
        _errorMessage = result['message']; // Update error message
        _isLoading = false;
        notifyListeners();
      }
    } catch (e) {
      _isLoading = false;
      _errorMessage = 'Something went wrong: $e'; // Handle exceptions
      notifyListeners();
    } finally {
      _isLoading = false;
      notifyListeners(); // Notify UI about state changes
    }
  }
}
