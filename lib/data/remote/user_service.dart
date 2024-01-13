import 'package:dio/dio.dart';
import 'package:flutter_application_bookstore/network/book_client.dart';

class UserService {
  Future<Response> signIn(String phone, String pass) {
    return BookClient.instance.dio.post(
      '/user/sign-in',
      data: {
        'phone': phone,
        'password': pass,
      },
    );
  }

  Future<Response> signUp(String phone, String pass, String displayName) {
    return BookClient.instance.dio.post(
      '/user/sign-up',
      data: {
        'displayName': displayName,
        'phone': phone,
        'password': pass,
      },
    );
  }
}
