import 'package:supabase_flutter/supabase_flutter.dart';

class AuthServices {
  final SupabaseClient _supabase = Supabase.instance.client;


  //signin backend
  Future<AuthResponse> signInWithEmailPassword(
    String email, String password)async{
    return await _supabase.auth.signInWithPassword(
       email: email,
       password: password,
    );
    }

  //signup backend
  Future<AuthResponse> signUpWithEmailPassword(String email, String password) async {
  return await Supabase.instance.client.auth.signUp(
    email: email,
    password: password,
  );
}



//signout
Future<void> signOut() async{
  await _supabase.auth.signOut();
}

//Get user email
String? getCurrentUserEmail(){
  final Session = _supabase.auth.currentSession;
  final User = Session?.user;
  return User?.email;
}
}

Future<Map<String, dynamic>?> getCurrentUserProfile() async {
  final user = Supabase.instance.client.auth.currentUser;
  if (user != null) {
    final response = await Supabase.instance.client
        .from('users_profiles')
        .select()
        .eq('id', user.id)
        .single();
    return response;
  }
  return null;
}
