import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
// import 'package:votex/user/Components/Home.dart';
import 'package:votex/login/signup/loginpage.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:votex/onboarding/onboarding_view.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  await Supabase.initialize(
    url: 'https://shhgsjlohfoshaytirtg.supabase.co', // your Supabase URL
    anonKey: 'eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJpc3MiOiJzdXBhYmFzZSIsInJlZiI6InNoaGdzamxvaGZvc2hheXRpcnRnIiwicm9sZSI6ImFub24iLCJpYXQiOjE3NDc2NDMzNjgsImV4cCI6MjA2MzIxOTM2OH0.kUkuLVred2T09-cnzPE_VJC9VRJlf5gsihStK6x52Nw', // your Supabase anon key
  );

  final prefs = await SharedPreferences.getInstance();
  final onboarding = prefs.getBool("onboarding")??false;
  // final onboarding = prefs.getBool("onboarding",false) ;

  
// print("Onboarding completed: $onboarding");

  runApp(MyApp(onboarding: onboarding));
}

class MyApp extends StatelessWidget {
  final bool onboarding;
  const MyApp({super.key, this.onboarding = false});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'Votex',
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(seedColor: Colors.deepPurple),
        useMaterial3: true,
      ),
       home: onboarding?  OnboardingView()  : LoginPage() ,
    );
  }
}
