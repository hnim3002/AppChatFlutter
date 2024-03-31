import 'package:email_validator/email_validator.dart';
import 'package:flash_chat_flutter/constants.dart';
import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import '../components/widget/rounded_button.dart';

class RegistrationScreen extends StatefulWidget {
  const RegistrationScreen({super.key});

  static String id = '/registration_screen';

  @override
  State<RegistrationScreen> createState() => _RegistrationScreenState();
}

class _RegistrationScreenState extends State<RegistrationScreen> {
  final TextEditingController _emailController = TextEditingController();
  final TextEditingController _passwordController = TextEditingController();
  final TextEditingController _rePasswordController = TextEditingController();
  String? _emailErrorText;
  String? _passwordErrorText;

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
      } else if (_rePasswordController.text.isEmpty) {
        _passwordErrorText = 'Please enter password';
        isValidate = false;
      } else if (_rePasswordController.text != _passwordController.text) {
        _passwordErrorText = 'Password & confirm password must be the same';
        isValidate = false;
      } else {
        _passwordErrorText = null;
      }
    });
    return isValidate;
  }

  @override
  void initState() {
    // TODO: implement initState
    super.initState();
    FirebaseAuth.instance.authStateChanges().listen((User? user) {
      if (user == null) {
        print('User is currently signed out!');
      } else {
        Navigator.pushNamed(context, '/chat_screen');
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 24.0),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: <Widget>[
            Flexible(
              child: Hero(
                tag: 'homeLogo',
                child: SizedBox(
                  height: 200.0,
                  child: Image.asset('images/logo.png'),
                ),
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
                hintText: 'Enter your password',
              ),
            ),
            const SizedBox(
              height: 8.0,
            ),
            TextField(
              controller: _rePasswordController,
              obscureText: true,
              onChanged: (value) {
                //Do something with the user input.
              },
              decoration: kTextFieldDecoration.copyWith(
                errorText: _passwordErrorText,
                labelText: 'Password',
                hintText: 'Enter your password',
              ),
            ),
            const SizedBox(
              height: 7.0,
            ),
            Padding(
              padding: const EdgeInsets.symmetric(vertical: 16.0),
              child: RoundedButton(
                buttonColor: Theme.of(context).colorScheme.primary,
                textColor: Theme.of(context).colorScheme.onPrimary,
                text: 'Register',
                onPress: () async {
                  if (_validateInput()) {
                    try {
                      final credential = await FirebaseAuth.instance
                          .createUserWithEmailAndPassword(
                        email: _emailController.text.trim(),
                        password: _passwordController.text.trim(),
                      );
                    } on FirebaseAuthException catch (e) {
                      if (e.code == 'email-already-in-use') {
                        setState(() {
                          _emailErrorText = ('The account already exists for that email.');
                        });
                      } else if (e.code == 'weak-password') {
                        setState(() {
                          _passwordErrorText = ('The password provided is too weak.');
                        });
                      }
                    } catch (e) {
                      print(e);
                    }
                  }
                  FirebaseAuth.instance.authStateChanges().listen((User? user) {
                    if (user == null) {
                      print('User is currently signed out!');
                    } else {
                      //pushReplacement
                      Navigator.pushNamed(context, '/chat_screen');
                    }
                  });
                },
              ),
            ),
          ],
        ),
      ),
    );
  }
}
