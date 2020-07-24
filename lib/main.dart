import 'package:flutter/material.dart';
import 'package:google_sign_in/google_sign_in.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_messaging/firebase_messaging.dart';

void main() {
  runApp(MaterialApp(
    home: Main(),
  ));
}

class Main extends StatefulWidget {
  @override
  _MainState createState() => _MainState();
}

class _MainState extends State<Main> {
  final FirebaseAuth auth = FirebaseAuth.instance;
  final FirebaseMessaging messaging = FirebaseMessaging();
  GoogleSignInAccount googleAccount;
  GoogleSignIn googleSignIn = GoogleSignIn();
  bool loginStatus = false;
  var a = TextEditingController();
  var b = TextEditingController();

  @override
  void initState() {
    super.initState();
    initialCheck();
  }

  Future<void> initialCheck() async {
    FirebaseUser userUid = await auth.currentUser();
    bool usrExits = await googleSignIn.isSignedIn();
    if (usrExits) {
      print(userUid.uid);
    }
  }

  Future<dynamic> handleGoogleSignIn() async {
    try {
      bool usrExits = await googleSignIn.isSignedIn();
      if (usrExits) {
        print('user already exists.!');
        FirebaseUser userUid = await auth.currentUser();
        print(userUid.uid);
        setState(() => loginStatus = true);
        return;
      } else {
        googleAccount = await googleSignIn.signIn();
        if (googleAccount == null) {
          print('login process terminated');
          return;
        } else {
          try {
            AuthResult result = await auth
                .signInWithCredential(GoogleAuthProvider.getCredential(
              idToken: (await googleAccount.authentication).idToken,
              accessToken: (await googleAccount.authentication).accessToken,
            ));
            print(result.additionalUserInfo.profile);
            print(result.user.uid);
            setState(() => loginStatus = true);
          } catch (err) {
            print(err);
          }
        }
      }
    } catch (err) {
      print(err);
    }
  }

  Future<dynamic> handleSignOut() async {
    await googleSignIn.signOut();
    print('Signout done');
    setState(() => loginStatus = false);
  }

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: Scaffold(
        body: Center(
          child: loginStatus
              ? Column(
                  children: <Widget>[
                    Container(
                      alignment: Alignment.topRight,
                      child: MaterialButton(
                        color: Colors.orange[300],
                        child: Text('Signout'),
                        onPressed: handleSignOut,
                      ),
                    ),
                    Expanded(
                        child: Column(
                      children: <Widget>[
                        SizedBox(height: 20),
                        TextField(
                          controller: a,
                        ),
                        SizedBox(height: 10),
                        TextField(
                          controller: b,
                        )
                      ],
                    ))
                  ],
                )
              : MaterialButton(
                  color: Colors.orange[300],
                  child: Text('SignIn with Google'),
                  onPressed: handleGoogleSignIn,
                ),
        ),
      ),
    );
  }
}
