import 'dart:async';

import 'package:flutter_application_bookstore/base/base_bloc.dart';
import 'package:flutter_application_bookstore/base/base_event.dart';
import 'package:flutter_application_bookstore/data/repositories/user_repo.dart';
import 'package:flutter_application_bookstore/event/signup_event.dart';
import 'package:flutter_application_bookstore/event/signup_fail_event.dart';
import 'package:flutter_application_bookstore/event/signup_success_event.dart';
import 'package:flutter_application_bookstore/shared/validation.dart';
import 'package:rxdart/rxdart.dart';

class SignUpBloc extends BaseBloc {
  late UserRepo _userRepo;
  final _phoneSubject = BehaviorSubject<String>();
  final _passwordSubject = BehaviorSubject<String>();
  final _displayNameSubject = BehaviorSubject<String>();
  final _signUpBtnSubject = BehaviorSubject<bool>();

  SignUpBloc({required UserRepo userRepo}) {
    _userRepo = userRepo;
    validateSignUp();
  }

  var phoneValidation = StreamTransformer<String, String>.fromHandlers(
    handleData: (phone, sink) {
      if (Validation.isPhoneValid(phone)) {
        sink.add("ok");
        return;
      }
      sink.add("Invalid Phone Number!");
    },
  );

  var passwordValidation = StreamTransformer<String, String>.fromHandlers(
    handleData: (pass, sink) {
      if (Validation.isPasswordValid(pass)) {
        sink.add("ok");
        return;
      }
      sink.add("Password is too short!");
    },
  );

  var displayNameValidation = StreamTransformer<String, String>.fromHandlers(
    handleData: (displayName, sink) {
      if (Validation.isDisplayNameValid(displayName)) {
        sink.add("ok");
        return;
      }
      sink.add("Display name is too short!");
    },
  );

  Stream<String> get phoneStream =>
      _phoneSubject.stream.transform(phoneValidation);
  Sink<String> get phoneSink => _phoneSubject.sink;

  Stream<String> get passwordStream =>
      _passwordSubject.stream.transform(passwordValidation);
  Sink<String> get passwordSink => _passwordSubject.sink;

  Stream<String> get displayNameStream =>
      _displayNameSubject.stream.transform(displayNameValidation);
  Sink<String> get displayNameSink => _displayNameSubject.sink;

  Stream<bool> get signUpBtnStream => _signUpBtnSubject.stream;
  Sink<bool> get signUpBtnSink => _signUpBtnSubject.sink;

  validateSignUp() {
    Rx.combineLatest3(_phoneSubject, _passwordSubject, _displayNameSubject,
        (phone, pass, displayName) {
      return Validation.isPhoneValid(phone) &&
          Validation.isPasswordValid(pass) &&
          Validation.isDisplayNameValid(displayName);
    }).listen((enable) {
      signUpBtnSink.add(enable);
    });
  }

  @override
  void dispatchEvent(BaseEvent event) {
    super.dispatchEvent(event);
    switch (event.runtimeType) {
      case SignUpEvent:
        handleSignUp(event);
        break;
    }
  }

  handleSignUp(event) {
    signUpBtnSink.add(false);
    loadingSink.add(true);
    Future.delayed(Duration(seconds: 3), () {
      SignUpEvent signUpEvent = event as SignUpEvent;
      _userRepo
          .signUp(signUpEvent.phone, signUpEvent.pass, signUpEvent.displayName)
          .then(
        (userData) {
          processEventSink.add(SignUpSuccessEvent(userData));
        },
        onError: (e) {
          signUpBtnSink.add(true);
          loadingSink.add(false);
          processEventSink
              .add(SignUpFailEvent(e.response.data['code'].toString()));
        },
      );
    });
  }

  @override
  void dispose() {
    _phoneSubject.close();
    _passwordSubject.close();
    _signUpBtnSubject.close();
  }
}
