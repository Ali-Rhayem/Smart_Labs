import 'package:flutter/foundation.dart';
import 'package:smart_labs_mobile/models/user_model.dart';

class UserProvider extends ChangeNotifier {
  User? _user;
  
  User? get user => _user;
  
  void setUser(User user) {
    _user = user;
    notifyListeners();
  }
  
  void clearUser() {
    _user = null;
    notifyListeners();
  }
} 