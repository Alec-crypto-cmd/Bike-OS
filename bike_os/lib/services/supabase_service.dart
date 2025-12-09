import 'package:supabase_flutter/supabase_flutter.dart';
import '../models/user.dart';
import '../models/location.dart';
import '../main.dart';

class SupabaseService {
  // Singleton
  static final SupabaseService _instance = SupabaseService._internal();
  factory SupabaseService() => _instance;
  SupabaseService._internal();

  User? get currentUser => supabase.auth.currentUser;

  // 1. Auth: Anonymous Sign In
  Future<void> signInAnonymously() async {
    try {
      final response = await supabase.auth.signInAnonymously();
      
      if (response.user != null) {
        // Create or Update Profile
        // We use 'upsert' to handle re-logins if needed, or initial creation
        await _createInitialProfile(response.user!.id);
      }
    } catch (e) {
      throw Exception('Auth Failed: $e');
    }
  }

  Future<void> _createInitialProfile(String userId) async {
    // Check if profile exists
    final data = await supabase
        .from('profiles')
        .select()
        .eq('id', userId)
        .maybeSingle();

    if (data == null) {
      // Create new profile with random name/avatar
      final username = "Rider_${userId.substring(0, 4)}";
      await supabase.from('profiles').insert({
        'id': userId,
        'username': username,
        'avatar_url': 'https://api.dicebear.com/7.x/adventurer/png?seed=$userId', // consistent avatar
      });
    }
  }
  
  // 2. Realtime: Subscribe to Locations
  Stream<List<UserLocation>> subscribeToLocations() {
    // Note: In a real app we might filter by group. 
    // For this prompt, it says "Rendering aller Gruppenmitglieder", 
    // assuming we listen to a specific group or all for demo.
    // We'll return a stream that transforms Supabase events.
    
    return supabase
        .from('locations')
        .stream(primaryKey: ['user_id'])
        .map((data) => data.map((json) => UserLocation.fromJson(json)).toList());
  }

  // 3. Update Own Location
  Future<void> updateLocation(double lat, double lng, String status) async {
    final user = currentUser;
    if (user == null) return;

    await supabase.from('locations').upsert({
      'user_id': user.id,
      'lat': lat,
      'lng': lng,
      'updated_at': DateTime.now().toIso8601String(),
      'status': status,
    });
  }

  // 4. Update Status (Navigating/Online)
  Future<void> updateStatus(String status) async {
    // Convenience wrapper around updateLocation if we don't change lat/lng, 
    // but usually status changes happen WITH location changes or separate.
    // We can just update the status column if we want.
    final user = currentUser;
    if (user == null) return;

    await supabase.from('locations').update({
       'status': status,
       'updated_at': DateTime.now().toIso8601String(),
    }).eq('user_id', user.id);
  }
}
