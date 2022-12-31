import 'dart:async';

import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:itum_communication_platform/pages/groups/groups_home_page.dart';
import 'package:itum_communication_platform/widgets/widegets.dart';

class verifyEmailPage extends StatefulWidget {
  const verifyEmailPage({Key? key}) : super(key: key);

  @override
  _verifyEmailPageState createState() => _verifyEmailPageState();
}

class _verifyEmailPageState extends State<verifyEmailPage> {
  bool isEmailVerified = false;
  bool canResendEmail = false;
  Timer ? timer;

  @override
  void initState() {
    // TODO: implement initState
    super.initState();
    isEmailVerified = FirebaseAuth.instance.currentUser!.emailVerified;

    if(!isEmailVerified){
      sendVerificationEmail();

      timer = Timer.periodic(
        Duration(seconds: 3),
          (_) => checkEmailVerified(),
      );
    }
  }

  @override
  void dispose() {
    timer?.cancel();
    // TODO: implement dispose
    super.dispose();
  }

  Future checkEmailVerified() async {
    //call after email verification
    await FirebaseAuth.instance.currentUser!.reload();
    setState(() {
      isEmailVerified = FirebaseAuth.instance.currentUser!.emailVerified;
    });

    if(isEmailVerified) timer?.cancel();
  }

  Future sendVerificationEmail() async{
    try{
      final user = FirebaseAuth.instance.currentUser!;
      await user.sendEmailVerification();

      setState(() => canResendEmail = false);
      await Future.delayed(Duration(seconds: 5));
      setState(() => canResendEmail = true);
    } catch(e){
      showSnackBar(context, Colors.greenAccent, e.toString());
    }
  }

  @override
  Widget build(BuildContext context) => isEmailVerified
      ? GroupHome()
      : Scaffold(
    appBar: AppBar(
      title: Text("Verify Email Address"),
    ),
    body: Padding(
      padding: EdgeInsets.all(20),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Text('A verification email has been sent to your email.',
          textAlign: TextAlign.center,
          style: TextStyle(fontSize: 20),),
          SizedBox(height: 24,),
          ElevatedButton.icon(
            style: ElevatedButton.styleFrom(
              minimumSize: Size.fromHeight(50),
            ),
              onPressed: canResendEmail ? sendVerificationEmail : null,
              icon: Icon(Icons.email, size: 32,),
              label: Text('Resent Email',
              style: TextStyle(fontSize: 24),)),
          SizedBox(height: 8,),
          TextButton(
            style: ElevatedButton.styleFrom(
              minimumSize: Size.fromHeight(50)
            ),
              onPressed: () => FirebaseAuth.instance.signOut(),
              child: Text('Cancel',
              style: TextStyle(fontSize: 24),))
        ],
      ),
    ),
  );
}
