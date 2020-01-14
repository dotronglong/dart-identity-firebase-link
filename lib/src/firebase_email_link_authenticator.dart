import 'dart:convert';

import 'package:crypto/crypto.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_dynamic_links/firebase_dynamic_links.dart';
import 'package:flutter/material.dart';
import 'package:identity/identity.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:sso/sso.dart';

import 'email_link_page.dart';

class FirebaseEmailLinkAuthenticator
    with WillNotify, WillConvertUser
    implements Authenticator {
  final String iOSBundleID;
  final String androidPackageName;
  final String url;
  final String androidMinimumVersion;
  final bool androidInstallIfNotAvailable;

  FirebaseEmailLinkAuthenticator(
      {@required this.url,
      @required this.iOSBundleID,
      @required this.androidPackageName,
      this.androidMinimumVersion = "1",
      this.androidInstallIfNotAvailable = true});

  @override
  WidgetBuilder get action => (context) => ActionButton(
      onPressed: () => Navigator.push(context,
          MaterialPageRoute(builder: (context) => EmailLinkPage(this))),
      color: Color.fromRGBO(97, 32, 105, 1),
      textColor: Colors.white,
      icon: Icon(
        Icons.link,
        color: Color.fromRGBO(97, 32, 105, 1),
      ),
      text: "Sign In With Link");

  @override
  Future<void> authenticate(BuildContext context, [Map parameters]) async {
    assert(parameters != null);
    assert(parameters["link"] != null);
    final String link = parameters["link"];
    final bool isSignInEmailLink =
        await FirebaseAuth.instance.isSignInWithEmailLink(link);
    if (!isSignInEmailLink) {
      return notify(context,
          "The link is invalid. Please try again or contact for support.");
    }
    SharedPreferences sharedPreferences = await SharedPreferences.getInstance();
    final String email = sharedPreferences.getString("email");

    notify(context, "Processing ...");
    return FirebaseAuth.instance
        .signInWithEmailAndLink(email: email, link: link)
        .then((result) => convert(result.user))
        .then((user) => Identity.of(context).user = user)
        .catchError(Identity.of(context).error);
  }

  Future<Uri> retrieveDynamicLink() async {
    final PendingDynamicLinkData data =
        await FirebaseDynamicLinks.instance.retrieveDynamicLink();
    return data?.link;
  }

  Future<String> generateDynamicLink(String email) async {
    var bytes = utf8.encode("$email-${DateTime.now().millisecondsSinceEpoch}");
    var digest = sha1.convert(bytes);
    String link = "$url?token=$digest";
    SharedPreferences sharedPreferences = await SharedPreferences.getInstance();
    sharedPreferences.setString("email", email);

    return link;
  }

  Future<void> sendEmailLink(String email) async {
    return FirebaseAuth.instance.sendSignInWithEmailLink(
      email: email,
      url: await generateDynamicLink(email),
      handleCodeInApp: true,
      iOSBundleID: iOSBundleID,
      androidPackageName: androidPackageName,
      androidInstallIfNotAvailable: true,
      androidMinimumVersion: androidMinimumVersion,
    );
  }
}
