import 'dart:async';

import 'package:dio/dio.dart';
import 'package:flutter_application_bookstore/data/remote/user_service.dart';
import 'package:flutter_application_bookstore/data/spref/spref.dart';
import 'package:flutter_application_bookstore/model/user_data.dart';
import 'package:flutter_application_bookstore/shared/constants.dart';

class UserRepo {
  UserService _userService = UserService();
  UserRepo({required UserService userService}) : _userService = userService;

  Future<UserData> signIn(String phoneNumber, String password) async {
    var c = Completer<UserData>();
    try {
      var response = await _userService.signIn(phoneNumber, password);
      var userData = UserData.fromJson(response.data['data']);
      if (userData != null) {
        SPref.instance.set(SPrefCache.KEY_TOKEN, userData.token);
        c.complete(userData);
      }
    } on DioException catch (e) {
      c.completeError(e);
    } catch (e) {
      c.completeError(e);
    }
    return c.future;
  }

  Future<UserData> signUp(String phone, String pass, String displayName) async {
    var c = Completer<UserData>();
    try {
      var response = await _userService.signUp(phone, pass, displayName);
      var userData = UserData.fromJson(response.data['data']);
      if (userData != null) {
        SPref.instance.set(SPrefCache.KEY_TOKEN, userData.token);
        c.complete(userData);
      }
    } on DioException catch (e) {
      c.completeError(e);
    } catch (e) {
      c.completeError(e);
    }
    return c.future;
  }
}
