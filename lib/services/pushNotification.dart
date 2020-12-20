import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter/material.dart';
import 'package:iit_app/model/appConstants.dart';
import 'package:iit_app/model/built_post.dart';
import 'package:iit_app/pages/worshop_detail/workshopDetailPage.dart';

class PushNotification {
  static final FirebaseMessaging _firebaseMessaging = FirebaseMessaging();

  static initialize(BuildContext context) {
    _firebaseMessaging.getToken().then((token) => print("fcm token:$token"));
    Future<dynamic> myBackgroundMessageHandler(
        Map<String, dynamic> message) async {
      if (message.containsKey('data')) {
        // Handle data message
        final dynamic data = message['data'];
      }

      if (message.containsKey('notification')) {
        // Handle notification message
        final dynamic notification = message['notification'];
      }

      // Or do other work.
    }

    _firebaseMessaging.configure(
      onMessage: (Map<String, dynamic> message) async {
        print('on message $message');
      },
      onResume: (Map<String, dynamic> message) async {
        print('on resume $message');
        _navigateTo(
            context,
            AppConstants.workshopFromDatabase
                .where((w) => message['data']['id'] == w.id ? w : Null)
                .toList());
      },
      onLaunch: (Map<String, dynamic> message) async {
        print('on launch $message');

        // BuiltWorkshopSummaryPost w = message['data']['id'];

        // AppConstants.service
        //     .getWorkshopDetailsPost(
        //         , AppConstants.djangoToken)
        //     .then((w) =>
        _navigateTo(
            context,
            AppConstants.workshopFromDatabase
                .where((w) => message['data']['id'] == w.id ? w : Null)
                .toList());
      },
      // TODO: Setup required configuration for onBackgroundMessage Handler, code changes would be required in app level build.gradle , AndroidManifest.xml, MainActivity.kt etc.
      onBackgroundMessage: myBackgroundMessageHandler,
    );
  }

  static _navigateTo(BuildContext ctx, w) {
    Navigator.of(ctx).push(MaterialPageRoute(
        builder: (context) => WorkshopDetailPage(workshop: w, isPast: false)));
  }
}
