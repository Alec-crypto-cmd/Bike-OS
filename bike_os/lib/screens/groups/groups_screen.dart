import 'package:flutter/material.dart';
import '../../services/supabase_service.dart';

class GroupsScreen extends StatelessWidget {
  const GroupsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text("My Group")),
      body: const Center(
        child: Text("Active Group Logic Here", style: TextStyle(color: Colors.grey)),
      ),
    );
  }
}
