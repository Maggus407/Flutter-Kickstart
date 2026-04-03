import 'package:supabase_flutter/supabase_flutter.dart';

class AuthService {
  final SupabaseClient _supabaseClient;

  AuthService(this._supabaseClient);

  Future<User?> signUpWithEmail(String email, String password) async {
    try {
      final response = await _supabaseClient.auth.signUp(
        email: email,
        password: password,
      );
      return response.user;
    } catch (e) {
      throw Exception('Fehler bei der Registrierung: $e');
    }
  }

  Future<User?> signInWithEmail(String email, String password) async {
    try {
      final response = await _supabaseClient.auth.signInWithPassword(
        email: email,
        password: password,
      );
      return response.user;
    } catch (e) {
      throw Exception('Fehler bei der Anmeldung: $e');
    }
  }

  Future<void> signOut() async {
    try {
      await _supabaseClient.auth.signOut();
    } catch (e) {
      throw Exception('Fehler beim Abmelden: $e');
    }
  }

  Stream<User?> get authState => _supabaseClient.auth.onAuthStateChange.map(
    (event) => event.session?.user,
  );
}
