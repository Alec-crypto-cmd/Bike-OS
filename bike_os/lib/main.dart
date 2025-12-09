import 'package:flutter/material.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'app.dart';

const SUPABASE_URL = "https://rwhaectrllygiusjghca.supabase.co";
const SUPABASE_ANON_KEY =
    "eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJpc3MiOiJzdXBhYmFzZSIsInJlZiI6InJ3aGFlY3RybGx5Z2l1c2pnaGNhIiwicm9sZSI6ImFub24iLCJpYXQiOjE3NjUyODU4NzQsImV4cCI6MjA4MDg2MTg3NH0.N1sxSOhJMWrjEPddC2O4NxbNFUE5exGUjeW82K_kwts";

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();

  await Supabase.initialize(
    url: SUPABASE_URL,
    anonKey: SUPABASE_ANON_KEY,
  );

  runApp(const BikeOSApp());
}

final supabase = Supabase.instance.client;
