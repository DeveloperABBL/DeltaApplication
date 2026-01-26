import 'package:flutter/material.dart';

// Placeholder UserModel - will be created when needed
class UserModel {
  final String? id;
  final String? name;

  UserModel({this.id, this.name});

  factory UserModel.guest() => UserModel();
}

class CustomerProvider extends ChangeNotifier {
  UserModel _current = UserModel.guest();
  UserModel get current => _current;

  set newUser(UserModel data) {
    _current = data;
    notifyListeners();
  }

  UserModel logout() {
    _current = UserModel.guest();
    notifyListeners();
    return _current;
  }
}
