import 'package:flutter_application_bookstore/base/base_event.dart';

class SignUpEvent extends BaseEvent {
  String phone;
  String pass;
  String displayName;

  SignUpEvent(
      {required this.phone, required this.pass, required this.displayName});
}
