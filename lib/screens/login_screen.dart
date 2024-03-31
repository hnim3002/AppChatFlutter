import 'package:email_validator/email_validator.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flash_chat_flutter/constants.dart';
import 'package:flutter/material.dart';
import 'package:modal_progress_hud_nsn/modal_progress_hud_nsn.dart';

import '../components/widget/rounded_button.dart';

class LoginScreen extends StatefulWidget {
  const LoginScreen({super.key});

  static String id = 'login_screen';

  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  bool isLoad = false;
  final TextEditingController _emailController = TextEditingController();
  final TextEditingController _passwordController = TextEditingController();
  String? _emailErrorText;
  String? _passwordErrorText;

  @override
  void initState() {
    // TODO: implement initState
    super.initState();
    FirebaseAuth.instance.authStateChanges().listen((User? user) {
      if (user == null) {
        print('User is currently signed out!');
      } else {
        //pushReplacement
        Navigator.pushNamed(context, '/chat_screen');
      }
    });
  }


  bool _validateInput() {
    bool isValidate = true;
    setState(() {
      if (_emailController.text.isEmpty) {
        _emailErrorText = 'Please enter email';
        isValidate = false;
      } else if (!EmailValidator.validate(_emailController.text)) {
        _emailErrorText = 'Please enter valid email';
        isValidate = false;
      } else {
        _emailErrorText = null;
      }
      if (_passwordController.text.isEmpty) {
        _passwordErrorText = 'Please enter password';
        isValidate = false;
      } else {
        _passwordErrorText = null;
      }
    });
    return isValidate;
  }


  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: ModalProgressHUD(
        inAsyncCall: isLoad,
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 24.0),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: <Widget>[
              Hero(
                tag: 'homeLogo',
                child: SizedBox(
                  height: 200.0,
                  child: Image.asset('images/logo.png'),
                ),
              ),
              const SizedBox(
                height: 48.0,
              ),
              TextField(
                controller: _emailController,
                onChanged: (value) {
                  //Do something with the user input.
                },
                decoration: kTextFieldDecoration.copyWith(
                  errorText: _emailErrorText,
                  labelText: 'Email',
                  hintText: 'Enter your email',
                ),
              ),
              const SizedBox(
                height: 8.0,
              ),
              TextField(
                controller: _passwordController,
                obscureText: true,
                onChanged: (value) {
                  //Do something with the user input.
                },
                decoration: kTextFieldDecoration.copyWith(
                  errorText: _passwordErrorText,
                  labelText: 'Password',
                  hintText: 'Enter your password.',
                )
              ),
              const SizedBox(
                height: 24.0,
              ),
              Padding(
                padding: const EdgeInsets.symmetric(vertical: 16.0),
                child: RoundedButton(
                  buttonColor: Theme.of(context).colorScheme.primary,
                  textColor: Theme.of(context).colorScheme.onPrimary,
                  text: 'Log in',
                  onPress: () async {
                    setState(() {
                      isLoad = true;
                    });
                    if(_validateInput()) {
                      try {
                        final credential = await FirebaseAuth.instance.signInWithEmailAndPassword(
                            email: _emailController.text.trim(),
                            password: _passwordController.text.trim()
                        );
                      } on FirebaseAuthException catch (e) {
                        if (e.code == 'user-not-found') {
                          setState(() {
                            isLoad = false;
                            _emailErrorText = 'No user found for that email.';
                          });
                        } else if (e.code == 'wrong-password') {
                          setState(() {
                            isLoad = false;
                            _passwordErrorText = 'Wrong password provided for that user.';
                          });
                        }

                      }
                    }
                  },
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
