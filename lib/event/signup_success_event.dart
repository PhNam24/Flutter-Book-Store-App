import 'package:flutter_application_bookstore/base/base_event.dart';
import 'package:flutter_application_bookstore/model/user_data.dart';

class SignUpSuccessEvent extends BaseEvent {
  final UserData userData;
  SignUpSuccessEvent(this.userData);
}