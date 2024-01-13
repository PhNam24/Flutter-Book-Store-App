import 'package:flutter_application_bookstore/base/base_event.dart';
import 'package:flutter_application_bookstore/model/user_data.dart';

class SignInSuccessEvent extends BaseEvent {
  final UserData userData;
  SignInSuccessEvent(this.userData);
}