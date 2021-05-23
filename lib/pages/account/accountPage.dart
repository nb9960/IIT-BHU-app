import 'package:flutter/material.dart';
import 'package:iit_app/data/internet_connection_interceptor.dart';
import 'package:iit_app/model/appConstants.dart';
import 'package:iit_app/model/built_post.dart';
import 'package:iit_app/model/deprecatedWidgetsStyle.dart';
import 'package:iit_app/screens/accountScreen.dart';

class AccountPage extends StatefulWidget {
  @override
  _AccountPageState createState() => _AccountPageState();
}

class _AccountPageState extends State<AccountPage> {
  BuiltProfilePost profileDetails;

  @override
  void initState() {
    fetchProfileDetails();
    super.initState();
  }

  void _reload() async {
    await fetchProfileDetails();
  }

  Future<String> _asyncInputDialog(
    BuildContext context,
    String queryName,
    String data,
  ) async {
    final controller = TextEditingController(text: data);
    return showDialog<String>(
      context: context,
      barrierDismissible:
          false, // dialog is dismissible with a tap on the barrier
      builder: (BuildContext context) {
        return AlertDialog(
          title: Text('Enter $queryName'),
          content: new Row(
            children: <Widget>[
              Expanded(
                  child: TextField(
                keyboardType: queryName == 'Phone No.'
                    ? TextInputType.phone
                    : TextInputType.name,
                autofocus: true,
                controller: controller,
                decoration: InputDecoration(
                    labelText: queryName,
                    hintText: queryName == 'Phone No.'
                        ? '+91987654321'
                        : 'Sheldon Cooper'),
              ))
            ],
          ),
          actions: <Widget>[
            TextButton(
              style: flatButtonStyle,
              child: Text('Ok'),
              onPressed: () {
                Navigator.of(context).pop(controller.text);
              },
            ),
          ],
        );
      },
    );
  }

  Future showUnsuccessfulDialog(String title) async {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: new Text("Unsuccessful :("),
          content: new Text(title),
          actions: <Widget>[
            TextButton(
              style: flatButtonStyle,
              child: new Text("Ok."),
              onPressed: () {
                Navigator.pop(context);
              },
            ),
          ],
        );
      },
    );
  }

  Future fetchProfileDetails() async {
    await AppConstants.service
        .getProfile(AppConstants.djangoToken)
        .then((value) {
      profileDetails = value.body;
      setState(() {});
    }).catchError((onError) {
      if (onError is InternetConnectionException) {
        AppConstants.internetErrorFlushBar.showFlushbar(context);
        return;
      }
      print("Error in fetching profile: ${onError.toString()}");
    });
  }

  void updateProfileDetails(String name, String phoneNumber) async {
    final updatedProfile = BuiltProfilePost((b) => b
      ..name = name
      ..phone_number = phoneNumber);
    await AppConstants.service
        .updateProfileByPatch(AppConstants.djangoToken, updatedProfile)
        .then((value) {
      profileDetails = value.body;
      AppConstants.currentUser = value.body;
      setState(() {});
    }).catchError((onError) {
      if (onError is InternetConnectionException) {
        AppConstants.internetErrorFlushBar.showFlushbar(context);
        return;
      }
      print("Error in updating profile: ${onError.toString()}");
      if (phoneNumber != profileDetails.phone_number)
        showUnsuccessfulDialog(
            "Please enter a number of the form +919876543210. Don't forget +91!");
      else if (name != profileDetails.name)
        showUnsuccessfulDialog("Could not update your name!");
    });
  }

  Future<bool> onPop() {
    Navigator.pushNamedAndRemoveUntil(
        context, '/home', ModalRoute.withName('/root'));
    return Future.value(false);
  }

  @override
  Widget build(BuildContext context) {
    return WillPopScope(
      onWillPop: onPop,
      child: SafeArea(
          minimum: const EdgeInsets.all(2.0),
          child: RefreshIndicator(
            onRefresh: () async => _reload(),
            child: AccountScreen(
              profileDetails: profileDetails,
              asyncInputDialog: _asyncInputDialog,
              updateProfileDetails: updateProfileDetails,
            ),
          )),
    );
  }
}
