import 'package:flutter/material.dart';
import 'package:flutter_application_bookstore/base/base_event.dart';
import 'package:flutter_application_bookstore/base/base_widget.dart';
import 'package:flutter_application_bookstore/data/remote/user_service.dart';
import 'package:flutter_application_bookstore/data/repositories/user_repo.dart';
import 'package:flutter_application_bookstore/event/signup_event.dart';
import 'package:flutter_application_bookstore/event/signup_fail_event.dart';
import 'package:flutter_application_bookstore/event/signup_success_event.dart';
import 'package:flutter_application_bookstore/module/signin/signin_page.dart';
import 'package:flutter_application_bookstore/module/signup/singup_bloc.dart';
import 'package:flutter_application_bookstore/shared/app_color.dart';
import 'package:flutter_application_bookstore/shared/widget/bloc_listener.dart';
import 'package:flutter_application_bookstore/shared/widget/loading_widget.dart';
import 'package:flutter_application_bookstore/shared/widget/normal_button.dart';
import 'package:provider/provider.dart';

class SignUpPage extends StatelessWidget {
  const SignUpPage({super.key});

  @override
  Widget build(BuildContext context) {
    return PageContainer(
      title: "Sign Up",
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
      child: SignUpFormWidget(),
    );
  }
}

class SignUpFormWidget extends StatefulWidget {
  const SignUpFormWidget({super.key});

  @override
  State<SignUpFormWidget> createState() => _SignUpFormWidgetState();
}

class _SignUpFormWidgetState extends State<SignUpFormWidget> {
  final TextEditingController _phoneNumberController = TextEditingController();

  final TextEditingController _passwordController = TextEditingController();

  final TextEditingController _displayNameController = TextEditingController();

  handleEvent(BaseEvent event) {
    if (event is SignUpSuccessEvent) {
      Navigator.pushAndRemoveUntil(
        context,
        MaterialPageRoute(builder: (BuildContext context) => SignInPage()),
        ModalRoute.withName('/sign-in'),
      );
      return;
    }

    if (event is SignUpFailEvent) {
      final snackBar = SnackBar(
        content: Text(event.errMessage),
        backgroundColor: Colors.red,
      );
      ScaffoldMessenger.of(context).showSnackBar(snackBar);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Provider<SignUpBloc>.value(
      value: SignUpBloc(userRepo: Provider.of(context)),
      child: Consumer<SignUpBloc>(
        builder: (context, bloc, child) {
          return BlocListener<SignUpBloc>(
            listener: handleEvent,
            child: LoadingTask(
              bloc: bloc,
              child: Container(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: <Widget>[
                    _buildHeaderText(),
                    _buildPhoneField(bloc),
                    _buildPassField(bloc),
                    _buildDisplayNameField(bloc),
                    _buildSignUpButton(bloc),
                    _buildFooter(),
                  ],
                ),
              ),
            ),
          );
        },
      ),
    );
  }

  Widget _buildHeaderText() {
    return Container(
      padding: EdgeInsets.only(left: 20, right: 20),
      child: Text(
        "Welcome! Please Fill The Form Below!",
        style: TextStyle(
          fontSize: 15,
          fontWeight: FontWeight.bold,
        ),
      ),
    );
  }

  Widget _buildPhoneField(SignUpBloc bloc) {
    return StreamProvider<String?>.value(
      initialData: null,
      value: bloc.phoneStream,
      child: Consumer<String?>(
        builder: (context, msg, chiid) => Container(
          padding: EdgeInsets.only(left: 20, right: 20),
          margin: EdgeInsets.only(top: 15),
          child: TextField(
            controller: _phoneNumberController,
            cursorColor: Colors.black,
            onChanged: (text) {
              bloc.phoneSink.add(text);
            },
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

  Widget _buildPassField(SignUpBloc bloc) {
    return StreamProvider<String?>.value(
      initialData: null,
      value: bloc.passwordStream,
      child: Consumer<String?>(
        builder: (context, msg, child) => Container(
          padding: EdgeInsets.only(left: 20, right: 20),
          margin: EdgeInsets.only(top: 15),
          child: TextField(
            controller: _passwordController,
            cursorColor: Colors.black,
            onChanged: (text) {
              bloc.passwordSink.add(text);
            },
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

  Widget _buildDisplayNameField(SignUpBloc bloc) {
    return StreamProvider<String?>.value(
      initialData: null,
      value: bloc.displayNameStream,
      child: Consumer<String?>(
        builder: (context, msg, child) => Container(
          padding: EdgeInsets.only(left: 20, right: 20),
          margin: EdgeInsets.only(top: 15),
          child: TextField(
            controller: _displayNameController,
            cursorColor: Colors.black,
            onChanged: (text) {
              bloc.displayNameSink.add(text);
            },
            decoration: InputDecoration(
              label: Text("Display Name"),
              errorText: msg == "ok" ? null : msg,
              icon: Icon(
                Icons.person,
                color: AppColor.blue,
              ),
              hintText: "Ex: Jone Cena",
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

  Widget _buildSignUpButton(SignUpBloc bloc) {
    return StreamProvider<bool>.value(
      initialData: false,
      value: bloc.signUpBtnStream,
      child: Consumer<bool>(
        builder: (context, enable, child) => Container(
          margin: EdgeInsets.only(top: 20),
          child: NormalButton(
            title: "Sign Up",
            onPressed: enable
                ? () => {
                      print("status sign-up: $enable"),
                      bloc.event.add(
                        SignUpEvent(
                          phone: _phoneNumberController.text,
                          pass: _passwordController.text,
                          displayName: _displayNameController.text,
                        ),
                      ),
                    }
                : () {
                    print("status sign-up: $enable");
                  },
          ),
        ),
      ),
    );
  }

  Widget _buildFooter() {
    return Container(
      margin: EdgeInsets.only(top: 5),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.center,
        children: <Widget>[
          Text("Already have account?"),
          Container(
            padding: EdgeInsets.all(5),
            child: GestureDetector(
              child: Text(
                "Sign in!",
                style: TextStyle(
                  color: AppColor.blue,
                ),
              ),
              onTap: () {
                Navigator.popUntil(context, (route) => false);
                Navigator.pushNamed(context, "/sign-in");
              },
            ),
          )
        ],
      ),
    );
  }
}
