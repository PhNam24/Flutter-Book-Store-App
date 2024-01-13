import 'package:flutter/material.dart';
import 'package:flutter_application_bookstore/base/base_event.dart';
import 'package:flutter_application_bookstore/base/base_widget.dart';
import 'package:flutter_application_bookstore/data/remote/user_service.dart';
import 'package:flutter_application_bookstore/data/repositories/user_repo.dart';
import 'package:flutter_application_bookstore/event/sigin_fail_event.dart';
import 'package:flutter_application_bookstore/event/signin_event.dart';
import 'package:flutter_application_bookstore/event/signin_success_event.dart';
import 'package:flutter_application_bookstore/module/signin/signin_bloc.dart';
import 'package:flutter_application_bookstore/shared/app_color.dart';
import 'package:flutter_application_bookstore/shared/widget/bloc_listener.dart';
import 'package:flutter_application_bookstore/shared/widget/loading_widget.dart';
import 'package:flutter_application_bookstore/shared/widget/normal_button.dart';
import 'package:provider/provider.dart';

class SignInPage extends StatelessWidget {
  const SignInPage({super.key});

  @override
  Widget build(BuildContext context) {
    return PageContainer(
      title: "Sign In",
      di: [
        Provider.value(
          value: UserService(),
        ),
        ProxyProvider<UserService, UserRepo>(
          update: (context, userService, previous) {
            return UserRepo(userService: userService);
          },
        )
      ],
      bloc: [],
      actions: [],
      child: SignInFormWidget(),
    );
  }
}

class SignInFormWidget extends StatefulWidget {
  @override
  State<SignInFormWidget> createState() => _SignInFormWidgetState();
}

class _SignInFormWidgetState extends State<SignInFormWidget> {
  final TextEditingController _phoneNumberController = TextEditingController();

  final TextEditingController _passwordController = TextEditingController();

  handleEvent(BaseEvent event) {
    if (event is SignInSuccessEvent) {
      Navigator.pushReplacementNamed(context, '/home');
      return;
    }

    if (event is SignInFailEvent) {
      final snackBar = SnackBar(
        content: Text(event.errMessage),
        backgroundColor: Colors.red,
      );
      ScaffoldMessenger.of(context).showSnackBar(snackBar);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Provider<SignInBloc>.value(
      value: SignInBloc(userRepo: Provider.of(context)),
      child: Consumer<SignInBloc>(
        builder: (context, bloc, child) {
          return BlocListener<SignInBloc>(
            listener: handleEvent,
            child: LoadingTask(
              bloc: bloc,
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: <Widget>[
                  _buildWelcomeText(),
                  _buildPhoneField(bloc),
                  _buildPasswordField(bloc),
                  _buildSigninButton(bloc),
                  _buildFooter(),
                ],
              ),
            ),
          );
        },
      ),
    );
  }

  Widget _buildWelcomeText() {
    return Container(
      child: Text(
        "Hello, Welcome back!",
        style: TextStyle(
          fontSize: 30,
          fontWeight: FontWeight.bold,
        ),
      ),
    );
  }

  Widget _buildPhoneField(SignInBloc bloc) {
    return StreamProvider<String?>.value(
      initialData: null,
      value: bloc.phoneStream,
      child: Consumer<String?>(
        builder: (context, msg, child) => Container(
          padding: EdgeInsets.only(left: 20, right: 20),
          margin: EdgeInsets.only(top: 15),
          child: TextField(
            controller: _phoneNumberController,
            onChanged: (text) {
              bloc.phoneSink.add(text);
            },
            cursorColor: Colors.black,
            decoration: InputDecoration(
              label: Text("Phone Number"),
              errorText: msg == "ok" ? null : msg,
              icon: Icon(
                Icons.phone,
                color: AppColor.blue,
              ),
              hintText: "Ex: 0987666666",
              hintStyle: TextStyle(
                fontSize: 15,
                color: AppColor.grey,
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildPasswordField(SignInBloc bloc) {
    return StreamProvider<String?>.value(
      initialData: null,
      value: bloc.passwordStream,
      child: Consumer<String?>(
        builder: (context, msg, child) => Container(
          padding: EdgeInsets.only(left: 20, right: 20),
          margin: EdgeInsets.only(top: 15),
          child: TextField(
            controller: _passwordController,
            onChanged: (text) {
              bloc.passwordSink.add(text);
            },
            cursorColor: Colors.black,
            obscureText: true,
            decoration: InputDecoration(
              label: Text("Password"),
              errorText: msg == "ok" ? null : msg,
              icon: Icon(
                Icons.lock,
                color: AppColor.blue,
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildSigninButton(SignInBloc bloc) {
    return StreamProvider<bool>.value(
      initialData: false,
      value: bloc.signInBtnStream,
      child: Consumer<bool>(
        builder: (context, enable, child) => Container(
          margin: EdgeInsets.only(top: 20),
          child: NormalButton(
            title: "Sign In",
            onPressed: enable
                ? () => {
                      print("status sign-in: $enable"),
                      bloc.event.add(
                        SignInEvent(
                          phone: _phoneNumberController.text,
                          pass: _passwordController.text,
                        ),
                      ),
                    }
                : () {
                    print("status sign-in: $enable");
                  },
          ),
        ),
      ),
    );
  }

  Widget _buildFooter() {
    return Container(
      padding: EdgeInsets.only(left: 25, right: 20),
      margin: EdgeInsets.only(top: 15),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.center,
        children: <Widget>[
          Text("New User? "),
          GestureDetector(
            child: Container(
              padding: EdgeInsets.all(5),
              child: Text(
                "Sign Up!",
                style: TextStyle(
                  color: AppColor.blue,
                ),
              ),
            ),
            onTap: () {
              Navigator.pushNamed(context, "/sign-up");
            },
          ),
          GestureDetector(
            child: Container(
              padding: EdgeInsets.all(5),
              child: Text(
                "Forgot Password?",
                style: TextStyle(
                  color: AppColor.blue,
                ),
              ),
            ),
            onTap: () => {},
          ),
        ],
      ),
    );
  }
}
