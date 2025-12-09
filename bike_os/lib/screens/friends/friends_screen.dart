import 'package:flutter/material.dart';
import '../../services/supabase_service.dart';

class FriendsScreen extends StatefulWidget {
  const FriendsScreen({super.key});

  @override
  State<FriendsScreen> createState() => _FriendsScreenState();
}

class _FriendsScreenState extends State<FriendsScreen> {
  final SupabaseService _supabase = SupabaseService();
  List<Map<String, dynamic>> _friends = []; // Mock list for now

  @override
  void initState() {
    super.initState();
    _fetchFriends();
  }

  Future<void> _fetchFriends() async {
    // In a real app, we'd have a 'friends' table. 
    // Here we might just query profiles for demo.
    final response = await supabase
        .from('profiles')
        .select()
        .limit(10);
    
    if (mounted) {
      setState(() {
        _friends = List<Map<String, dynamic>>.from(response);
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("Friends"),
        backgroundColor: Colors.black,
      ),
      body: Column(
        children: [
          Padding(
            padding: const EdgeInsets.all(16.0),
            child: TextField(
              decoration: InputDecoration(
                hintText: "Search Friends...",
                prefixIcon: const Icon(Icons.search),
                filled: true,
                fillColor: Colors.grey[900],
                border: OutlineInputBorder(borderRadius: BorderRadius.circular(10)),
              ),
            ),
          ),
          Expanded(
            child: ListView.builder(
              itemCount: _friends.length,
              itemBuilder: (context, index) {
                final friend = _friends[index];
                return ListTile(
                  leading: CircleAvatar(
                    backgroundImage: NetworkImage(friend['avatar_url'] ?? ''),
                  ),
                  title: Text(friend['username'] ?? 'Unknown', style: const TextStyle(color: Colors.white)),
                  subtitle: const Text("Online", style: TextStyle(color: Colors.green)), // Mock status
                  trailing: IconButton(
                    icon: const Icon(Icons.group_add, color: Color(0xFF00E676)),
                    onPressed: () {
                      // Trigger invite logic
                      ScaffoldMessenger.of(context).showSnackBar(
                         SnackBar(content: Text("Invited ${friend['username']}"))
                      );
                    },
                  ),
                );
              },
            ),
          ),
        ],
      ),
    );
  }
}
