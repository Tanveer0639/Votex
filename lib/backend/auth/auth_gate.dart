import 'package:flutter/material.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:votex/login/signup/loginpage.dart';
import 'package:votex/user/homescreen/home_screen.dart';

class MyWidget extends StatelessWidget {
  const MyWidget({super.key});

  @override
  Widget build(BuildContext context) {
    return StreamBuilder(
      // ?listen to all auth changes
      stream: Supabase.instance.client.auth.onAuthStateChange, 

      // build approprat page based on auth state
      builder: (context, snapshot){
        // if Lodding.....
        if(snapshot.connectionState == ConnectionState.waiting){
          return const Scaffold(
            body: Center(child: CircularProgressIndicator(),),
          );
        }

      //check if there is a valid session currently
      final Session = snapshot.hasData? snapshot.data!.session : null;

      if(Session != null){
        return VotexHomeScreen();
      }else{
        return LoginPage();
      }

      }
    );
  }
}