import 'package:flutter/material.dart';

class MessagesScreen extends StatelessWidget {
  const MessagesScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text("Messages")),
      body: ListView(
        children: const [
          ListTile(
            title: Text("Group Invite", style: TextStyle(color: Colors.white)),
            subtitle: Text("Alice invited you to 'Sunday Ride'", style: TextStyle(color: Colors.grey)),
            trailing: Icon(Icons.mail, color: Colors.blue),
          )
        ],
      ),
    );
  }
}
