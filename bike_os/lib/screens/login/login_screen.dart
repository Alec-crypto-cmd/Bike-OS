import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import '../../services/supabase_service.dart';
import '../../services/location_service.dart';

class LoginScreen extends StatefulWidget {
  const LoginScreen({super.key});

  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  bool _isLoading = false;
  
  Future<void> _handleLogin() async {
    setState(() => _isLoading = true);
    
    try {
      final authService = SupabaseService();
      await authService.signInAnonymously();
      
      // Request Location Permissions & Start Service immediately after login
      final locService = LocationService();
      await locService.initialize();

      if (mounted) {
        context.go('/map');
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Login Failed: $e')),
        );
      }
    } finally {
      if (mounted) {
        setState(() => _isLoading = false);
      }
    }
  }

  @override
  void initState() {
    super.initState();
    // Auto-login check could go here, but router handles it mostly.
    // For this prompt, user asked for "Auth... beim ersten Start"
    // We can trigger it automatically or via button. Google Maps style usually just starts.
    // Let's do a button for clarity/consent "Start Adventure"
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black, // Dark tech theme
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Icon(Icons.map_outlined, size: 80, color: Color(0xFF00E676)),
            const SizedBox(height: 20),
            const Text(
              "BikeOS Navigator",
              style: TextStyle(
                fontSize: 28, 
                fontWeight: FontWeight.bold, 
                color: Colors.white
              ),
            ),
            const SizedBox(height: 10),
            const Text(
              "Anonymous Secure Group Navigation",
              style: TextStyle(color: Colors.grey),
            ),
            const SizedBox(height: 50),
            _isLoading 
              ? const CircularProgressIndicator(color: Color(0xFF00E676))
              : ElevatedButton.icon(
                  onPressed: _handleLogin,
                  icon: const Icon(Icons.login),
                  label: const Text("Start Riding"),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: const Color(0xFF00E676),
                    foregroundColor: Colors.black,
                    padding: const EdgeInsets.symmetric(horizontal: 40, vertical: 15),
                  ),
                ),
          ],
        ),
      ),
    );
  }
}
