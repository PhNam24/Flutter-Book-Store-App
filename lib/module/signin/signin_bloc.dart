import 'dart:async';
import 'dart:convert';

import 'package:flutter_application_bookstore/base/base_bloc.dart';
import 'package:flutter_application_bookstore/base/base_event.dart';
import 'package:flutter_application_bookstore/data/repositories/user_repo.dart';
import 'package:flutter_application_bookstore/event/sigin_fail_event.dart';
import 'package:flutter_application_bookstore/event/signin_event.dart';
import 'package:flutter_application_bookstore/event/signin_success_event.dart';
import 'package:flutter_application_bookstore/shared/validation.dart';
import 'package:rxdart/rxdart.dart';

class SignInBloc extends BaseBloc {
  late UserRepo _userRepo;
  final _phoneSubject = BehaviorSubject<String>();
  final _passwordSubject = BehaviorSubject<String>();
  final _signInBtnSubject = BehaviorSubject<bool>();

  SignInBloc({required UserRepo userRepo}) {
    _userRepo = userRepo;
    validateSignIn();
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

  Stream<String> get phoneStream =>
      _phoneSubject.stream.transform(phoneValidation);
  Sink<String> get phoneSink => _phoneSubject.sink;

  Stream<String> get passwordStream =>
      _passwordSubject.stream.transform(passwordValidation);
  Sink<String> get passwordSink => _passwordSubject.sink;

  Stream<bool> get signInBtnStream => _signInBtnSubject.stream;
  Sink<bool> get signInBtnSink => _signInBtnSubject.sink;

  validateSignIn() {
    Rx.combineLatest2(_phoneSubject, _passwordSubject, (phone, pass) {
      return Validation.isPhoneValid(phone) && Validation.isPasswordValid(pass);
    }).listen((enable) {
      signInBtnSink.add(enable);
    });
  }

  @override
  void dispatchEvent(BaseEvent event) {
    // TODO: implement dispatchEvent
    super.dispatchEvent(event);
    switch (event.runtimeType) {
      case SignInEvent:
        handleSignIn(event);
        break;
    }
  }

  handleSignIn(event) {
    signInBtnSink.add(false);
    loadingSink.add(true);
    Future.delayed(Duration(seconds: 3), () {
      SignInEvent signInEvent = event as SignInEvent;
      _userRepo.signIn(signInEvent.phone, signInEvent.pass).then(
        (userData) {
          processEventSink.add(SignInSuccessEvent(userData));
        },
        onError: (e) {
          signInBtnSink.add(true);
          loadingSink.add(false);
          processEventSink
              .add(SignInFailEvent(e.response.data['code'].toString()));
        },
      );
    });
  }

  handleSignUp(event) {}

  @override
  void dispose() {
    _phoneSubject.close();
    _passwordSubject.close();
    _signInBtnSubject.close();
  }
}
