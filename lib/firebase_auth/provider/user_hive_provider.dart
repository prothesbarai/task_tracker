import 'package:flutter/material.dart';
import 'package:hive/hive.dart';
import '../user_hive_model/user_hive_model.dart';

class UserHiveProvider with ChangeNotifier {
  final Box<UserHiveModel> _userBox = Hive.box<UserHiveModel>("UserLoginBox");
  UserHiveModel? user;

  UserHiveProvider() {_init();}

  Future<void> _init() async {
    if (_userBox.isNotEmpty) {
      user = _userBox.getAt(0);
    }
    notifyListeners();
  }

  /// >>> Update Specific Field to Hive ========================================
  Future<void> updateUser({String? uid, String? name, String? email, String? phone, bool? regLoginFlag,}) async {
    if (user == null) {
      user = UserHiveModel(uid: uid ?? "", name: name ?? "", email: email ?? "", phone: phone ?? "", regLoginFlag: regLoginFlag ?? false,);
      await _userBox.add(user!);
    } else {
      user!.uid = uid ?? user!.uid;
      user!.name = name ?? user!.name;
      user!.email = email ?? user!.email;
      user!.phone = phone ?? user!.phone;
      user!.regLoginFlag = regLoginFlag ?? user!.regLoginFlag;
      await user!.save();
    }
    notifyListeners();
  }
  /// <<< Update Specific Field to Hive ========================================


  /// >>> Clear Hive User Data =================================================
  Future<void> clearUserData() async{
    await _userBox.clear();
    user = null;
    notifyListeners();
  }
  /// <<< Clear Hive User Data =================================================
}
