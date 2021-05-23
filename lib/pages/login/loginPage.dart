import 'package:flutter/material.dart';
import 'package:iit_app/external_libraries/spin_kit.dart';
import 'package:iit_app/model/appConstants.dart';
import 'package:iit_app/model/deprecatedWidgetsStyle.dart';
import 'package:iit_app/model/sharedPreferenceKeys.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../../services/authentication.dart' as authentication;

class LoginPage extends StatefulWidget {
  static Future guestLoginSetup() async {
    AppConstants.isGuest = true;
    AppConstants.djangoToken = null;
    //saving guest mode in shared preferences
    SharedPreferences prefs = await SharedPreferences.getInstance();
    prefs.clear();
    prefs = await SharedPreferences.getInstance();
    prefs.setBool(SharedPreferenceKeys.isGuest, true);
  }

  @override
  _LoginPageState createState() => new _LoginPageState();
}

void errorDialog(BuildContext context) {
  AppConstants.logInButtonEnabled = true;
  showDialog(
    context: context,
    builder: (_) => AlertDialog(
      title: Center(child: Text('OOPS....')),
      titlePadding: EdgeInsets.all(15),
      content: InkWell(
        splashColor: Colors.red,
        onTap: () {
          Navigator.of(context).pushReplacementNamed('/login');
        },
        child: Container(
          height: 175,
          width: 100,
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: <Widget>[
              Image.asset('assets/sorry.png'),
              Text('Sign in failed.'),
            ],
          ),
        ),
      ),
    ),
    barrierDismissible: true,
  );
}

class _LoginPageState extends State<LoginPage> {
  bool _loading;
  @override
  void initState() {
    this._loading = false;
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      minimum: const EdgeInsets.all(2.0),
      child: Scaffold(
        resizeToAvoidBottomInset: false,
        body: _loading
            ? Center(child: LoadingCircle)
            : ListView(
                children: <Widget>[
                  Container(
                    padding: EdgeInsets.fromLTRB(15.0, 110.0, 0.0, 0.0),
                    child: Text('Welcome to IIT(BHU)\'s Workshops App.',
                        style: TextStyle(
                            fontSize: 40.0, fontWeight: FontWeight.bold)),
                  ),
                  SizedBox(height: 15),
                  OutlinedButton(
                    style: outlineButtonStyle.copyWith(
                      shape: MaterialStateProperty.all<OutlinedBorder>(
                        RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(40)),
                      ),
                      side: MaterialStateProperty.resolveWith<BorderSide>(
                          (states) {
                        if (states.contains(MaterialState.pressed))
                          return BorderSide(
                            color: Theme.of(context).colorScheme.primary,
                            width: 1,
                          );
                        return BorderSide(color: Colors.grey);
                      }),
                      elevation:
                          MaterialStateProperty.resolveWith<double>((states) {
                        if (states.contains(MaterialState.pressed)) return 0.0;
                        return null;
                      }),
                      overlayColor: MaterialStateProperty.resolveWith(
                        (states) {
                          if (states.contains(MaterialState.pressed))
                            return Colors.grey;
                          return null;
                        },
                      ),
                      foregroundColor: MaterialStateProperty.resolveWith<Color>(
                        (states) {
                          if (states.contains(MaterialState.pressed))
                            return Colors.grey[400];
                          return Colors.grey;
                        },
                      ),
                    ),
                    onPressed: AppConstants.logInButtonEnabled == false
                        ? null
                        : () => _signInWithGoogle(),
                    child: Padding(
                      padding: const EdgeInsets.fromLTRB(0, 10, 0, 10),
                      child: Row(
                        mainAxisSize: MainAxisSize.min,
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: <Widget>[
                          Image(
                              image: AssetImage("assets/google_logo.png"),
                              height: 25.0),
                          Padding(
                            padding: const EdgeInsets.only(left: 10),
                            child: Text(
                              'Sign in with Google',
                              style: TextStyle(
                                fontSize: 20,
                              ),
                            ),
                          )
                        ],
                      ),
                    ),
                  ),
                  SizedBox(height: 15.0),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: <Widget>[
                      Text(
                        'Login Using Institute ID.',
                        style: TextStyle(fontFamily: 'Montserrat'),
                      ),
                    ],
                  ),
                  SizedBox(height: 150.0),
                  GestureDetector(
                    onTap: () async {
                      await LoginPage.guestLoginSetup();

                      Navigator.of(context).pushNamedAndRemoveUntil(
                          '/home', ModalRoute.withName('/root'));
                    },
                    child: CircleAvatar(
                      radius: 52,
                      backgroundColor: Colors.purple.withOpacity(0.3),
                      child: CircleAvatar(
                        radius: 50,
                        backgroundColor: Colors.black.withOpacity(0.8),
                        child: Center(
                            child: Text(
                          'Guest',
                          style: TextStyle(
                              fontSize: 26,
                              fontWeight: FontWeight.bold,
                              color: Colors.white),
                        )),
                      ),
                    ),
                  ),
                ],
              ),
      ),
    );
  }

  void _signInWithGoogle() async {
    if (AppConstants.logInButtonEnabled == true) {
      print(
          'appConstants.logInButtonEnabled : ${AppConstants.logInButtonEnabled}');
      AppConstants.logInButtonEnabled = false;

      setState(() {
        this._loading = true;
      });

      final _user = await authentication.signInWithGoogle();

      AppConstants.logInButtonEnabled = true;

      if (_user == null || AppConstants.djangoToken == null) {
        setState(() {
          this._loading = false;
        });

        await authentication.signOutGoogle();

        return errorDialog(context);
      } else {
        // logged in successfully :)

        SharedPreferences prefs = await SharedPreferences.getInstance();
        await prefs.setString(
            SharedPreferenceKeys.djangoToken, AppConstants.djangoToken);

        await AppConstants.service
            .getProfile(AppConstants.djangoToken)
            .then((snapshot) {
          AppConstants.currentUser = snapshot.body;
        }).catchError((onError) {
          print('unable to fetch user profile $onError');
        });

        Navigator.of(context)
            .pushNamedAndRemoveUntil('/home', ModalRoute.withName('/root'));
      }
    }

    setState(() {});
  }
}
